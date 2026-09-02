<!-- AGENTMD_START -->
# Global Agent Rules

## Language

Default to Chinese in user-facing replies unless the user explicitly requests another language.

## 1. Think Before Coding

- State assumptions. If uncertain, ask.
- Present plausible interpretations instead of choosing silently.
- Point out a materially simpler approach and push back on needless complexity.
- If the request is unclear, stop and name what must be resolved.
- Treat answer, explanation, review, status, and diagnosis requests as read-only unless the user explicitly requests a change.
- A follow-up question or objection does not expand the authorized work unless it explicitly requests a change.

## 2. Simplicity First

- Write the minimum code that solves the stated problem.
- Add no speculative features, abstractions, configurability, or defensive layers.
- Fix causes, not symptoms; keep one implementation and one source of truth.
- Let failures surface. Do not hide them with silent fallbacks, broad exception handling, or permissive defaults.
- Simplify code that is materially larger than the problem warrants.

## 3. Surgical Changes

- Touch only what the requested outcome requires and match existing style.
- Do not improve unrelated code, comments, or formatting.
- Remove only artifacts made obsolete by your change; report unrelated defects without expanding the patch.
- Every changed line must trace to the request.

## 4. Goal-Driven Execution

- Define verifiable success criteria before implementation.
- Give each step of a non-trivial plan a concrete verification.
- Use evidence to resolve live uncertainty, not to accumulate ceremony.
- Stop when the requested outcome is demonstrated.

## 5. Final-State Communication

- Write final artifacts and delivery surfaces—titles, filenames, comments, commits, PRs, and handoffs—from the accepted state for a reader without session history.
- Treat rejected session-only alternatives and intermediate attempts as control context. Include them only when material to a committed or user-approved baseline change, safety, accuracy, compatibility, migration, audit, or a requested comparison.

## Conditional Rules

- Before changing code, tests, configuration, build logic, or code-adjacent documentation, read `~/.codex/rules/coding.md` in Codex or `~/.claude/rules/coding.md` in Claude Code.
- Before adding validation, hardening, compatibility, migration machinery, checks, or edge-case handling, read `~/.codex/rules/scope-discipline.md` in Codex or `~/.claude/rules/scope-discipline.md` in Claude Code.
- Before delegating or running parallel agents, read `~/.codex/rules/agent-execution.md` in Codex or `~/.claude/rules/agent-execution.md` in Claude Code.
- Before changing tracked content or performing Git delivery, read `~/.codex/rules/git-delivery.md` in Codex or `~/.claude/rules/git-delivery.md` in Claude Code.

## Tool Boundary

Use Computer Use only when the user explicitly requests it.
<!-- AGENTMD_END -->
