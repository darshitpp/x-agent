# OpenAI Codex CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `codex`
- **Non-interactive subcommand:** `codex exec` (alias: `codex e`)
- **Stdin prompt:** Pass `-` as the prompt argument to read from stdin
- **Output format:** `--json` for newline-delimited JSON events, or `--output-last-message <path>` to write final
  response to file
- **Trust/auto-approve flag:** `--full-auto` (sets approvals to `on-request` + sandbox to `workspace-write`), or
  `--dangerously-bypass-approvals-and-sandbox` / `--yolo` for full bypass
- **Model flag:** `-m` / `--model`
- **List models command:** Not available — no `--list-models` flag. Available models must be maintained in the version
  matrix.
- **Self-call detection:** Check for `codex` in process ancestry (no dedicated env var)
- **Sandbox modes:** `--sandbox read-only|workspace-write|danger-full-access` (`-s`)
- **Approval modes:** `--ask-for-approval untrusted|on-request|never` (`-a`)

## 2. Model Selection Heuristic

- **Default model (fallback):** `o4-mini` (OpenAI's default for Codex CLI)
- **Aliases:** None — use full model IDs
- **Quirks:** Codex CLI is tightly coupled to OpenAI models. Does not expose models from other providers. No
  `--list-models` flag — fall back to default model always. Supports `--oss` flag for local Ollama models.

## 3. Invocation Template

| Mode           | Command                                                                 |
|----------------|-------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| codex exec -m <model> --ephemeral -`             |
| **Delegation** | `cat "$PROMPT_FILE" \| codex exec -m <model> --full-auto --ephemeral -` |

Note: `codex exec` is the non-interactive subcommand. `-` reads prompt from stdin. `--full-auto` enables autonomous
execution. Add `--ephemeral` to skip session persistence for one-off queries.

## 4. Version Compatibility Matrix

| Version                                                  | Exec Subcommand | Model Flag       | Full-Auto Flag | Stdin | Notes   |
|----------------------------------------------------------|-----------------|------------------|----------------|-------|---------|
| (pending — populate from first snapshot or npm registry) | `codex exec`    | `-m` / `--model` | `--full-auto`  | `-`   | Current |
