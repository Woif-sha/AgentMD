# Global Agent Rules

Guidelines for reducing common coding-agent mistakes. They favor deliberate, bounded work over speed; use judgment for trivial tasks.

## 1. Think Before Coding

- State assumptions. If uncertain, ask.
- Present plausible interpretations instead of choosing silently.
- Point out a materially simpler approach and push back on needless complexity.
- If the request is unclear, stop and name what must be resolved.

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

## Conditional Rules

- Before changing code, tests, configuration, build logic, or code-adjacent documentation, read [`rules/coding.md`](rules/coding.md).
- Before adding validation, hardening, compatibility, migration machinery, checks, or edge-case handling, read [`rules/scope-discipline.md`](rules/scope-discipline.md).
- Before delegating or running parallel agents, read [`rules/agent-execution.md`](rules/agent-execution.md).
- Before changing tracked content or performing Git delivery, read [`rules/git-delivery.md`](rules/git-delivery.md).

## Tool Boundary

Use Computer Use only when the user explicitly requests it.
