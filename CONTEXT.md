# Agent Instruction Repository

This repository defines the global behavioral contract shared by supported coding agents while keeping task-specific guidance out of their always-loaded context.

## Language

**Global invariant**:
A behavioral rule that must govern every task and therefore belongs in the always-loaded global instruction file.
_Avoid_: Global preference, default tip

**Conditional rule**:
A rule loaded only for the task branch named by its context pointer.
_Avoid_: Optional rule, secondary rule

**Context pointer**:
A compact instruction that names a conditional rule and the exact branch that requires it.
_Avoid_: Link, reference

**Live uncertainty**:
A currently unresolved fact whose answer can change the next action; it justifies proportional investigation or verification.
_Avoid_: Possible concern, theoretical risk

**Scope discipline**:
The boundary that keeps a proposed remedy proportional without suppressing investigation or reporting of real, reachable defects.
_Avoid_: Minimalism, ignore edge cases
