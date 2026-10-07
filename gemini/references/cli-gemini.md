# Gemini CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `gemini`
- **Non-interactive flag:** `-p` / `--prompt` (takes prompt as value, or reads from stdin)
- **Output format flag:** `-o` / `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `-y` / `--yolo` (or `--approval-mode default|auto_edit|yolo|plan`)
- **Workspace trust:** headless runs in an untrusted directory fail; pass `--skip-trust` (or set `GEMINI_CLI_TRUST_WORKSPACE=true`)
- **Deprecation:** consumer/free tiers retired 2026-06-18 in favor of `agy`; enterprise and paid API-key users unaffected
- **List models command:** Not directly available via CLI flag. Model is specified with `-m`.

## 2. Model Selection Heuristic

- **Default model (fallback):** `gemini-2.5-pro`
- **Aliases:** None — use full model IDs
- **Quirks:** Gemini CLI uses auto-routing by default (routes between Flash and Pro based on prompt complexity). No
  `--list-models` flag — available models must be maintained in the version matrix.

## 3. Invocation Template

| Mode           | Command                                                   |
|----------------|-----------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| gemini -m <model> -p - -o text --skip-trust`    |
| **Delegation** | `cat "$PROMPT_FILE" \| gemini -m <model> -p - -y -o text --skip-trust` |

Note: `-p` is appended to input on stdin, so `-p -` plus piped stdin carries the prompt. `-y` enables auto-approve for delegation.

## 4. Version Compatibility Matrix

| Version | Prompt Flag       | Model Flag       | Output Format            | Yolo Flag       | Notes   |
|---------|-------------------|------------------|--------------------------|-----------------|---------|
| 0.46.x  | `-p` / `--prompt` | `-m` / `--model` | `-o` / `--output-format` | `-y` / `--yolo` | Current |
