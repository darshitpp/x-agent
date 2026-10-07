# Cursor Agent CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `agent`
- **Non-interactive flag:** `-p` / `--print`
- **Output format flag:** `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `--trust` (trust workspace, headless only), `--force` / `--yolo` (apply file changes and run commands without confirmation; without it print mode only proposes changes)
- **Other:** `--auto-review` (server classifier auto-runs safe tool calls, prompts for the rest)
- **Read-only mode:** `--mode ask` (Q&A, no edits) or `--mode plan`; plain `-p` has access to all tools incl. write and shell
- **List models command:** `agent --list-models 2>&1`

## 2. Model Selection Heuristic

- **Default model (fallback):** `composer-2-fast`
- **Aliases:** None — use full model IDs
- **Quirks:** Model list includes ANSI escape codes in output; strip control characters before parsing. Models from
  multiple providers (OpenAI, Anthropic, Google, xAI, Moonshot) are available.

## 3. Invocation Template

Safe prompt transport — write prompt to temp file, pipe via stdin:

| Mode           | Command                                                  |
|----------------|----------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| agent -p --model <model> --mode ask` |
| **Delegation** | `cat "$PROMPT_FILE" \| agent -p --model <model> --trust --force` |

Note: in print mode, file changes are only proposed unless `--force` / `--yolo` is set, so Delegation passes `--trust --force`. Validation uses `--mode ask` so the run stays read-only.

## 4. Version Compatibility Matrix

| Version   | List Models     | Print Flag       | Model Flag | Trust Flag                       | Notes   |
|-----------|-----------------|------------------|------------|----------------------------------|---------|
| 2026.08.x | `--list-models` | `-p` / `--print` | `--model`  | `--trust` / `--force` / `--yolo` | Current; `--mode ask\|plan` is read-only |
