#!/usr/bin/env bash
set -euo pipefail

repository_root="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
user_profile="${2:-${HOME:?HOME is not set}}"
start_marker='<!-- CODEGRAPH_START -->'
end_marker='<!-- CODEGRAPH_END -->'
authoritative_file="$repository_root/global/AGENTS.md"
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

extract_parts() {
    local source=$1
    local block=$2
    local outside=$3
    local start_count
    local end_count

    start_count=$(grep -Fxc -- "$start_marker" "$source" || true)
    end_count=$(grep -Fxc -- "$end_marker" "$source" || true)
    if [[ "$start_count" != 1 || "$end_count" != 1 ]]; then
        echo "Expected one complete CodeGraph block in: $source" >&2
        return 1
    fi

    awk -v start="$start_marker" -v end="$end_marker" '
        $0 == start { copying = 1 }
        copying { print }
        $0 == end { copying = 0 }
    ' "$source" > "$block"

    if [[ $(head -n 1 "$block") != "$start_marker" || $(tail -n 1 "$block") != "$end_marker" ]]; then
        echo "Expected an ordered CodeGraph block in: $source" >&2
        return 1
    fi

    awk -v start="$start_marker" -v end="$end_marker" '
        $0 == start { skipping = 1; next }
        $0 == end { skipping = 0; next }
        !skipping { print }
    ' "$source" > "$outside"
}

replace_block() {
    local source=$1
    local block=$2
    local output=$3

    awk -v start="$start_marker" -v end="$end_marker" -v block="$block" '
        BEGIN {
            while ((getline line < block) > 0) {
                replacement = replacement line ORS
            }
            close(block)
        }
        $0 == start { printf "%s", replacement; skipping = 1; next }
        $0 == end { skipping = 0; next }
        !skipping { print }
    ' "$source" > "$output"
}

if ! command -v codegraph >/dev/null 2>&1; then
    echo 'CodeGraph is not installed.' >&2
    exit 1
fi
codegraph --version >/dev/null

repository_root=$(readlink -f -- "$repository_root")
authoritative_file="$repository_root/global/AGENTS.md"
extract_parts "$authoritative_file" "$temp_dir/authoritative-block" "$temp_dir/authoritative-outside"

candidate_block=''
replaceable_files=()
for file in "$user_profile/.codex/AGENTS.md" "$user_profile/.claude/CLAUDE.md"; do
    if [[ ! -e "$file" && ! -L "$file" ]]; then
        continue
    fi
    if [[ -L "$file" ]]; then
        continue
    fi
    if [[ ! -f "$file" ]]; then
        echo "Expected an instruction file or symbolic link: $file" >&2
        exit 1
    fi

    index=${#replaceable_files[@]}
    block="$temp_dir/candidate-$index-block"
    outside="$temp_dir/candidate-$index-outside"
    extract_parts "$file" "$block" "$outside"
    if ! cmp -s -- "$outside" "$temp_dir/authoritative-outside"; then
        echo "Refusing to replace an instruction file with unmanaged content: $file" >&2
        exit 1
    fi

    if [[ -z "$candidate_block" ]]; then
        candidate_block=$block
    elif ! cmp -s -- "$candidate_block" "$block"; then
        echo 'Codex and Claude contain different CodeGraph blocks. Resolve the mismatch before syncing.' >&2
        exit 1
    fi
    replaceable_files+=("$file")
done

if [[ -n "$candidate_block" ]] && ! cmp -s -- "$candidate_block" "$temp_dir/authoritative-block"; then
    replace_block "$authoritative_file" "$candidate_block" "$temp_dir/updated-agents"
    mv -- "$temp_dir/updated-agents" "$authoritative_file"
    echo "Updated CodeGraph block: $authoritative_file"
fi

for file in "${replaceable_files[@]}"; do
    rm -- "$file"
    echo "Removed CodeGraph-rewritten file: $file"
done

"$repository_root/scripts/install-links.sh" "$repository_root" "$user_profile"
"$repository_root/scripts/validate-links.sh" "$repository_root" "$user_profile"
