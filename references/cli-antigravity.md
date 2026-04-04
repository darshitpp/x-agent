# Antigravity CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `antigravity`
- **Non-interactive subcommand:** `antigravity chat`
- **Output format flag:** Confirm via `antigravity chat --help` (likely `--output-format text|json`)
- **Model flag:** `--model` (confirm via `antigravity chat --help`)
- **List models command:** Not expected to be available — assume unavailable initially
- **Self-call detection:** Check for `ANTIGRAVITY_SESSION` environment variable or `antigravity` in process ancestry

## 2. Model Selection Heuristic

- **Default model (fallback):** Antigravity's default model for `chat` subcommand (confirm via `antigravity chat --help`)
- **Aliases:** None — use full model IDs
- **Quirks:** Antigravity delegates to the `chat` subcommand for non-interactive use. Input parsing via stdin may need testing — if `.stdin` proves flaky, the prompt may need to be passed as a file argument instead. Auto-approve behavior is subcommand-dependent.

## 3. Invocation Template

| Mode           | Command                                                                |
|----------------|------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| antigravity chat --model <model>`               |
| **Delegation** | `cat "$PROMPT_FILE" \| antigravity chat --model <model> --yolo`        |

Note: `antigravity chat` is the non-interactive subcommand. Prompt is piped via stdin. `--yolo` flag for auto-approve in delegation mode (confirm flag name via `antigravity chat --help`; if different, update accordingly). Antigravity CLI does not expose an internal `--timeout` flag; the external process kill wrapper in `query-cli.sh` enforces the 120s limit.

## 4. Version Compatibility Matrix

| Version   | Chat Subcommand | Model Flag  | Yolo Flag     | Output Format           | Notes         |
|-----------|-----------------|-------------|---------------|-------------------------|---------------|
| (pending) | `chat`          | `--model`   | `--yolo` (TBD)| `--output-format` (TBD) | Initial entry |
