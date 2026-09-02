# AgentMD Project Rules

## Purpose

This repository is the single source of truth for global Codex and Claude Code instructions.

## Instruction Layers

- Edit `global/AGENTS.md` for global agent behavior.
- Edit the root `AGENTS.md` only for rules specific to maintaining this repository.
- `CLAUDE.md` files are symbolic links to the `AGENTS.md` file in the same directory. Keep one authoritative file per layer and never duplicate their contents.
- Keep supporting global rules under `global/rules/` so relative references from `global/AGENTS.md` remain self-contained.
- Keep the official `CODEGRAPH_START/END` block inline in `global/AGENTS.md`; update it only through `scripts/sync-codegraph-instructions.sh`.

## Server Branch

- Work, commit, and finish server-specific tasks on `server`.
- Treat `main` as the source of shared rules. Adopt a shared change only when the server environment should use it.
- Merge `server` into `main` only when the user explicitly requests it.
- Treat CodeGraph as an optional capability activated for repositories containing `.codegraph/`.

## Merge Policy

- When merging `main` into `server`, resolve conflicting files with `main`'s complete version.
- If a conflict concerns server-versus-computer environment differences, stop before resolving and ask the user which version to keep.

## Change Workflow

1. Update the appropriate `AGENTS.md` file.
2. After CodeGraph installation or upgrade, run `scripts/sync-codegraph-instructions.sh`.
3. Confirm both `CLAUDE.md` links still resolve to their same-directory `AGENTS.md` targets.
4. Run `scripts/validate-links.sh` before committing.
5. Follow `global/rules/git-delivery.md` for Git delivery.
