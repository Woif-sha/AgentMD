# AgentMD Project Rules

## Purpose

This repository is the single source of truth for global Codex and Claude Code instructions.

## Instruction Layers

- Edit `global/AGENTS.md` for global agent behavior.
- Edit the root `AGENTS.md` only for rules specific to maintaining this repository.
- `CLAUDE.md` files are symbolic links to the `AGENTS.md` file in the same directory. Keep one authoritative file per layer and never duplicate their contents.
- Keep supporting global rules under `global/rules/` so relative references from `global/AGENTS.md` remain self-contained.

## Repository Research

- When studying an external repository, save the findings to `research/<repository-name>.md` before reporting completion.
- Treat `research/` as local workspace state: list `/research/` in `.git/info/exclude` and keep its files outside Git delivery.

## Change Workflow

1. When an external repository enters consideration, add or update its row in the `Source provenance` ledger in `README.md` with the reviewed revision, current status, influence, and available research records.
2. Update the appropriate `AGENTS.md` file.
3. Confirm both `CLAUDE.md` links still resolve to their same-directory `AGENTS.md` targets.
4. Run `scripts/validate-links.ps1` before committing.
5. Follow `global/rules/git-delivery.md` for Git delivery. When upstream ideas change tracked AgentMD instructions, commit the integration first, then immediately record that exact commit in the ledger and deliver the provenance update before reporting completion.
