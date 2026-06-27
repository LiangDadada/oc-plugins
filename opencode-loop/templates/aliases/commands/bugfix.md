<!-- Managed by oc-plugins/opencode-loop -->
---
description: Alias for /loop-bugfix
agent: loop-builder
---

Run the same protocol as `/loop-bugfix` for this task:

$ARGUMENTS

Load the `software-loop-contract` skill, create or continue a bugfix loop, follow `INTAKE -> REPRODUCE -> DIAGNOSE -> PATCH -> VERIFY -> REVIEW -> ACCEPT -> DONE`, record required evidence, and do not mark `DONE` until `loop-acceptor` confirms acceptance.
