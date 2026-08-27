# AgentMD Project Rules

## Purpose

This repository is the single source of truth for global Codex and Claude Code instructions.

## Instruction Layers

- Edit `global/AGENTS.md` for global agent behavior.
- Edit the root `AGENTS.md` only for rules specific to maintaining this repository.
- `CLAUDE.md` files are symbolic links to the `AGENTS.md` file in the same directory. Keep one authoritative file per layer and never duplicate their contents.
- Keep supporting global rules under `global/rules/` so relative references from `global/AGENTS.md` remain self-contained.

## Server Branch

- Work, commit, and finish every task on `server`.
- Treat `main` as a read-only baseline. Merge `server` into `main` only when the user explicitly requests it.

## Change Workflow

1. Update the appropriate `AGENTS.md` file.
2. Confirm both `CLAUDE.md` links still resolve to their same-directory `AGENTS.md` targets.
3. Run the platform-native link validator before committing: `scripts/validate-links.sh` on Linux or `scripts/validate-links.ps1` on Windows.
4. Follow `global/rules/git-delivery.md` for Git delivery.
