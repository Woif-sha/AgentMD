# Git Delivery

## Completed Change Delivery

Treat one completed, validated, independently reversible change set as the commit boundary; a file save or unfinished experiment is not a commit boundary. The user grants standing authorization to commit completed coding work locally without asking again.

Base commit, PR, and handoff claims on the task-owned final diff and read-back state.

After every code, test, asset, configuration, or code-adjacent documentation change:

1. Inspect the final diff and working tree. Preserve unrelated user changes and keep generated or ignored artifacts out of Git.
2. Run validation proportional to the change and any repository-required checks. A completed implementation with failing required checks is not ready to deliver.
3. Before each task commit, run `git pull` and integrate upstream changes according to repository conventions. Preserve uncommitted work and existing commits. Review the final diff and rerun affected checks before committing.
4. Stage only files that belong to the current task, then create a local commit with a terse message that identifies the outcome or root cause. Do not leave completed work uncommitted.
5. Confirm the local commit and working-tree state before reporting completion.

Follow repository-specific branch and release conventions when present. After delivering work, leave the checkout on the repository's designated development branch when one exists.

Delivery ends after verifying the local commit and working-tree state. The user handles pushes; do not run `git push`.

## GitHub CLI PR Delivery

Use the locally authenticated GitHub CLI as the primary client for PR creation, inspection, and merge. The GitHub App may provide read-only context, but do not probe its write permissions before using the verified CLI path.

1. Run `gh auth status` and confirm the CLI is authenticated as the intended user with access to the repository and the scopes required for the operation.
2. Create the PR with `gh pr create` and the requested draft or ready state.
3. Before merging, use `gh pr view` and the repository's required check commands to confirm the PR is mergeable and every required check has passed or no checks apply.
4. Merge with `gh pr merge` using the repository's required merge strategy.
5. Verify the PR is `MERGED`, confirm any issue named by `Closes` was closed, and synchronize the local default branch with the remote.

Preserve required checks and branch protections throughout this path; never force-push or bypass them.

## Version Releases

When the user requests a version release, read [release.md](release.md) before preparing it.
