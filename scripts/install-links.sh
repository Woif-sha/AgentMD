#!/usr/bin/env bash
set -euo pipefail

repository_root="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
user_profile="${2:-${HOME:?HOME is not set}}"
backup_root="$user_profile/.agentmd-backups/$(date +%Y%m%d-%H%M%S)"

install_link() {
    local link=$1
    local target=$2
    local actual_target
    local expected_target
    local relative_path
    local backup_path

    if [[ ! -f "$target" ]]; then
        echo "Link target does not exist: $target" >&2
        return 1
    fi
    expected_target=$(readlink -f -- "$target")

    mkdir -p -- "$(dirname -- "$link")"

    if [[ -e "$link" || -L "$link" ]]; then
        actual_target=$(readlink -f -- "$link" || true)
        if [[ -L "$link" && "$actual_target" == "$expected_target" ]]; then
            echo "Already linked: $link -> $target"
            return
        fi

        relative_path=${link#"$user_profile"/}
        backup_path="$backup_root/$relative_path"
        mkdir -p -- "$(dirname -- "$backup_path")"
        cp -L -- "$link" "$backup_path"
        rm -- "$link"
        echo "Backed up: $link -> $backup_path"
    fi

    ln -s -- "$target" "$link"
    echo "Linked: $link -> $target"
}

repository_root=$(readlink -f -- "$repository_root")
install_link "$user_profile/.codex/AGENTS.md" "$repository_root/global/AGENTS.md"
install_link "$user_profile/.claude/CLAUDE.md" "$repository_root/global/CLAUDE.md"

while IFS= read -r -d '' rule_file; do
    rule_name=$(basename -- "$rule_file")
    install_link "$user_profile/.codex/rules/$rule_name" "$rule_file"
    install_link "$user_profile/.claude/rules/$rule_name" "$rule_file"
done < <(find "$repository_root/global/rules" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
