# Shared Procedure for Cross-Agent Task Running

## Step 1: Infer Mode

Classify the user's request based on prompt signals:

| Mode           | Signals                                                                                                  | Behavior                                                          |
|----------------|----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| **validation** | "review", "check", "second opinion", "verify", "validate", "what do you think", "compare"                | Gather context, send to target CLI, present structured comparison |
| **delegation** | "fix", "implement", "build", "refactor", "add", "create", "do", "run" — or absence of validation signals | Hand off task entirely, return output with minimal framing        |

**Conflict resolution:** If both validation and delegation signals are present, validation takes precedence. The user
asked for review; fixes are a natural outcome.

Default to **delegation** if no clear signals are present.

## Step 2: Detect Model Override

1. Check if the user specified a model in the prompt (e.g., `--model gpt-5.3` or natural language like "use sonnet for
   this").
2. If a model name or alias is found, use it directly and skip auto-selection.
3. If not, proceed to Step 3.

## Step 3: Select Model

1. Run the target CLI's list-models command (read the exact command from the CLI reference file).
2. If the list-models command fails or returns no results, fall back to the default model specified in the CLI reference
   file and skip to Step 4.
3. Parse and classify all available models into tiers. Match signals in order — **first match wins**:

| Priority | Tier                   | Signal in model name                           | Traits                            |
|----------|------------------------|------------------------------------------------|-----------------------------------|
| 1        | **Flagship reasoning** | `opus`, `pro`, `grok-4`, `o3`, `o4`            | Best quality, highest cost        |
| 2        | **Code-specialized**   | `codex`, `code`                                | Optimized for code tasks          |
| 3        | **Balanced**           | `sonnet`, `flash`, `gpt-5.x` (base)            | Good all-round, moderate cost     |
| 4        | **Fast/cheap**         | `haiku`, `flash-lite`, `mini`, `nano`, `-fast` | Lowest cost                       |
| 5        | **Unknown**            | No signal match                                | Classified as Balanced by default |

4. Pick based on mode + task context:

| Mode                                 | Task Type      | Preferred Tier                                                  |
|--------------------------------------|----------------|-----------------------------------------------------------------|
| **Validation** — plan/architecture   | Complex        | Flagship reasoning (different model family than host preferred) |
| **Validation** — code review         | Moderate       | Code-specialized → Balanced (different model family preferred)  |
| **Delegation** — implement/build     | Active coding  | Code-specialized → Balanced                                     |
| **Delegation** — simple fix/refactor | Low complexity | Balanced → Fast/cheap                                           |
| **General**                          | Unknown        | Balanced                                                        |

5. **Validation mode family filter:** "Different family" means a different model provider family than the model the host
   agent is currently using. Detection: check the host agent's model via environment variables (`ANTHROPIC_MODEL`,
   `CURSOR_MODEL`) or the host CLI's config. If undetectable, prefer models from a provider other than the target CLI's
   default provider. This is a preference, not a hard filter — if only same-family models are available, use them.

6. Within the selected tier, break ties:
    - Latest version number wins. Parse version from model name: numeric versions (`5.3` > `5.2`), date-based versions (
      `20260401` > `20250514`). If not parseable, treat as equal.
    - Standard reasoning tier preferred (no `-low`, `-high`, `-xhigh` suffix).
    - Non-fast variant preferred over fast.

7. User override from Step 2 always wins over any auto-selection.

## Step 4: Gather Context

Classify the review type and gather appropriate context:

| Review Type      | Signal                            | Context to gather               |
|------------------|-----------------------------------|---------------------------------|
| **plan**         | plan, design, spec, approach      | Read plan/design doc            |
| **code**         | implementation, diff, changes, PR | `git diff`, changed files       |
| **architecture** | structure, modules, dependencies  | Key interfaces, directory tree  |
| **general**      | anything else                     | Files/context from conversation |

Delegation mode uses lighter context — task description and relevant file paths, not full diffs.

## Step 5: Construct Prompt

- **Validation mode:** Start with a role prompt ("senior engineer providing a review"). Include gathered context, the
  user's specific question, and request for issues/edge cases/alternatives with confidence ratings. End with "Be direct.
  Flag only real issues, not style preferences." Keep under 12,000 tokens (~8,000 words). If context exceeds this limit,
  prioritize: (a) most recent changes, (b) files directly relevant to the user's question, (c) truncate long diffs to
  changed hunks only, (d) summarize large files rather than including verbatim. For fast/cheap tier models with smaller
  context windows, reduce to 6,000 tokens.
- **Delegation mode:** Use the user's original request as the task prompt. Include relevant file contents and context.
  No review framing. Same token limits apply.

## Step 6: Execute CLI

1. Read the CLI-specific reference file for the invocation template and flags.
2. Detect the installed CLI version via `<cli> --version`.
3. Look up the version matrix for the correct flags. If the installed version is not in the matrix, use the latest known
   version's flags and warn the user.
4. Write the constructed prompt to a temp file (safe prompt transport — never embed prompt in shell argument strings):
   ```bash
   PROMPT_FILE=$(mktemp)
   cat <<'PROMPT_EOF' > "$PROMPT_FILE"
   <constructed-prompt>
   PROMPT_EOF
   ```
5. Run in non-interactive/print mode with a **120-second timeout**. If the CLI does not respond within this window, kill
   the process and report a timeout error.
6. Capture full output. Clean up the temp file: `rm -f "$PROMPT_FILE"`.
7. On failure, report the error and suggest checking CLI installation/authentication.

## Step 7: Present Results

- **Validation mode:** Read `assets/result-template.md` and follow the validation template structure. Present the second
  opinion, agreement, counterpoints, and synthesis. Do not blindly agree with the second model. If the second model's
  output is generic or unhelpful, say so.
- **Delegation mode:** Present the target CLI's output directly with a brief header noting which CLI and model were
  used. Add commentary only if the output needs clarification or has issues.

## Error Handling

| Condition                      | Behavior                                                                |
|--------------------------------|-------------------------------------------------------------------------|
| CLI not found                  | Inform user with install instructions from CLI reference file           |
| Model unavailable              | Fall back to default model from CLI reference file, inform user         |
| `--list-models` fails          | Fall back to default model from CLI reference file                      |
| Output empty or garbled        | Report failure, suggest retry with explicit `--model`                   |
| Version not in matrix          | Use latest known version's flags, warn user                             |
| Host model family undetectable | Prefer models from a different provider than target CLI's default       |
| CLI execution timeout (>120s)  | Kill process, report timeout, suggest simpler prompt or different model |
| Unrecognized model name        | Classify as Balanced, proceed normally                                  |
