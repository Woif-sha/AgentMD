# AgentMD

Global Codex and Claude Code instructions, versioned in one private repository.

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
| `%USERPROFILE%\.codex\AGENTS.md` | `global/AGENTS.md` |
| `%USERPROFILE%\.claude\CLAUDE.md` | `global/CLAUDE.md` |
| `%USERPROFILE%\.codex\rules\*.md` | `global/rules/*.md` |
| `%USERPROFILE%\.claude\rules\*.md` | `global/rules/*.md` |

On Linux, install or refresh the global links with Bash:

```bash
./scripts/install-links.sh
```

Validate repository symbolic links, global links, and local Markdown link targets with:

```bash
./scripts/validate-links.sh
```

On Windows, use PowerShell:

```powershell
.\scripts\install-links.ps1
```

Validate with:

```powershell
.\scripts\validate-links.ps1
```

Existing global files are copied to `$HOME/.agentmd-backups/<timestamp>` on Linux or `%USERPROFILE%\.agentmd-backups\<timestamp>` on Windows before replacement.
