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
| `%USERPROFILE%\.codex\AGENTS.md` | `global/AGENTS.md` |
| `%USERPROFILE%\.claude\CLAUDE.md` | `global/CLAUDE.md` |
| `%USERPROFILE%\.codex\rules\*.md` | `global/rules/*.md` |
| `%USERPROFILE%\.claude\rules\*.md` | `global/rules/*.md` |

Install or refresh the global links from PowerShell:

```powershell
.\scripts\install-links.ps1
```

Existing global files are copied to `%USERPROFILE%\.agentmd-backups\<timestamp>` before replacement. Validate repository and global links with:

```powershell
.\scripts\validate-links.ps1
```
