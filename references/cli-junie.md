# Junie CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `junie`
- **Non-interactive flag:** Any invocation with a task argument (or `--task=<text>`) is non-interactive by default. Note `-p` means `--project`, not print
- **Output format flag:** `--output-format text|json|json-stream` (`--json-output-file <path>` writes JSON to a file); `--input-format text|json`
- **Trust/auto-approve flag:** None (non-interactive mode auto-approves)
- **List models command:** Not directly available. Model is specified with `--model`.

## 2. Model Selection Heuristic

- **Default model (fallback):** Use Junie's default (dynamic best price/quality, no explicit model flag)
- **Aliases:** None — use full model IDs (e.g., `anthropic-claude-3.5-sonnet`)
- **Quirks:** LLM-agnostic with BYOK support. Accepts provider-prefixed model IDs. Supports `--provider openai|anthropic|google|xai|openrouter|copilot` and `--openai-api-key`,
  `--anthropic-api-key`, `--google-api-key`, `--grok-api-key`, `--openrouter-api-key` for BYOK.

## 3. Invocation Template

| Mode           | Command                                                            |
|----------------|--------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| junie --model <model> --output-format text --skip-update-check` |
| **Delegation** | `cat "$PROMPT_FILE" \| junie --model <model> --output-format text --skip-update-check` |

Note: Junie reads task from stdin when no positional argument is provided. `--skip-update-check` stops the self-updater running mid-invocation. Add `--timeout 120000` for the 120s execution
timeout (Junie uses milliseconds).

## 4. Version Compatibility Matrix

| Version | Model Flag | Output Format                | Timeout Flag                | Notes   |
|---------|------------|------------------------------|-----------------------------|---------|
| 1417.x  | `--model`  | `--output-format text\|json` | `-t` / `--timeout` (millis) | Current |
