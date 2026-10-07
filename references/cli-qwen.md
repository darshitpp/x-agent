# Qwen Code CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `qwen`
- **Non-interactive flag:** positional prompt (one-shot by default; `-i` for interactive). `-p` / `--prompt` still works but is deprecated
- **Auto-approve flag:** `--yolo` (or `--approval-mode plan|default|auto-edit|auto|yolo`)
- **Output format flag:** `--output-format text|json|stream-json`
- **Model flag:** `--model`
- **List models command:** None documented. Model is specified with `--model`.
- **Budget flags:** `--max-wall-time <e.g. 10m>`, `--max-tool-calls <n>`

## 2. Model Selection Heuristic

- **Default model (fallback):** `qwen3-coder-plus`
- **Aliases:** None — use full model IDs
- **Quirks:** Qwen Code is optimized for Qwen model family. May support other providers via BYOK configuration. The `--yolo` flag is the primary auto-approve mechanism (equivalent to `--trust` in Cursor or `--full-auto` in Codex).

## 3. Invocation Template

| Mode           | Command                                                    |
|----------------|------------------------------------------------------------|
| **Validation** | `qwen "$(cat "$PROMPT_FILE")" --model <model>`            |
| **Delegation** | `qwen "$(cat "$PROMPT_FILE")" --model <model> --yolo`     |

Note: `--yolo` enables auto-approve for delegation. Validation runs without it (read-only perspective). The prompt is passed as the positional argument (one-shot); stdin, if piped, is appended. Qwen Code does not expose an internal `--timeout` flag; enforce the 120-second limit per `references/shared-procedure.md` Step 6 (kill the process if it does not exit).

## 4. Version Compatibility Matrix

| Version   | Model Flag  | Yolo Flag | Output Format           | Notes        |
|-----------|-------------|-----------|-------------------------|--------------|
| 0.25.x | `--model`   | `--yolo`  | `--output-format text\|json\|stream-json` | positional prompt; `-p` deprecated |
