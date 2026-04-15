# Claude Code CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `claude`
- **Non-interactive flag:** `-p` / `--print`
- **Output format flag:** `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `--dangerously-skip-permissions`
- **List models command:** `claude --list-models 2>&1` (if available) or infer from `claude --help`
- **Self-call detection:** Check for `CLAUDE_CODE` environment variable or `claude` in process ancestry

## 2. Model Selection Heuristic

- **Default model (fallback):** `sonnet` (alias for claude-sonnet-4-6)
- **Aliases:** `opus` → claude-opus-4-6, `sonnet` → claude-sonnet-4-6, `haiku` → claude-haiku-4-5
- **Quirks:** Model can also be set via `ANTHROPIC_MODEL` env var. Supports `--fallback-model` for overload scenarios.

## 3. Invocation Template

| Mode           | Command                                                                |
|----------------|------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| claude -p --model <model> --output-format text` |
| **Delegation** | `cat "$PROMPT_FILE" \| claude -p --model <model> --output-format text` |

Note: Claude Code validation and delegation use the same invocation — no separate trust flag needed for print mode.

## 4. Version Compatibility Matrix

| Version | Print Flag       | Model Flag | Output Format                             | Notes   |
|---------|------------------|------------|-------------------------------------------|---------|
| 2.1.x   | `-p` / `--print` | `--model`  | `--output-format text\|json\|stream-json` | Current |
