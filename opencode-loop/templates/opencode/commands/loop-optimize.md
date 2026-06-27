<!-- Managed by oc-plugins/opencode-loop -->
---
description: Run a metric-driven optimization loop
agent: loop-builder
---

Start or continue a metric-driven software optimization loop.

Optimization task:

$ARGUMENTS

Protocol:

1. Load the `software-loop-contract` skill.
2. Read `.ocloop/current.json` if it exists.
3. If no active optimization loop exists, create a new run under `.ocloop/runs/` and initialize `state.json` with:
   - `loop_type`: `optimize`
   - `phase`: `INTAKE`
   - `status`: `running`
   - `attempt`: `1`
   - `max_attempts`: `8`
   - `done`: `false`
4. Follow this state machine exactly:
   `INTAKE -> BASELINE -> HYPOTHESIS -> PATCH -> MEASURE -> COMPARE -> REVIEW -> ACCEPT -> DONE`.
5. Establish and record the baseline before changing code.
6. Use one hypothesis per attempt.
7. Make one coherent change per attempt.
8. Run the benchmark or eval command after each candidate.
9. Record metrics in `metrics.json` and summarize them in `evidence.md`.
10. Accept only if the configured metric threshold is met, no unacceptable regression is introduced, health check passes, and review has no unresolved must-fix item.
