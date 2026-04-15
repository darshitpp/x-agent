# Qwen Code CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `qwen`
- **Non-interactive flag:** `--yolo` (auto-approves all actions)
- **Output format flag:** `--output-format text|json` (confirm via `qwen --help`)
- **Model flag:** `--model`
- **List models command:** `qwen --list-models` (confirm availability; assume unavailable initially)
- **Self-call detection:** Check for `QWEN_SESSION` or `QWEN_CODE` environment variable, or `qwen` in process ancestry

## 2. Model Selection Heuristic

- **Default model (fallback):** Qwen's default model (confirm via `qwen --help`)
- **Aliases:** None — use full model IDs
- **Quirks:** Qwen Code is optimized for Qwen model family. May support other providers via BYOK configuration. The `--yolo` flag is the primary auto-approve mechanism (equivalent to `--trust` in Cursor or `--full-auto` in Codex).

## 3. Invocation Template

| Mode           | Command                                                    |
|----------------|------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| qwen --model <model>`               |
| **Delegation** | `cat "$PROMPT_FILE" \| qwen --model <model> --yolo`        |

Note: `--yolo` enables auto-approve for delegation. Validation runs without it (read-only perspective). Prompt is piped via stdin. Qwen Code does not expose an internal `--timeout` flag; the external process kill wrapper in `query-cli.sh` enforces the 120s limit.

## 4. Version Compatibility Matrix

| Version   | Model Flag  | Yolo Flag | Output Format           | Notes        |
|-----------|-------------|-----------|-------------------------|--------------|
| (pending) | `--model`   | `--yolo`  | `--output-format` (TBD) | Initial entry |
