# Git Delivery

## Local Delivery

Treat one completed, validated, independently reversible change set as the commit boundary. The user authorizes local commits for completed tracked changes.

1. Inspect the final diff and working tree. Stage only task files; preserve unrelated user changes and exclude generated or ignored artifacts.
2. Run repository-required and proportional validation.
3. Commit locally with a terse outcome or root-cause message.
4. Confirm the commit, current branch, and working-tree state before reporting completion.

Follow repository-specific branch conventions and leave the checkout on its designated development branch.

## Remote Boundary

This server is local-only for Git delivery. Remote reads are allowed when needed; remote writes are outside its role. Do not push, create or merge pull requests, create or publish tags or releases, or dispatch workflows. Treat unavailable remote write access as expected, not as a blocker.

Change version or release metadata only when explicitly requested, then validate and commit it locally.
