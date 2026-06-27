<!-- Managed by oc-plugins/opencode-loop -->
---
description: Start or continue a bounded TDD loop
agent: loop-builder
---

Start or continue a software TDD loop.

User task:

$ARGUMENTS

Protocol:

1. Load the `software-loop-contract` skill.
2. Read `.ocloop/current.json` if it exists.
3. If no active TDD loop exists, create a new run under `.ocloop/runs/` and initialize `state.json` with:
   - `loop_type`: `tdd`
   - `phase`: `INTAKE`
   - `status`: `running`
   - `attempt`: `1`
   - `max_attempts`: `5`
   - `done`: `false`
4. Follow this state machine exactly:
   `INTAKE -> SPEC -> RED -> GREEN -> REFACTOR -> REVIEW -> ACCEPT -> DONE`.
5. Record spec evidence before editing production code.
6. Record red phase evidence before implementation.
7. Record green phase evidence after implementation.
8. Do not add or keep `skip`, `only`, or `todo` markers to make tests pass.
9. Use `loop-reviewer` before acceptance and `loop-acceptor` for the final gate.
10. Do not mark `DONE` unless TDD acceptance passes.
