# Git Delivery

## Completed Change Delivery

Treat one completed, validated, independently reversible change set as the commit boundary; a file save or unfinished experiment is not a commit boundary. The user grants standing authorization to commit and push completed coding work without asking again.

After every code, test, asset, configuration, or code-adjacent documentation change:

1. Inspect the final diff and working tree. Stage only files that belong to the current task; preserve unrelated user changes and keep generated or ignored artifacts out of Git.
2. Run validation proportional to the change and any repository-required checks. A completed implementation with failing required checks is not ready to deliver.
3. Create a local commit with a terse message that identifies the outcome or root cause. Do not leave completed work uncommitted.
4. If an accessible GitHub remote exists, fetch before pushing, confirm the remote branch has not diverged, and push the current branch with upstream tracking when needed. Never force-push or rewrite published history. If authentication, network access, branch protection, divergence, or the absence of a GitHub remote prevents a safe push, keep the local commit and report the exact blocker.
5. Confirm the local commit, remote branch, and clean working-tree state before reporting completion.

Follow repository-specific branch and release conventions when present. After delivering work, leave the checkout on the repository's designated development branch when one exists.

## Version Releases

Create a Git tag or GitHub Release only when the user explicitly requests a release or version publication; ordinary commits and pushes never imply a release.

1. Resolve the requested semantic-version increment. By default, treat “小版本” as a patch increment (`Z` in `X.Y.Z`); treat “次版本/minor” as `Y`, and “主版本/major” as `X`.
2. Update every authoritative version file and the changelog on the designated development branch, then run the repository's complete release checks and build the distributable artifact.
3. Commit and push the release metadata, wait for required CI, promote the validated development branch to the release/default branch using the repository's required merge strategy, and push that branch.
4. Create and push an annotated `vX.Y.Z` tag only after the release branch points to the validated release commit. Never reuse or move an existing version tag.
5. Create or verify a GitHub Release whose tag and title are exactly `vX.Y.Z`. Publish only the matching version artifact, and include user-visible changes, installation or update instructions, completed validation, and limitations in the release notes.
6. Wait for the release workflow, then verify its conclusion, release metadata, downloadable artifact identity and version, and remote branch/tag alignment. A tag without a verified release artifact is not a completed release.
