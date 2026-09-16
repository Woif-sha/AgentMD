# Version Releases

Create a Git tag or GitHub Release only when the user explicitly requests a release or version publication; that request authorizes the pushes required by the release workflow. Ordinary commits and pushes never imply a release.

## Release Records

- Write changelog entries and Release notes in Chinese; retain original spelling only for code identifiers, filenames, commands, and proper names.
- Keep `CHANGELOG.md` under `## 未发布` and dated `## X.Y.Z - YYYY-MM-DD` sections. Under each, use the nonempty categories `### 新增`, `### 调整`, `### 修复`, `### 安全`, and `### 工程` in that order. Move shipped entries from `未发布` into the version section without duplication.
- Generate Release notes from that version's changelog with this hierarchy: `# [**vX.Y.Z**](release URL)`, `## 更新内容`, the existing `###` change categories, `## 安装与更新`, `## 发布校验`, and `## 完整记录`.
- Describe observable changes rather than commits or implementation chronology. State only checks actually completed; never present pending or unrun validation as passed.

## GitHub Actions Delivery

1. Resolve the requested semantic-version increment. By default, treat “小版本” as a patch increment (`Z` in `X.Y.Z`); treat “次版本/minor” as `Y`, and “主版本/major” as `X`.
2. Update every authoritative version file and the changelog on the designated development branch, then run the repository's complete release checks and build the distributable artifact.
3. Commit and push the release metadata, wait for required CI, promote the validated development branch to the release/default branch using the repository's required merge strategy, and push that branch.
4. From the release branch, dispatch the repository's GitHub Actions release workflow with `X.Y.Z`. The workflow is the sole publisher: it creates the immutable `vX.Y.Z` tag, a same-titled Release, and only matching version artifacts. Never create a version tag or Release locally or manually; if the workflow is unavailable, stop and report the blocker.
5. Wait for the workflow, then verify its conclusion, Release tag and title, artifact identity and version, and remote branch/tag alignment. Establish asset identity by matching Release metadata digests to locally inspected deterministic artifacts; download only when metadata cannot settle it. Existing versions are immutable: a rerun must not move the tag or replace an asset with different bytes.
