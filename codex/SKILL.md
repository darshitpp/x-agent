---
name: codex
description: Delegate tasks or get a second opinion from OpenAI Codex CLI.
  Infers mode (delegation vs validation) from prompt context. Detects
  available models at runtime via the CLI. Use when cross-validating code,
  plans, or architecture with Codex CLI, or offloading work to it.
  Do not use for tasks that do not benefit from cross-model input.
---

# Cross-Agent Task Runner — OpenAI Codex CLI

## Procedures

**Step 1: Execute Shared Procedure**

1. Read `references/shared-procedure.md` for the core workflow
   (mode inference, context gathering, prompt construction, result presentation).
2. Read `references/cli-codex.md` for Codex-specific flags, model selection
   heuristics, and version compatibility matrix.
3. Follow the shared procedure using the Codex-specific details.
