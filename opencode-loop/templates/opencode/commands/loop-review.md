<!-- Managed by oc-plugins/opencode-loop -->
---
description: Review the current diff using the software loop contract
agent: loop-reviewer
---

Start or continue a software review loop.

Review target:

$ARGUMENTS

Protocol:

1. Load the `software-loop-contract` skill.
2. Read `.ocloop/current.json` if it exists.
3. Inspect the current worktree status and diff.
4. If no active review loop exists, create a new run under `.ocloop/runs/` and initialize `state.json` with:
   - `loop_type`: `review`
   - `phase`: `INTAKE`
   - `status`: `running`
   - `attempt`: `1`
   - `max_attempts`: `3`
   - `done`: `false`
5. Follow this state machine exactly:
   `INTAKE -> DIFF_SCAN -> RISK_CLASSIFY -> RESOLUTION -> VERIFY -> ACCEPT -> DONE`.
6. Classify findings as:
   - `must-fix`
   - `should-fix`
   - `optional`
7. Cover correctness, security, performance, maintainability, and test coverage.
8. Write the review report and resolution status to the active run `evidence.md`.
9. If source code changes are made to resolve must-fix items, require `./scripts/health.sh` or the configured health check.
10. Do not mark `DONE` unless every must-fix item is fixed, deferred, or explicitly accepted as risk.
