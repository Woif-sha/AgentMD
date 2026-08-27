#!/usr/bin/env bash
set -euo pipefail

repository_root="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
user_profile="${2:-${HOME:?HOME is not set}}"
markdown_count=0

validate_link() {
    local link=$1
    local target=$2
    local actual_target

    if [[ ! -L "$link" ]]; then
        echo "Expected a symbolic link: $link" >&2
        return 1
    fi

    actual_target=$(readlink -f -- "$link" || true)
    if [[ "$actual_target" != "$target" ]]; then
        echo "Unexpected target for $link: $actual_target (expected $target)" >&2
        return 1
    fi

    echo "Valid: $link -> $target"
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
            if [[ "$in_fence" == true ]]; then
                in_fence=false
            else
                in_fence=true
            fi
            continue
        fi
        if [[ "$in_fence" == true ]]; then
            continue
        fi

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
validate_link "$repository_root/CLAUDE.md" "$repository_root/AGENTS.md"
validate_link "$repository_root/global/CLAUDE.md" "$repository_root/global/AGENTS.md"
validate_link "$user_profile/.codex/AGENTS.md" "$repository_root/global/AGENTS.md"
validate_link "$user_profile/.claude/CLAUDE.md" "$repository_root/global/AGENTS.md"

while IFS= read -r -d '' rule_file; do
    rule_name=$(basename -- "$rule_file")
    validate_link "$user_profile/.codex/rules/$rule_name" "$rule_file"
    validate_link "$user_profile/.claude/rules/$rule_name" "$rule_file"
done < <(find "$repository_root/global/rules" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

while IFS= read -r -d '' markdown_file; do
    validate_markdown_file "$markdown_file"
    ((markdown_count += 1))
done < <(find "$repository_root" -type f -name '*.md' -print0)

echo "Valid: local Markdown links in $markdown_count files"
