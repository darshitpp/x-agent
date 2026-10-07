# Claude Code CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `claude`
- **Non-interactive flag:** `-p` / `--print`
- **Output format flag:** `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `--dangerously-skip-permissions`
- **List models command:** None (`--list-models` is not a flag). Use aliases or full model names; see `claude --help`
- **Related flags:** `--permission-mode acceptEdits|auto|bypassPermissions|manual|dontAsk|plan`, `--no-session-persistence`, `--max-budget-usd`

## 2. Model Selection Heuristic

- **Default model (fallback):** `sonnet` (alias for the latest Sonnet)
- **Aliases:** `opus`, `sonnet`, `haiku`, `fable` — each resolves to the latest model of that family
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
| 2.1.x (2.1.292 verified) | `-p` / `--print` | `--model`  | `--output-format text\|json\|stream-json` | Current |
