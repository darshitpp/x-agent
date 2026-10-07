# Antigravity CLI (agy) Reference

Successor to Gemini CLI (consumer/free tiers retired 2026-06-18). Go binary.

## 1. CLI Identity & Invocation

- **Command:** `agy`
- **Non-interactive flag:** `-p` / `--print` / `--prompt`
- **Output format flag:** `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `--dangerously-skip-permissions` (no `--yolo`; without it, tools needing approval are soft-denied)
- **List models command:** Not available via flag. Use `/model` in the TUI.

## 2. Model Selection Heuristic

- **Default model (fallback):** agy default (omit `--model`)
- **Aliases:** None — use full model slugs (e.g. `gemini-3.8-flash-medium`)
- **Quirks:** Unknown model slug exits non-zero. `--print-timeout` (default `5m`) caps wait. `--effort low|medium|high` sets reasoning.

## 3. Invocation Template

| Mode           | Command                                                                              |
|----------------|--------------------------------------------------------------------------------------|
| **Validation** | `agy -p "$(cat "$PROMPT_FILE")" --model <model> --output-format text`                |
| **Delegation** | `agy -p "$(cat "$PROMPT_FILE")" --model <model> --output-format text --dangerously-skip-permissions` |

Note: `-p` takes the prompt as an argument; piped stdin is not supported for text input (only `--input-format stream-json` with `--output-format stream-json`). Tools needing approval are soft-denied (exit 0) without the skip flag.

## 4. Version Compatibility Matrix

| Version | Print Flag | Model Flag | Output Format     | Auto-approve                     | Notes   |
|---------|------------|------------|-------------------|----------------------------------|---------|
| 1.1.x   | `-p`       | `--model`  | `--output-format` | `--dangerously-skip-permissions` | Current |
