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

## GitHub CLI PR Delivery

Use the locally authenticated GitHub CLI as the primary client for PR creation, inspection, and merge. The GitHub App may provide read-only context, but do not probe its write permissions before using the verified CLI path.

1. Run `gh auth status` and confirm the CLI is authenticated as the intended user with access to the repository and the scopes required for the operation.
2. Create the PR with `gh pr create` and the requested draft or ready state.
3. Before merging, use `gh pr view` and the repository's required check commands to confirm the PR is mergeable and every required check has passed or no checks apply.
4. Merge with `gh pr merge` using the repository's required merge strategy.
5. Verify the PR is `MERGED`, confirm any issue named by `Closes` was closed, and synchronize the local default branch with the remote.

Preserve required checks and branch protections throughout this path; never force-push or bypass them.

## Version Releases

Create a Git tag or GitHub Release only when the user explicitly requests a release or version publication; ordinary commits and pushes never imply a release.

### Release Records

- Write changelog entries and Release notes in Chinese; retain original spelling only for code identifiers, filenames, commands, and proper names.
- Keep `CHANGELOG.md` under `## 未发布` and dated `## X.Y.Z - YYYY-MM-DD` sections. Under each, use the nonempty categories `### 新增`, `### 调整`, `### 修复`, `### 安全`, and `### 工程` in that order. Move shipped entries from `未发布` into the version section without duplication.
- Generate Release notes from that version's changelog with this hierarchy: `# [**vX.Y.Z**](release URL)`, `## 更新内容`, the existing `###` change categories, `## 安装与更新`, `## 发布校验`, and `## 完整记录`.
- Describe observable changes rather than commits or implementation chronology. State only checks actually completed; never present pending or unrun validation as passed.

### GitHub Actions Delivery

1. Resolve the requested semantic-version increment. By default, treat “小版本” as a patch increment (`Z` in `X.Y.Z`); treat “次版本/minor” as `Y`, and “主版本/major” as `X`.
2. Update every authoritative version file and the changelog on the designated development branch, then run the repository's complete release checks and build the distributable artifact.
3. Commit and push the release metadata, wait for required CI, promote the validated development branch to the release/default branch using the repository's required merge strategy, and push that branch.
4. From the release branch, dispatch the repository's GitHub Actions release workflow with `X.Y.Z`. The workflow is the sole publisher: it creates the immutable `vX.Y.Z` tag, a same-titled Release, and only matching version artifacts. Never create a version tag or Release locally or manually; if the workflow is unavailable, stop and report the blocker.
5. Wait for the workflow, then verify its conclusion, Release tag and title, artifact identity and version, and remote branch/tag alignment. Establish asset identity by matching Release metadata digests to locally inspected deterministic artifacts; download only when metadata cannot settle it. Existing versions are immutable: a rerun must not move the tag or replace an asset with different bytes.
