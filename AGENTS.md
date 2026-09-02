# AgentMD Project Rules

## Purpose

This repository is the single source of truth for global Codex and Claude Code instructions.

## Instruction Layers

- Edit `global/AGENTS.md` for global agent behavior.
- Edit the root `AGENTS.md` only for rules specific to maintaining this repository.
- `CLAUDE.md` files are symbolic links to the `AGENTS.md` file in the same directory. Keep one authoritative file per layer and never duplicate their contents.
- Keep supporting global rules under `global/rules/` so relative references from `global/AGENTS.md` remain self-contained.

## Installed Instruction Ownership

- The content between `AGENTMD_START` and `AGENTMD_END` in `global/AGENTS.md` is the payload synchronized to user-level instruction files.
- A user-level instruction file that still links to this repository is exclusively managed by AgentMD.
- A user-level instruction file that has become a regular file is shared. Update only its AgentMD-managed payload and preserve all content outside the markers.
- Stop without overwriting when a shared instruction file has missing, duplicated, or out-of-order markers, or when a symbolic link points somewhere unexpected.
- Files under `global/rules/` are fully managed by AgentMD. Synchronize a regular installed copy in place instead of converting it back to a link.

## Branch Roles

- Use `main` for shared rules and the default Windows/client configuration.
- Use `server` for server-specific rules and Linux-native tooling.
- Work, commit, and finish server-specific tasks on `server`.
- Keep shared changes on `main`; apply a shared change to `server` only when the server environment should adopt it.
- Merge `server` into `main` only when the user explicitly requests it.

## Merge Policy

- When merging `main` into `server`, resolve conflicting files with `main`'s complete version.
- If a conflict concerns server-versus-computer environment differences, stop before resolving and ask the user which version to keep.

## Repository Research

- When studying an external repository, save the findings to `research/<repository-name>.md` before reporting completion.
- Treat `research/` as local workspace state: list `/research/` in `.git/info/exclude` and keep its files outside Git delivery.

## Change Workflow

1. When an external repository enters consideration, add or update its row in the `Source provenance` ledger in `README.md` with the reviewed revision, current status, influence, and integrating AgentMD commit. Keep the `AgentMD record` column limited to integrating commits; research notes remain local workspace state and are not referenced by tracked content.
2. Update the appropriate `AGENTS.md` file.
3. Run `scripts/install-links.sh` to install or synchronize the user-level files without taking over shared instruction content.
4. Run `scripts/validate-links.sh`, which must accept both current AgentMD links and current managed copies while continuing to require the repository's own `CLAUDE.md` links.
5. Follow `global/rules/git-delivery.md` for Git delivery. When upstream ideas change tracked AgentMD instructions, commit the integration first, then immediately record that exact commit in the ledger and deliver the provenance update before reporting completion.
