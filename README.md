# AgentMD — Server branch

Global Codex and Claude Code instructions for Linux and server environments.

## Choose a branch

| Branch | Use when | Difference |
| --- | --- | --- |
| `main` | Windows or a default client installation | Shared rules and PowerShell-native tooling |
| `server` | A Linux or server installation | Server-specific rules and Bash-native tooling |

CodeGraph is an optional capability on both supported branches. A repository containing `.codegraph/` activates its agent instructions; repositories without that directory use the same branch without CodeGraph.

## Layout

| File | Purpose |
| --- | --- |
| `global/AGENTS.md` | Authoritative global instructions |
| `global/CLAUDE.md` | Symbolic link to `global/AGENTS.md` |
| `global/rules/` | Supporting documents referenced by global instructions |
| `AGENTS.md` | Instructions specific to this repository |
| `CLAUDE.md` | Symbolic link to the root `AGENTS.md` |

Always edit the appropriate `AGENTS.md`. The matching `CLAUDE.md` resolves to the same content automatically.

## Global links

| Global path | Repository target |
| --- | --- |
| `$HOME/.codex/AGENTS.md` | `global/AGENTS.md` |
| `$HOME/.claude/CLAUDE.md` | `global/CLAUDE.md` |
| `$HOME/.codex/rules/*.md` | `global/rules/*.md` |
| `$HOME/.claude/rules/*.md` | `global/rules/*.md` |

On Linux, install or refresh the global links with Bash:

```bash
./scripts/install-links.sh
```

Validate repository symbolic links, global links, and local Markdown link targets with:

```bash
./scripts/validate-links.sh
```

Existing global files are copied to `$HOME/.agentmd-backups/<timestamp>` before replacement.

## CodeGraph integration

The official `CODEGRAPH_START/END` block stays inline in `global/AGENTS.md` and activates only for repositories containing `.codegraph/`.

After CodeGraph installation or upgrade, accept the current managed block and restore the AgentMD links with the platform-native command:

```bash
./scripts/sync-codegraph-instructions.sh
```

The sync stops if the rewritten file contains unmanaged content, then restores the links and runs the existing validator.
