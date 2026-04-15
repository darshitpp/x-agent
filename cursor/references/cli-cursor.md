# Cursor Agent CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `agent`
- **Non-interactive flag:** `-p` / `--print`
- **Output format flag:** `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `--trust`, `--force` / `--yolo`
- **List models command:** `agent --list-models 2>&1`
- **Self-call detection:** Check for `CURSOR_SESSION` or `CURSOR_TRACE_ID` environment variable

## 2. Model Selection Heuristic

- **Default model (fallback):** `composer-2-fast`
- **Aliases:** None — use full model IDs
- **Quirks:** Model list includes ANSI escape codes in output; strip control characters before parsing. Models from
  multiple providers (OpenAI, Anthropic, Google, xAI, Moonshot) are available.

## 3. Invocation Template

Safe prompt transport — write prompt to temp file, pipe via stdin:

| Mode           | Command                                                  |
|----------------|----------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| agent -p --model <model>`         |
| **Delegation** | `cat "$PROMPT_FILE" \| agent -p --model <model> --trust` |

Note: `--trust` enables auto-approve for delegation. Validation runs without it (read-only perspective).

## 4. Version Compatibility Matrix

| Version   | List Models     | Print Flag       | Model Flag | Trust Flag                       | Notes   |
|-----------|-----------------|------------------|------------|----------------------------------|---------|
| 2026.03.x | `--list-models` | `-p` / `--print` | `--model`  | `--trust` / `--force` / `--yolo` | Current |
