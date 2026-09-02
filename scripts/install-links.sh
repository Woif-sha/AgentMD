#!/usr/bin/env bash
set -euo pipefail

repository_root="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
user_profile="${2:-${HOME:?HOME is not set}}"
start_marker='<!-- AGENTMD_START -->'
end_marker='<!-- AGENTMD_END -->'
backup_root="$user_profile/.agentmd-backups/$(date +%Y%m%d-%H%M%S)"
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

extract_managed_block() {
    local source=$1
    local output=$2
    local start_count
    local end_count

    start_count=$(grep -Fxc -- "$start_marker" "$source" || true)
    end_count=$(grep -Fxc -- "$end_marker" "$source" || true)
    if [[ "$start_count" != 1 || "$end_count" != 1 ]]; then
        echo "Expected one complete AgentMD managed block in: $source" >&2
        return 1
    fi

    awk -v start="$start_marker" -v end="$end_marker" '
        $0 == start { copying = 1 }
        copying { print }
        $0 == end { copying = 0 }
    ' "$source" > "$output"

    if [[ $(head -n 1 "$output") != "$start_marker" || $(tail -n 1 "$output") != "$end_marker" ]]; then
        echo "Expected one ordered AgentMD managed block in: $source" >&2
        return 1
    fi
}

replace_managed_block() {
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

backup_file() {
    local file=$1
    local relative_path=${file#"$user_profile"/}
    local backup_path="$backup_root/$relative_path"

    mkdir -p -- "$(dirname -- "$backup_path")"
    cp -L -- "$file" "$backup_path"
    echo "Backed up: $file -> $backup_path"
}

repository_root=$(readlink -f -- "$repository_root")
authoritative_file="$repository_root/global/AGENTS.md"
authoritative_block="$temp_dir/authoritative-block"
extract_managed_block "$authoritative_file" "$authoritative_block"

actions=()
kinds=()
links=()
targets=()

plan_entry() {
    local kind=$1
    local link=$2
    local target=$3
    local expected_target
    local actual_target
    local installed_block
    local action

    if [[ ! -f "$target" ]]; then
        echo "Managed source does not exist: $target" >&2
        return 1
    fi
    expected_target=$(readlink -f -- "$target")

    if [[ ! -e "$link" && ! -L "$link" ]]; then
        action=CreateLink
    elif [[ -d "$link" ]]; then
        echo "Expected a file or symbolic link: $link" >&2
        return 1
    elif [[ -L "$link" ]]; then
        actual_target=$(readlink -f -- "$link" || true)
        if [[ "$actual_target" != "$expected_target" ]]; then
            echo "Refusing to replace an unexpected symbolic link: $link -> $actual_target" >&2
            return 1
        fi
        action=UnchangedLink
    elif [[ "$kind" == Instruction ]]; then
        installed_block="$temp_dir/installed-${#actions[@]}-block"
        if ! extract_managed_block "$link" "$installed_block"; then
            backup_file "$link"
            return 1
        fi
        if cmp -s -- "$installed_block" "$authoritative_block"; then
            action=UnchangedCopy
        else
            action=UpdateManagedBlock
        fi
    elif cmp -s -- "$link" "$target"; then
        action=UnchangedCopy
    else
        action=UpdateRuleCopy
    fi

    actions+=("$action")
    kinds+=("$kind")
    links+=("$link")
    targets+=("$target")
}

plan_entry Instruction "$user_profile/.codex/AGENTS.md" "$authoritative_file"
plan_entry Instruction "$user_profile/.claude/CLAUDE.md" "$repository_root/global/CLAUDE.md"

while IFS= read -r -d '' rule_file; do
    rule_name=$(basename -- "$rule_file")
    plan_entry Rule "$user_profile/.codex/rules/$rule_name" "$rule_file"
    plan_entry Rule "$user_profile/.claude/rules/$rule_name" "$rule_file"
done < <(find "$repository_root/global/rules" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

for index in "${!actions[@]}"; do
    action=${actions[$index]}
    link=${links[$index]}
    target=${targets[$index]}

    case "$action" in
        CreateLink)
            mkdir -p -- "$(dirname -- "$link")"
            ln -s -- "$target" "$link"
            echo "Linked: $link -> $target"
            ;;
        UpdateManagedBlock)
            updated="$temp_dir/updated-$index"
            replace_managed_block "$link" "$authoritative_block" "$updated"
            backup_file "$link"
            mv -- "$updated" "$link"
            echo "Updated managed block: $link"
            ;;
        UpdateRuleCopy)
            backup_file "$link"
            cp -- "$target" "$link"
            echo "Updated managed rule copy: $link"
            ;;
        UnchangedLink)
            echo "Already linked: $link -> $target"
            ;;
        UnchangedCopy)
            echo "Managed copy is current: $link"
            ;;
    esac
done
