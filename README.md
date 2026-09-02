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

Existing global files are copied to `%USERPROFILE%\.agentmd-backups\<timestamp>` before replacement. Validate repository symbolic links, global links, and local Markdown link targets with:

```powershell
.\scripts\validate-links.ps1
```

## Source provenance

AgentMD distills selected ideas instead of mirroring upstream repositories. This ledger records every upstream repository that can be confirmed from repository evidence, including sources that were evaluated but not adopted.

| Upstream | Pinned revision | Status | Influence on AgentMD | AgentMD record |
| --- | --- | --- | --- | --- |
| [`lili-luo/aicoding-cookbook`](https://github.com/lili-luo/aicoding-cookbook) | [`0957cc4`](https://github.com/lili-luo/aicoding-cookbook/commit/0957cc4d767eb880675b487a918330e9ccde8edb) | Seeded, later distilled | Initial global rules for observable failures, root-cause fixes, structural work, bounded planning, and agent execution | [`f72b8db`](https://github.com/Woif-sha/AgentMD/commit/f72b8dbbe81054530dfec8e68fef11707176aa32) |
| [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills) (formerly `forrestchang/andrej-karpathy-skills`) | [`2c60614`](https://github.com/multica-ai/andrej-karpathy-skills/commit/2c606141936f1eeef17fa3043a72095b4765b9c2) | Adopted and adapted | The four core principles: think before coding, simplicity first, surgical changes, and goal-driven execution | [`b7e2d8c`](https://github.com/Woif-sha/AgentMD/commit/b7e2d8c0eb928b9e84e5ced95d5b5f24154a7492) |
| [`LB623/no-negative-echo`](https://github.com/LB623/no-negative-echo) | [`eba9f1d`](https://github.com/LB623/no-negative-echo/commit/eba9f1d2b4c19e699786a49427189988ad6d8d65) | Adopted and adapted | Final-state communication for artifacts, commits, PRs, and handoffs | [research record](https://github.com/Woif-sha/AgentMD/blob/0f599f6740d7657059cd29b722530b11e57f688c/research/no-negative-echo.md), [`9f422e8`](https://github.com/Woif-sha/AgentMD/commit/9f422e8b5fe83b89773401cc1d0bcb808f1906e0) |
| [`lennney/stop-that-shit`](https://github.com/lennney/stop-that-shit) | [`68f4a7a`](https://github.com/lennney/stop-that-shit/commit/68f4a7a1303b00a8f8319eb33ff1ca84eb0ad3cc) | Researched, not yet adopted | Paired bad/good cases, task mutation modes, and host-independent guard boundaries | — |

Add a row when an upstream repository enters consideration, pin the reviewed revision, and update its status rather than removing its history. Link the durable research note and integrating AgentMD commit when they exist. Do not assign provenance from textual similarity alone.
