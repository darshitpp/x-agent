# OpenCode CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `opencode`
- **Non-interactive subcommand:** `opencode run`
- **Trust/auto-approve flag:** `--auto` (auto-approve permissions not explicitly denied; dangerous)
- **Output format flag:** `--format default|json` (`default` outputs formatted text to stdout; ANSI/session header goes to stderr, `json` outputs raw JSON events)
- **Model flag:** `-m` / `--model` (format: `provider/model`, e.g. `anthropic/claude-sonnet-4`, `openai/gpt-4o`)
- **List models command:** `opencode models` (requires configured provider credentials)

## 2. Model Selection Heuristic

- **Default model (fallback):** OpenCode's default model (confirm via `opencode models`)
- **Aliases:** None — use full `provider/model` IDs
- **Quirks:** OpenCode is multi-provider (OpenAI, Anthropic, Google, AWS Bedrock, Groq, Azure, OpenRouter). Model IDs use `provider/model` format. Without `--auto`, `run` does not auto-approve permissions that are not already allowed. The `--format default` output sends ANSI codes and session header to stderr; stdout is clean text. The `--format json` option outputs raw JSON events for programmatic consumption.

## 3. Invocation Template

| Mode           | Command                                                                       |
|----------------|-------------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format default 2>/dev/null`        |
| **Delegation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format default --auto 2>/dev/null`  |

Note: Both modes use `--format default` for human-readable output (`--format json` gives raw JSON events). Only Delegation adds `--auto`, so Validation does not auto-approve permissions. Prompt is piped via stdin. OpenCode does not expose an internal `--timeout` flag; enforce the 120-second limit per `references/shared-procedure.md` Step 6 (kill the process if it does not exit). Stderr is suppressed (`2>/dev/null`) to remove ANSI codes and session header from output.

## 4. Version Compatibility Matrix

| Version | Model Flag         | Run Subcommand | Format Flag              | Notes                          |
|---------|--------------------|----------------|--------------------------|--------------------------------|
| 1.3.10  | `-m` / `--model`   | `run`          | `--format default\|json` | Verified; stdin piping works   |
| 1.17.8  | `-m` / `--model`   | `run`          | `--format default\|json` | Earlier; run auto-approved tool use |
| 1.18.x  | `-m` / `--model`   | `run`          | `--format default\|json` | Current (1.18.34 verified; 1.18.35 latest); adds `--auto` |
