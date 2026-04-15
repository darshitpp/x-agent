# Junie CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `junie`
- **Non-interactive flag:** Any invocation with a task argument is non-interactive by default
- **Output format flag:** `--output-format text|json`
- **Trust/auto-approve flag:** None (non-interactive mode auto-approves)
- **List models command:** Not directly available. Model is specified with `--model`.
- **Self-call detection:** Check for `JUNIE_SESSION` or JetBrains-specific environment markers

## 2. Model Selection Heuristic

- **Default model (fallback):** Use Junie's default (dynamic best price/quality, no explicit model flag)
- **Aliases:** None — use full model IDs (e.g., `anthropic-claude-3.5-sonnet`)
- **Quirks:** LLM-agnostic with BYOK support. Accepts provider-prefixed model IDs. Supports `--openai-api-key`,
  `--anthropic-api-key`, `--google-api-key`, `--grok-api-key`, `--openrouter-api-key` for BYOK.

## 3. Invocation Template

| Mode           | Command                                                            |
|----------------|--------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| junie --model <model> --output-format text` |
| **Delegation** | `cat "$PROMPT_FILE" \| junie --model <model> --output-format text` |

Note: Junie reads task from stdin when no positional argument is provided. Add `--timeout 120000` for the 120s execution
timeout (Junie uses milliseconds).

## 4. Version Compatibility Matrix

| Version | Model Flag | Output Format                | Timeout Flag                | Notes   |
|---------|------------|------------------------------|-----------------------------|---------|
| 888.x   | `--model`  | `--output-format text\|json` | `-t` / `--timeout` (millis) | Current |
