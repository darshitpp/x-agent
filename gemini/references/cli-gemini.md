# Gemini CLI Reference

## 1. CLI Identity & Invocation

- **Command:** `gemini`
- **Non-interactive flag:** `-p` / `--prompt` (takes prompt as value, or reads from stdin)
- **Output format flag:** `-o` / `--output-format text|json|stream-json`
- **Trust/auto-approve flag:** `-y` / `--yolo`
- **List models command:** Not directly available via CLI flag. Model is specified with `-m`.
- **Self-call detection:** Check for `GEMINI_CLI` environment variable

## 2. Model Selection Heuristic

- **Default model (fallback):** `gemini-2.5-pro`
- **Aliases:** None — use full model IDs
- **Quirks:** Gemini CLI uses auto-routing by default (routes between Flash and Pro based on prompt complexity). No
  `--list-models` flag — available models must be maintained in the version matrix.

## 3. Invocation Template

| Mode           | Command                                                   |
|----------------|-----------------------------------------------------------|
| **Validation** | `cat "$PROMPT_FILE" \| gemini -m <model> -p - -o text`    |
| **Delegation** | `cat "$PROMPT_FILE" \| gemini -m <model> -p - -y -o text` |

Note: `-p -` reads prompt from stdin. `-y` enables auto-approve for delegation.

## 4. Version Compatibility Matrix

| Version | Prompt Flag       | Model Flag       | Output Format            | Yolo Flag       | Notes   |
|---------|-------------------|------------------|--------------------------|-----------------|---------|
| 0.36.x  | `-p` / `--prompt` | `-m` / `--model` | `-o` / `--output-format` | `-y` / `--yolo` | Current |
