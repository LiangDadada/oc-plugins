<!-- Managed by oc-plugins/opencode-loop -->
---
name: software-loop-contract
description: Defines bounded software loop state machines, evidence files, and acceptance rules for bugfix, TDD, review, and optimization workflows.
compatibility: opencode
metadata:
  profile: software
  runtime: opencode-native
---

# Software Loop Contract

## Core rule

A loop is complete only when all conditions are true:

1. The active run reaches the `ACCEPT` phase.
2. Required evidence exists.
3. Loop-specific acceptance passes.
4. Health check passes.
5. Reviewer has no unresolved must-fix issue.
6. `handoff.md` is updated.

Health checks prove engineering health. They do not prove loop completion by themselves.

## State files

Each run lives under `.ocloop/runs/<run-id>/` and should contain:

- `state.json`
- `task.md`
- `evidence.md`
- `failures.md`
- `decisions.md`
- `handoff.md`
- `metrics.json` for optimization loops

`.ocloop/current.json` points at the active run.

## Required `state.json` shape

```json
{
  "loop_type": "bugfix",
  "phase": "INTAKE",
  "status": "running",
  "attempt": 1,
  "max_attempts": 5,
  "task": "short task description",
  "scope": {
    "allow": [],
    "deny": [".env*", "**/.env*", "**/migrations/**", "**/lock*", ".github/**"]
  },
  "checks": {
    "focused": "./scripts/focused.sh <pattern>",
    "health": "./scripts/health.sh",
    "full": "./scripts/full.sh"
  },
  "evidence": {},
  "last_failure": null,
  "done": false
}
```

## Common evidence rules

Evidence must include command, result, and the meaningful output or observation. Record failures in `failures.md` so the next attempt does not repeat the same wrong direction. Record durable design decisions in `decisions.md`.

## Bugfix loop

State machine:

```text
INTAKE -> REPRODUCE -> DIAGNOSE -> PATCH -> VERIFY -> REVIEW -> ACCEPT -> DONE
```

Required evidence:

- reproduction or documented non-reproducibility
- root cause
- focused pass
- health pass
- diff reviewed

Acceptance:

- original failure is reproduced or non-reproducibility is documented
- root cause is stated
- focused check passes
- health check passes
- tests were not weakened
- no unresolved must-fix review item remains

## TDD loop

State machine:

```text
INTAKE -> SPEC -> RED -> GREEN -> REFACTOR -> REVIEW -> ACCEPT -> DONE
```

Required evidence:

- spec
- red failure
- green pass
- health pass
- diff reviewed

Acceptance:

- test or spec changed before production implementation
- red failure is recorded
- green pass is recorded
- no `skip`, `only`, or `todo` marker was added to force a pass
- production change matches the spec
- health check passes
- no unresolved must-fix review item remains

## Review loop

State machine:

```text
INTAKE -> DIFF_SCAN -> RISK_CLASSIFY -> RESOLUTION -> VERIFY -> ACCEPT -> DONE
```

Required evidence:

- review report
- must-fix resolution
- health pass if source code changed

Acceptance:

- correctness reviewed
- security reviewed
- performance reviewed
- maintainability reviewed
- test coverage reviewed
- every must-fix item is fixed, deferred, or explicitly accepted as risk

## Optimize loop

State machine:

```text
INTAKE -> BASELINE -> HYPOTHESIS -> PATCH -> MEASURE -> COMPARE -> REVIEW -> ACCEPT -> DONE
```

Required evidence:

- baseline metric
- hypothesis
- candidate metric
- comparison
- health pass

Acceptance:

- baseline is recorded before modification
- candidate is measured after modification
- metric improvement meets the configured threshold
- no unacceptable regression is introduced
- health check passes
- no unresolved must-fix review item remains

## Compact rule

Before stopping or handing off, rewrite `handoff.md` with:

1. current task
2. current phase
3. confirmed facts
4. files touched
5. checks run
6. current failure, if any
7. decisions that must not be forgotten
8. forbidden directions
9. next smallest action

Keep it under 120 lines.
