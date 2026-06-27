<!-- Managed by oc-plugins/opencode-loop -->
---
description: Start or continue a bounded software loop
agent: loop-builder
---

Start or continue an opencode-native software loop for this task:

$ARGUMENTS

Protocol:

1. Load the `software-loop-contract` skill.
2. Read the project rules that opencode provides for this repository.
3. Read `.ocloop/current.json` if it exists.
4. If there is no active run, choose the smallest matching loop type: `bugfix`, `tdd`, `review`, or `optimize`.
5. Create a run directory under `.ocloop/runs/<timestamp>-<loop-type>-<short-slug>/` and set `.ocloop/current.json.active_run` to that path.
6. Initialize the run with `state.json`, `task.md`, `evidence.md`, `failures.md`, `decisions.md`, `handoff.md`, and `metrics.json` as applicable.
7. Follow the state machine from the loop contract. Do not skip phases.
8. Use the phase-specific agent boundary:
   - intake, reproduce, diagnose, spec, baseline, hypothesis: `loop-planner`
   - patch, green, refactor, verify, measure: `loop-builder`
   - review and risk classification: `loop-reviewer`
   - accept: `loop-acceptor`
9. Run focused checks before broad health checks.
10. Do not mark `DONE` unless loop-specific acceptance passes and `loop-acceptor` confirms it.
11. Update the run `handoff.md` before stopping.
