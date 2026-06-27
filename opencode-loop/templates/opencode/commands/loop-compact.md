<!-- Managed by oc-plugins/opencode-loop -->
---
description: Compact current software loop context
agent: loop-planner
---

Compact the current software loop context.

Protocol:

1. Load the `software-loop-contract` skill.
2. Read `.ocloop/current.json`.
3. Read the active run files:
   - `state.json`
   - `task.md`
   - `evidence.md`
   - `failures.md`
   - `decisions.md`
   - `metrics.json` if present
4. Inspect current status and diff summary.
5. Rewrite the active run `handoff.md`.
6. The handoff must include:
   - current task
   - current phase
   - confirmed facts
   - files touched
   - checks run
   - current failure, if any
   - decisions that must not be forgotten
   - forbidden directions
   - next smallest action
7. Keep `handoff.md` under 120 lines.
8. Do not modify source code.
