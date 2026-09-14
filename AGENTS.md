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
- Keep shared changes on `main`; apply a shared change to `server` only when the server environment should adopt it.

## Repository Research

- When studying an external repository, save the findings to `research/<repository-name>.md` before reporting completion.
- Treat `research/` as local workspace state: list `/research/` in `.git/info/exclude` and keep its files outside Git delivery.

## Change Workflow

1. When an external repository enters consideration, add or update its row in the `Source provenance` ledger in `README.md` with the reviewed revision, current status, influence, and integrating AgentMD commit. Keep the `AgentMD record` column limited to integrating commits; research notes remain local workspace state and are not referenced by tracked content.
2. Update the appropriate `AGENTS.md` file.
3. After changing `global/AGENTS.md` or `global/rules/`, run `scripts/install-links.ps1`; a commit or push does not synchronize user-level files. For a shared regular instruction file, completion requires the managed payload to be current while all content outside the markers, including tool-managed blocks such as CodeGraph, remains unchanged.
4. Run `scripts/validate-links.ps1`, which must accept both current AgentMD links and current managed copies while continuing to require the repository's own `CLAUDE.md` links. For isolated validation under a temporary user profile, run `scripts/validate-isolated-links.ps1` so the temporary profile is removed in a `finally` cleanup after the link checks. Do not deliver the change until installation and validation both pass.
5. Follow `global/rules/git-delivery.md` for Git delivery. When upstream ideas change tracked AgentMD instructions, commit the integration first, then immediately record that exact commit in the ledger and deliver the provenance update before reporting completion.
