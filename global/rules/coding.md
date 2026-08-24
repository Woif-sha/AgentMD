# Coding Work

## Diagnose

- Establish the failing behavior from code, logs, tests, or runtime evidence before editing.
- Trace the cause from first principles. Prefer removing redundant configuration, branches, and gates over adding bypasses.
- Keep failures observable; do not add mock success, hidden fallbacks, broad exception handling, or silent defaults.

## Structural Work

Treat duplicated logic, multiple sources of truth, shared validation or permissions, contracts, schemas, migrations, cross-module state, repeated failures, and security or data-integrity boundaries as structural.

- Name the invariant.
- Express it once in the authoritative layer.
- Remove superseded logic instead of creating a parallel path.
- Reject a local patch when it preserves inconsistency or debt.

## Code Shape

- Name symbols for domain intent, units, and state; use the project's vocabulary consistently.
- Keep functions cohesive, control flow shallow, side effects explicit, and each passage at one abstraction level. Judge size by local reasoning cost, not fixed line, parameter, or class counts.
- Use comments for invariants, external constraints, compatibility reasons, security decisions, and non-obvious trade-offs; keep mechanics in the code and comments current.
- Introduce an abstraction only for a demonstrated seam; keep business logic independent from concrete infrastructure when that seam exists.
- Before implementing common functionality or adding a package, inspect the capabilities, documentation, and types of dependencies already used by the project. Reuse a maintained dependency when it reduces total complexity. Add a narrower third-party boundary only when it constrains capability, stabilizes domain semantics, or translates failures; settle uncertain behavior with a minimal learning or contract test.
- Match repository conventions and avoid hidden mutation.

## Tests and Refactoring

- Keep tests readable, deterministic, independent, and focused on observable behavior. Group assertions by one behavior and failure reason instead of enforcing an assertion count.
- Before behavior-preserving refactoring where current behavior is unclear or uncovered, capture it with focused characterization tests. Make one explainable transformation at a time and run the relevant checks after each step.

## Concurrent Code

- In concurrent code, minimize shared mutable state, name its owner, use maintained concurrency primitives, and define cancellation, shutdown, timeout, and failure behavior.

## Plan and Verify

For non-trivial work, state the cause, affected area, local-versus-structural choice, approach, and validation. Proceed directly for trivial edits.

- For multi-step builds, establish the smallest working end-to-end slice, then add capabilities without breaking it.
- Run repository-required checks.
- Use optional checks only to settle a live uncertainty or identify an affected consumer.
- Review the diff for symptom patches, duplication, hidden fallbacks, second sources of truth, obsolete code created by the change, unrequested behavior, weak evidence, and security regressions.
- Stop when success criteria are met with sufficient evidence.
