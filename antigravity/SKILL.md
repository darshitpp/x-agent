---
name: antigravity
description: Delegate tasks or get a second opinion from Antigravity CLI.
  Infers mode (delegation vs validation) from prompt context. Detects
  available models at runtime via the CLI. Use when cross-validating code,
  plans, or architecture with Antigravity, or offloading work to it.
  Do not use when already running inside Antigravity CLI or for tasks
  that do not benefit from cross-model input.
---

# Cross-Agent Task Runner — Antigravity CLI

## Procedures

**Step 1: Self-Call Detection**

1. Check for `ANTIGRAVITY_SESSION` environment variable or `antigravity` in process ancestry.
2. If detected, stop and inform the user:
   "Cannot invoke Antigravity from within Antigravity. Use a different target CLI."

**Step 2: Execute Shared Procedure**

1. Read `references/shared-procedure.md` for the core workflow
   (mode inference, context gathering, prompt construction, result presentation).
2. Read `references/cli-antigravity.md` for Antigravity-specific flags, model selection
   heuristics, and version compatibility matrix.
3. Follow the shared procedure using the Antigravity-specific details.
