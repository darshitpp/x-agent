# Pi CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `pi`
- **Non-interactive flag:** `-p` / `--print` (process prompt and exit)
- **Output mode flag:** `--mode text|json|rpc` (default: text)
- **Provider flag:** `--provider <name>` (default: `google`; supports `anthropic`, `openai`, `openrouter`, `deepseek`, etc.)
- **Model flag:** `--model <pattern>` (supports `provider/id` and `:thinking` suffix, e.g. `sonnet:high`)
- **Ephemeral session:** `--no-session` (don't save session to disk)
- **Trust project-local files:** `-a` / `--approve` (load AGENTS.md, CLAUDE.md, themes, prompts from the project for this run; required for skill to run on real projects)
- **List models command:** `pi --list-models [search]` (fuzzy search optional)
- **Version:** `pi --version` (returns e.g. `0.80.3`); echo once before invoking for traceability
- **Self-call detection:** Check for `PI_AGENT` environment variable or `pi` in process ancestry

## 2. Model Selection Heuristic

- **Default provider:** `google` (Gemini)
- **Default model (fallback):** First available from `pi --list-models`, filtered to Balanced tier
- **Aliases (via `--model` shorthand):** `sonnet:high` → anthropic/claude-sonnet with high thinking; `opus:high` → anthropic/claude-opus with high thinking; `haiku:low` → anthropic/claude-haiku with low thinking
- **Provider prefix in model flag:** `--model openai/gpt-4o` works without `--provider openai`
- **Quirks:**
  - Pi is **provider-agnostic**; model families come from many providers (anthropic, openai, google, deepseek, openrouter, etc.)
  - `ANTHROPIC_MODEL` env var is **not** a Pi convention — Pi uses `--model` or `provider/id` strings
  - No `--fallback-model` flag; use `--models a,b,c` for cycling or retry with explicit `--model`
  - Thinking level is set via `--thinking <off|minimal|low|medium|high|xhigh|max>` or `:level` suffix on `--model`

## 3. Invocation Template

| Mode           | Command                                                                            |
|----------------|------------------------------------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| pi -p -a --provider <p> --model <m> --mode text --no-session` |
| **Delegation** | `cat "$PROMPT_FILE" \| pi -p -a --provider <p> --model <m> --mode text --no-session` |

**Notes:**

- Validation and delegation use the same invocation shape; mode is inferred from prompt content (see shared-procedure.md Step 1).
- `--no-session` avoids leaving session files on the host; use `--continue`/`--resume` only when the user explicitly asks to resume.
- `--mode json` for machine-readable output (one JSON object per line); `--mode rpc` for JSON-RPC over stdio.
- Always echo `pi --version` once before invoking to record the exact version in the log.
- If `--list-models` succeeds, use a real model name from its output. If it fails, fall back to a sensible default (e.g. `gemini-2.5-flash` for google, `claude-sonnet-4-5` for anthropic) and warn.

## 4. Version Compatibility Matrix

| Version | Print Flag | Model Flag | Provider Flag | Output Mode   | Notes   |
|---------|-----------|------------|---------------|---------------|---------|
| 0.80.x  | `-p`/`--print` | `--model` | `--provider`  | `--mode text|json|rpc` | Current |

**Compatibility policy:**

- Flags above are the contract. If the installed `pi --version` reports a major version that isn't 0.80.x, use the closest match in this table and warn the user.
- `pi --version` is the source of truth at runtime; this matrix is a quick-reference snapshot.
- Run `pi --help` once before relying on these flags to confirm they're still present (Pi adds flags frequently).
