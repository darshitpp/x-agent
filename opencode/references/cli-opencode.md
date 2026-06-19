# OpenCode CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `opencode`
- **Non-interactive subcommand:** `opencode run` (auto-approves tool use in non-interactive mode)
- **Output format flag:** `--format default|json` (`default` outputs formatted text to stdout; ANSI/session header goes to stderr, `json` outputs raw JSON events)
- **Model flag:** `-m` / `--model` (format: `provider/model`, e.g. `anthropic/claude-sonnet-4`, `openai/gpt-4o`)
- **List models command:** `opencode models` (requires configured provider credentials)
- **Self-call detection:** Check for `OPENCODE` environment variable (set to `1` inside OpenCode sessions), or `opencode` in process ancestry

## 2. Model Selection Heuristic

- **Default model (fallback):** OpenCode's default model (confirm via `opencode models`)
- **Aliases:** None — use full `provider/model` IDs
- **Quirks:** OpenCode is multi-provider (OpenAI, Anthropic, Google, AWS Bedrock, Groq, Azure, OpenRouter). Model IDs use `provider/model` format. The `run` subcommand auto-approves all tool use in non-interactive mode. The `--format default` output sends ANSI codes and session header to stderr; stdout is clean text. The `--format json` option outputs raw JSON events for programmatic consumption.

## 3. Invocation Template

| Mode           | Command                                                                       |
|----------------|-------------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format json 2>/dev/null`     |
| **Delegation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format default 2>/dev/null`  |

Note: Validation mode uses `--format json` to get structured output for parsing, while Delegation mode uses `--format default` for human-readable output. Both modes use the `run` subcommand because OpenCode auto-approves all actions in non-interactive mode. Prompt is piped via stdin. OpenCode does not expose an internal `--timeout` flag; enforce the 120-second limit per `references/shared-procedure.md` Step 6 (kill the process if it does not exit). Stderr is suppressed (`2>/dev/null`) to remove ANSI codes and session header from output.

## 4. Version Compatibility Matrix

| Version | Model Flag         | Run Subcommand | Format Flag              | Notes                          |
|---------|--------------------|----------------|--------------------------|--------------------------------|
| 1.3.10  | `-m` / `--model`   | `run`          | `--format default\|json` | Verified; stdin piping works   |
| 1.17.8  | `-m` / `--model`   | `run`          | `--format default\|json` | Current version; full feature set available |
