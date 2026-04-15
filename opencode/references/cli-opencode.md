# OpenCode CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `opencode`
- **Non-interactive subcommand:** `opencode run` (auto-approves tool use in non-interactive mode)
- **Output format flag:** `--format default|json` (`default` outputs plain text to stdout; ANSI/session header goes to stderr)
- **Model flag:** `-m` / `--model` (format: `provider/model`, e.g. `opencode/big-model-name`, `anthropic/claude-sonnet-4-6`)
- **List models command:** `opencode models` (requires configured provider credentials)
- **Self-call detection:** Check for `OPENCODE` environment variable (set to `1` inside OpenCode sessions), or `opencode` in process ancestry

## 2. Model Selection Heuristic

- **Default model (fallback):** OpenCode's default model (confirm via `opencode models`)
- **Aliases:** None — use full `provider/model` IDs
- **Quirks:** OpenCode is multi-provider (OpenAI, Anthropic, Google, AWS Bedrock, Groq, Azure, OpenRouter). Model IDs use `provider/model` format. The `run` subcommand auto-approves all tool use in non-interactive mode — there is no separate `--yolo` or `--trust` flag. The `--format default` output sends ANSI codes and session header to stderr; stdout is clean text.

## 3. Invocation Template

| Mode           | Command                                                                       |
|----------------|-------------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format default 2>/dev/null`  |
| **Delegation** | `cat "$PROMPT_FILE" \| opencode run -m <model> --format default 2>/dev/null`  |

Note: Both modes use the same command because OpenCode auto-approves all actions in non-interactive `run` mode. Prompt is piped via stdin. OpenCode does not expose an internal `--timeout` flag; the external process kill wrapper in `query-cli.sh` enforces the 120s limit. Stderr is suppressed (`2>/dev/null`) to remove ANSI codes and session header from output.

## 4. Version Compatibility Matrix

| Version | Model Flag         | Run Subcommand | Format Flag              | Notes                          |
|---------|--------------------|----------------|--------------------------|--------------------------------|
| 1.3.10  | `-m` / `--model`   | `run`          | `--format default\|json` | Verified; stdin piping works   |
