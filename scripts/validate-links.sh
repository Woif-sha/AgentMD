#!/usr/bin/env bash
set -euo pipefail

repository_root="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
user_profile="${2:-${HOME:?HOME is not set}}"
start_marker='<!-- AGENTMD_START -->'
end_marker='<!-- AGENTMD_END -->'
markdown_count=0
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

validate_link() {
    local link=$1
    local target=$2
    local actual_target
    local expected_target

    if [[ ! -L "$link" ]]; then
        echo "Expected a symbolic link: $link" >&2
        return 1
    fi

    actual_target=$(readlink -f -- "$link" || true)
    expected_target=$(readlink -f -- "$target")
    if [[ "$actual_target" != "$expected_target" ]]; then
        echo "Unexpected target for $link: $actual_target (expected $expected_target)" >&2
        return 1
    fi

    echo "Valid repository link: $link -> $target"
}

validate_installed_file() {
    local kind=$1
    local link=$2
    local target=$3
    local index=$4
    local actual_target
    local expected_target
    local installed_block

    if [[ ! -e "$link" && ! -L "$link" ]] || [[ -d "$link" ]]; then
        echo "Expected an installed file or symbolic link: $link" >&2
        return 1
    fi

    expected_target=$(readlink -f -- "$target")
    if [[ -L "$link" ]]; then
        actual_target=$(readlink -f -- "$link" || true)
        if [[ "$actual_target" != "$expected_target" ]]; then
            echo "Unexpected target for $link: $actual_target (expected $expected_target)" >&2
            return 1
        fi
        echo "Valid linked $kind: $link -> $target"
        return
    fi

    if [[ "$kind" == instruction ]]; then
        installed_block="$temp_dir/installed-$index-block"
        extract_managed_block "$link" "$installed_block"
        if ! cmp -s -- "$installed_block" "$authoritative_block"; then
            echo "Outdated AgentMD managed block: $link" >&2
            return 1
        fi
        echo "Valid managed instruction copy: $link"
        return
    fi

    if ! cmp -s -- "$link" "$target"; then
        echo "Outdated managed rule copy: $link" >&2
        return 1
    fi
    echo "Valid managed rule copy: $link"
}

validate_destination() {
    local markdown_file=$1
    local line_number=$2
    local destination=$3
    local path_part
    local decoded_path
    local resolved_path

    destination=${destination#<}
    destination=${destination%>}
    if [[ "$destination" == \#* || "$destination" =~ ^[a-z][a-z0-9+.-]*: ]]; then
        return
    fi

    path_part=${destination%%[?#]*}
    if [[ -z "$path_part" ]]; then
        return
    fi

    printf -v decoded_path '%b' "${path_part//%/\\x}"
    if [[ "$decoded_path" == /* ]]; then
        resolved_path=$(readlink -m -- "$decoded_path")
    else
        resolved_path=$(readlink -m -- "$(dirname -- "$markdown_file")/$decoded_path")
    fi

    if [[ ! -e "$resolved_path" ]]; then
        echo "Broken Markdown link in ${markdown_file#"$repository_root"/}:$line_number: $destination" >&2
        return 1
    fi
}

validate_markdown_file() {
    local markdown_file=$1
    local fence_pattern='^[[:space:]]*(```|~~~)'
    local reference_pattern='^[[:space:]]{0,3}\[[^]]+\]:[[:space:]]*(<[^>]+>|[^[:space:]]+)'
    local inline_pattern="!?\\[[^]]*\\]\\((<[^>]+>|[^[:space:])]+)([[:space:]]+[\"'][^\"']*[\"'])?\\)"
    local line
    local remainder
    local destination
    local match
    local line_number=0
    local in_fence=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number += 1))
        if [[ "$line" =~ $fence_pattern ]]; then
            if [[ "$in_fence" == true ]]; then in_fence=false; else in_fence=true; fi
            continue
        fi
        if [[ "$in_fence" == true ]]; then continue; fi

        if [[ "$line" =~ $reference_pattern ]]; then
            validate_destination "$markdown_file" "$line_number" "${BASH_REMATCH[1]}"
        fi

        remainder=$line
        while [[ "$remainder" =~ $inline_pattern ]]; do
            destination=${BASH_REMATCH[1]}
            match=${BASH_REMATCH[0]}
            validate_destination "$markdown_file" "$line_number" "$destination"
            remainder=${remainder#*"$match"}
        done
    done < "$markdown_file"
}

repository_root=$(readlink -f -- "$repository_root")
authoritative_file="$repository_root/global/AGENTS.md"
authoritative_block="$temp_dir/authoritative-block"
extract_managed_block "$authoritative_file" "$authoritative_block"

validate_link "$repository_root/CLAUDE.md" "$repository_root/AGENTS.md"
validate_link "$repository_root/global/CLAUDE.md" "$authoritative_file"

installed_index=0
validate_installed_file instruction "$user_profile/.codex/AGENTS.md" "$authoritative_file" "$((installed_index += 1))"
validate_installed_file instruction "$user_profile/.claude/CLAUDE.md" "$repository_root/global/CLAUDE.md" "$((installed_index += 1))"

while IFS= read -r -d '' rule_file; do
    rule_name=$(basename -- "$rule_file")
    validate_installed_file rule "$user_profile/.codex/rules/$rule_name" "$rule_file" "$((installed_index += 1))"
    validate_installed_file rule "$user_profile/.claude/rules/$rule_name" "$rule_file" "$((installed_index += 1))"
done < <(find "$repository_root/global/rules" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

while IFS= read -r -d '' markdown_file; do
    validate_markdown_file "$markdown_file"
    ((markdown_count += 1))
done < <(find "$repository_root" -type f -name '*.md' -print0)

echo "Valid local Markdown links in $markdown_count files"
