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

- Prefer cohesive functions, shallow control flow, explicit names, and comments about intent or trade-offs.
- Introduce an abstraction only for a demonstrated seam; keep business logic independent from concrete infrastructure when that seam exists.
- Match repository conventions and avoid hidden mutation.

## Plan and Verify

For non-trivial work, state the cause, affected area, local-versus-structural choice, approach, and validation. Proceed directly for trivial edits.

- Run repository-required checks.
- Use optional checks only to settle a live uncertainty or identify an affected consumer.
- Review the diff for symptom patches, duplication, hidden fallbacks, second sources of truth, obsolete code created by the change, unrequested behavior, weak evidence, and security regressions.
- Stop when success criteria are met with sufficient evidence.
