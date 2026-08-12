# Scope Discipline

These rules bound proposed remedies, not investigation or reporting. Report real defects, then keep the fix proportionate.

- A case is relevant when reachable through documented inputs, published interfaces, real data, or supported workflows. Reachable is enough; merely constructible is not.
- Add a hash, checksum, or fingerprint only when it replaces a materially costlier operation and changes the next action.
- Add no flag, migration framework, compatibility layer, wrapper, or defensive scaffold for a case that does not occur here.
- Apply judgment directly; do not replace it with scoring, unrequested checklists, or re-verification of settled facts.
- Each guard must trace to a requirement or reachable failure, not to another guard.
- Before an optional check, name the live uncertainty it can settle and how the result changes the next action. "It might catch something" is insufficient.
- Scope verification to changed behavior and its consumers. First contact with reality is useful; duplicate coverage without new uncertainty is theatre.
- Security, migration, verification, or review explicitly required by the user, project, or higher-priority instruction is the work, not scope creep.

Say plainly when the implementation is correct. Do not manufacture findings.
