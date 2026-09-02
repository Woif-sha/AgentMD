# AgentMD Project Rules

## Purpose

This repository is the single source of truth for global Codex and Claude Code instructions.

## Instruction Layers

- Edit `global/AGENTS.md` for global agent behavior.
- Edit the root `AGENTS.md` only for rules specific to maintaining this repository.
- `CLAUDE.md` files are symbolic links to the `AGENTS.md` file in the same directory. Keep one authoritative file per layer and never duplicate their contents.
- Keep supporting global rules under `global/rules/` so relative references from `global/AGENTS.md` remain self-contained.
- Keep the official `CODEGRAPH_START/END` block inline in `global/AGENTS.md`; update it only through the platform-native `scripts/sync-codegraph-instructions.*` script.

## Branch Roles

- Use `main` for shared rules and the default Windows/client configuration.
- Use `server` for server-specific rules and Linux-native tooling.
- Treat CodeGraph as an optional capability on either supported branch, activated for repositories containing `.codegraph/`.
- Keep shared changes on `main`; apply a shared change to `server` only when the server environment should adopt it.

## Repository Research

- When studying an external repository, save the findings to `research/<repository-name>.md` before reporting completion.
- Treat `research/` as local workspace state: list `/research/` in `.git/info/exclude` and keep its files outside Git delivery.

## Change Workflow

1. When an external repository enters consideration, add or update its row in the `Source provenance` ledger in `README.md` with the reviewed revision, current status, influence, and integrating AgentMD commit. Keep the `AgentMD record` column limited to integrating commits; research notes remain local workspace state and are not referenced by tracked content.
2. Update the appropriate `AGENTS.md` file.
3. After CodeGraph installation or upgrade, run `scripts/sync-codegraph-instructions.ps1` to accept its current managed block and restore user-level links.
4. Confirm both `CLAUDE.md` links still resolve to their same-directory `AGENTS.md` targets.
5. Run `scripts/validate-links.ps1` before committing.
6. Follow `global/rules/git-delivery.md` for Git delivery. When upstream ideas change tracked AgentMD instructions, commit the integration first, then immediately record that exact commit in the ledger and deliver the provenance update before reporting completion.
