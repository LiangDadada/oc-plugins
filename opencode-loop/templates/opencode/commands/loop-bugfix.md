<!-- Managed by oc-plugins/opencode-loop -->
---
description: Start or continue a bounded bugfix loop
agent: loop-builder
---

Start or continue a software bugfix loop.

User task:

$ARGUMENTS

Protocol:

1. Load the `software-loop-contract` skill.
2. Read `.ocloop/current.json` if it exists.
3. If no active bugfix loop exists, create a new run under `.ocloop/runs/` and initialize `state.json` with:
   - `loop_type`: `bugfix`
   - `phase`: `INTAKE`
   - `status`: `running`
   - `attempt`: `1`
   - `max_attempts`: `5`
   - `done`: `false`
4. Follow this state machine exactly:
   `INTAKE -> REPRODUCE -> DIAGNOSE -> PATCH -> VERIFY -> REVIEW -> ACCEPT -> DONE`.
5. Required evidence:
   - reproduction or documented non-reproducibility
   - root cause
   - focused check result
   - health check result
   - diff review result
6. Use `loop-planner` for reproduce/diagnose, `loop-builder` for patch/verify, `loop-reviewer` for review, and `loop-acceptor` for accept.
7. Do not weaken tests or assertions.
8. Do not mark `DONE` unless the original failure is fixed, focused and health checks pass, and there is no unresolved must-fix review item.
9. Update `handoff.md` before stopping.
