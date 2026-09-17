# Git Delivery

Integrate histories with merge, preserving existing commits. Do not rebase or squash; report incompatible repository policies instead of changing strategies.

## Completed Change Delivery

Treat one completed, validated, independently reversible change set as the commit boundary; a file save or unfinished experiment is not a commit boundary. The user grants standing authorization to commit completed coding work locally without asking again.

Base commit, PR, and handoff claims on the task-owned final diff and read-back state.

After every code, test, asset, configuration, or code-adjacent documentation change:

1. Inspect the final diff and working tree. Preserve unrelated user changes and keep generated or ignored artifacts out of Git.
2. Run validation proportional to the change and any repository-required checks. A completed implementation with failing required checks is not ready to deliver.
3. Before each task commit, run `git pull --no-rebase --ff`, preserving uncommitted work. Resolve conflicts by inspecting both sides and preserving their intended behavior; ask when intent is ambiguous. Finish any merge, review the final diff, and rerun affected checks before committing.
4. Stage only files that belong to the current task, then create a local commit with a terse message that identifies the outcome or root cause. Do not leave completed work uncommitted.
5. Confirm the local commit and working-tree state before reporting completion.

Follow repository-specific branch and release conventions when present. After delivering work, leave the checkout on the repository's designated development branch when one exists.

Ordinary delivery ends after verifying the local commit and working-tree state. The user pushes branches for all workflows; do not push directly or through another tool. If a PR or release needs commits not yet on the remote, report what is ready and wait for the user to push.

## GitHub CLI PR Delivery

Use the locally authenticated GitHub CLI as the primary client for PR creation, inspection, and merge. The GitHub App may provide read-only context, but do not probe its write permissions before using the verified CLI path.

PR inspection is read-only. A request to create a PR does not authorize merging it.

1. Run `gh auth status` and confirm the CLI is authenticated as the intended user with access to the repository and the scopes required for the operation.
2. When creation is requested, confirm the intended commits are on the remote branch, then use `gh pr create` with the requested draft or ready state.
3. Only when merging is explicitly requested, use `gh pr view` and the repository's required check commands to confirm the PR is mergeable and every required check has passed or no checks apply.
4. Merge with `gh pr merge --merge`.
5. Verify the PR is `MERGED`, confirm any issue named by `Closes` was closed, and synchronize the local default branch with the remote.

Preserve required checks and branch protections throughout this path; never force-push or bypass them.

## Version Releases

When the user requests a version release, read [release.md](release.md) before preparing it.
