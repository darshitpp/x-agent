# jcode CLI Reference

Rust multi-provider terminal coding agent (github.com/1jehuang/jcode).

## 1. CLI Identity & Invocation

- **Command:** `jcode`
- **Non-interactive flag:** `run "<prompt>"` subcommand (single message, then exit)
- **Output format flag:** `run --json` (single JSON result) or `run --ndjson` (event stream); default streams text
- **Trust/auto-approve flag:** None documented; run mode needs no separate flag
- **List models command:** None as a flag; use `/model` in the TUI

## 2. Model Selection Heuristic

- **Default model (fallback):** jcode default (omit `--model`)
- **Aliases:** None — pass provider model IDs (e.g. `claude-opus-4-6`, `gpt-5.5`); `-p` / `--provider` selects the provider (default `auto`)
- **Quirks:** `-m` / `--model` and `-p` / `--provider` are global flags (valid before or after `run`). `--quiet` suppresses status output for scripting. Run `jcode login` first to connect a provider.

## 3. Invocation Template

| Mode           | Command                                                       |
|----------------|---------------------------------------------------------------|
| **Validation** | `jcode --model <model> run "$(cat "$PROMPT_FILE")"`           |
| **Delegation** | `jcode --model <model> run "$(cat "$PROMPT_FILE")"`           |

Note: same invocation for both modes; no auto-approve flag exists. `message` is a required positional argument, so the prompt is passed as an argument (no stdin).

## 4. Version Compatibility Matrix

| Version | Run Subcommand | Model Flag        | Output Format       | Notes                      |
|---------|----------------|-------------------|---------------------|----------------------------|
| 0.92.x  | `run`          | `-m` / `--model`  | `--json`/`--ndjson` | Verified against source    |
