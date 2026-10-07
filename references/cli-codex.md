# OpenAI Codex CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `codex`
- **Non-interactive subcommand:** `codex exec` (alias: `codex e`)
- **Stdin prompt:** Pass `-` as the prompt argument to read from stdin
- **Output format:** `--json` for newline-delimited JSON events, or `-o` / `--output-last-message <path>` to write final
  response to file
- **Outside a git repo:** add `--skip-git-repo-check`
- **Trust/auto-approve flag:** `--sandbox workspace-write` (`--full-auto` is deprecated and absent from `codex exec` as of 0.160), or
  `--dangerously-bypass-approvals-and-sandbox` for full bypass; `--approve-for-me` routes approvals to automatic review
- **Model flag:** `-m` / `--model`
- **List models command:** Not available — no `--list-models` flag. Available models must be maintained in the version
  matrix.
- **Sandbox modes:** `--sandbox read-only|workspace-write|danger-full-access` (`-s`)

## 2. Model Selection Heuristic

- **Default model (fallback):** `o4-mini` (OpenAI's default for Codex CLI)
- **Aliases:** None — use full model IDs
- **Quirks:** Codex CLI is tightly coupled to OpenAI models. Does not expose models from other providers. No
  `--list-models` flag — fall back to default model always. Supports `--oss` flag for local Ollama models.

## 3. Invocation Template

| Mode           | Command                                                                 |
|----------------|-------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| codex exec -m <model> --ephemeral -`             |
| **Delegation** | `cat "$PROMPT_FILE" \| codex exec -m <model> --sandbox workspace-write --ephemeral -` |

Note: `codex exec` is the non-interactive subcommand. `-` reads prompt from stdin. `--sandbox workspace-write` allows file edits inside the workspace. Add `--ephemeral` to skip session persistence for one-off queries.

## 4. Version Compatibility Matrix

| Version                                            | Exec Subcommand | Model Flag       | Write Access                    | Stdin | Notes                          |
|----------------------------------------------------|-----------------|------------------|---------------------------------|-------|--------------------------------|
| 0.160.x (verified via `codex exec --help`)          | `codex exec`    | `-m` / `--model` | `--sandbox workspace-write`     | `-`   | `--full-auto` removed from `exec`  |
