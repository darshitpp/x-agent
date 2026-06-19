# x-agent

Let your AI coding agent talk to other AI coding agents.

x-agent is a set of [agentskills.io](https://agentskills.io) skills that enable any AI CLI tool — Codex, Cursor, Claude
Code, Gemini CLI, Junie, Qwen Code, OpenCode, Pi — to delegate tasks to or get second opinions from the others. Install it once, and your agent
gains the ability to call any of the other seven.

## Why

Every model has blind spots. A single model reviewing its own output is like proofreading your own writing — you miss
things. x-agent fixes this by letting your agent bring in a different model family for a genuine second opinion.

- **Catch what one model misses.** Claude might miss a concurrency issue that Gemini catches. Codex might spot an API
  misuse that Cursor overlooks. Cross-model validation surfaces real problems, not just style preferences.
- **Use the right model for the job.** Some models are better at reasoning about architecture, others at writing code
  fast. Instead of being locked into one, delegate the task to whichever model fits best.
- **No copy-paste workflow.** Without x-agent, cross-validating means manually copying context between terminals.
  x-agent handles context gathering, prompt construction, model selection, and result synthesis automatically.

## When to use it

| Situation                                                    | Mode           | What happens                                                                                                             |
|--------------------------------------------------------------|----------------|--------------------------------------------------------------------------------------------------------------------------|
| You finished a plan and want a sanity check before building  | **Validation** | Sends the plan to a different model family, returns a structured comparison with agreement, counterpoints, and synthesis |
| You have a PR and want a review from a different perspective | **Validation** | Gathers the diff, sends it to the target CLI, presents findings you can act on                                           |
| You want a task done by a specific model                     | **Delegation** | Hands off the task entirely — the target CLI does the work and returns the result                                        |
| Your current model is stuck on a bug                         | **Delegation** | Routes the problem to a different model that might approach it differently                                               |
| You want to compare how two models would implement something | **Validation** | Get the second model's approach, then see where the two agree and diverge                                                |

You **don't** need x-agent when you're happy with your current model's output and don't need a second perspective. It
adds a round-trip to another CLI, so use it when the extra signal is worth the time.

## Supported CLIs

| CLI            | Command       | Default Model        | Notes                                                    |
|----------------|---------------|----------------------|----------------------------------------------------------|
| OpenAI Codex   | `codex`       | `o4-mini`            | OpenAI models only                                       |
| Cursor Agent   | `agent`       | `composer-2-fast`    | Multi-provider (OpenAI, Anthropic, Google, xAI)          |
| Claude Code    | `claude`      | `sonnet`             | Anthropic models                                         |
| Gemini CLI     | `gemini`      | `gemini-2.5-pro`     | Google models, auto-routing                              |
| Junie          | `junie`       | Junie default        | LLM-agnostic, BYOK support                               |
| Qwen Code      | `qwen`        | Qwen default         | Qwen model family, `--yolo` for auto-approve             |
| OpenCode       | `opencode`    | OpenCode default     | Multi-provider, uses `run` subcommand with auto-approval |
| Pi             | `pi`          | `sonnet`             | Multi-provider, minimal terminal coding harness          |

## How to use it

The skill infers what to do from your natural language. No flags or special syntax needed.

**Validation** — words like "review", "check", "second opinion", "validate", "compare" trigger validation mode. Your
agent gathers context, sends it to the target CLI, and presents a structured comparison.

```
Review my implementation plan using Cursor
Get a second opinion on this PR from Gemini
Validate this architecture with Claude
```

**Delegation** — words like "fix", "implement", "build", "refactor", "create" trigger delegation mode. The task is
handed off entirely to the target CLI.

```
Use Codex to implement the retry logic
Have Cursor fix the failing tests
Delegate this refactoring to Claude
```

**Model override** — specify a model explicitly when you want control over which model runs the task.

```
Review this code using o4-mini via Codex
Use opus to validate my approach via Claude
```

**What happens under the hood:**

1. Infers mode (validation or delegation) from your prompt
2. Queries the target CLI for available models, classifies them into tiers (flagship reasoning, code-specialized,
   balanced, fast/cheap)
3. Picks a model — for validation, prefers a different model family than your current agent to get a genuine second
   opinion
4. Gathers relevant context (diffs, files, plans) based on what you're asking about
5. Constructs a prompt, writes it to a temp file (safe transport), and runs the target CLI in non-interactive mode with
   a 120s timeout
6. Presents results — validation gets a structured template (second opinion, agreement, counterpoints, synthesis);
   delegation returns the output directly

## Installation

### Quick Install (recommended)

Install using [skills.sh](https://skills.sh/) — works with Claude Code, GitHub Copilot, Cursor, Cline, Windsurf, and 15+
other agents:

```bash
npx skills add darshitpp/x-agent
```

This auto-detects the agent and installs all seven skills in the correct location. No manual setup needed.

### Claude Code (manual)

There are two installation scopes:

**Global (available in all projects):**

```bash
git clone https://github.com/darshitpp/x-agent.git ~/.claude/skills/x-agent
```

**Per-project (available only in that project):**

```bash
cd /path/to/your/project
mkdir -p .claude/skills
git clone https://github.com/darshitpp/x-agent.git .claude/skills/x-agent
```

After installation, the skills appear automatically in Claude Code's available skills list. Each CLI has its own skill (
`codex`, `cursor`, `claude`, `gemini`, `junie`, `qwen`, `opencode`, `pi`) that triggers based on context.

To update later:

```bash
cd ~/.claude/skills/x-agent   # or .claude/skills/x-agent
git pull
```

### Other Agents

This skill follows the [agentskills.io](https://agentskills.io) open standard and works with any compatible agent.
See [Usage with Different Agents](#usage-with-different-agents) below for agent-specific setup.

## Directory Structure

```
x-agent/
├── codex/SKILL.md                    # Thin entry point (~27 lines)
├── cursor/SKILL.md                   # Thin entry point (~27 lines)
├── claude/SKILL.md                   # Thin entry point (~27 lines)
├── gemini/SKILL.md                   # Thin entry point (~27 lines)
├── junie/SKILL.md                    # Thin entry point (~27 lines)
├── qwen/SKILL.md                     # Thin entry point (~27 lines)
├── opencode/SKILL.md                # Thin entry point (~27 lines)
├── pi/SKILL.md                      # Thin entry point (~20 lines)
├── references/
│   ├── shared-procedure.md           # Core procedure (~105 lines)
│   ├── cli-codex.md                  # Codex CLI identity, invocation, version matrix
│   ├── cli-cursor.md                 # Cursor Agent CLI identity, invocation, version matrix
│   ├── cli-claude.md                 # Claude Code CLI identity, invocation, version matrix
│   ├── cli-gemini.md                 # Gemini CLI identity, invocation, version matrix
│   ├── cli-junie.md                  # Junie CLI identity, invocation, version matrix
│   ├── cli-qwen.md                   # Qwen Code CLI identity, invocation, version matrix
│   ├── cli-opencode.md              # OpenCode CLI identity, invocation, version matrix
│   └── cli-pi.md                    # Pi CLI identity, invocation, version matrix
├── scripts/
│   ├── validate-metadata.py          # Validates SKILL.md frontmatter (authoring + CI)
│   ├── query-cli.sh                  # Maintainer-only CLI wrapper (not used by skills at runtime)
│   └── run-workflow.sh               # Run GitHub Actions workflows locally via act
├── assets/
│   └── result-template.md            # Output template for validation/delegation (read at runtime)
├── tests/
│   ├── bats/                          # BATS shell script tests
│   └── pytest/                        # Python tests (metadata, skill integrity)
├── .github/workflows/
│   ├── run-tests.yml                 # CI test suite (BATS + pytest, ubuntu + macOS)
│   └── lint-workflows.yml            # actionlint on workflow YAML
├── docs/superpowers/                 # Design specs and implementation history
├── README.md
├── LICENSE
└── .gitignore
```

## CI

GitHub Actions runs on every push and pull request to `main`:

- **`run-tests.yml`** — BATS tests for `query-cli.sh` (mocked CLIs) and pytest for metadata validation, canonical/per-skill file drift, and self-contained installs (ubuntu + macOS).
- **`lint-workflows.yml`** — [actionlint](https://github.com/rhysd/actionlint) on workflow YAML when `.github/workflows/` changes.

Run workflows locally with [act](https://github.com/nektos/act): `./scripts/run-workflow.sh run-tests.yml`

## Maintaining CLI references

When a target CLI changes flags or defaults, update manually:

1. Run `<cli> --version` and `<cli> --help` (and `--list-models` if available).
2. Edit `references/cli-<name>.md` (identity, invocation template, version matrix).
3. Copy into the skill bundle: `cp references/cli-<name>.md <name>/references/`
4. Run the test suite.

Skills do not use repo-root `scripts/` at runtime — each install is self-contained under `<cli>/` with its own `references/` and `assets/result-template.md`.

## Testing

The test suite has no external CLI dependencies — shell and Python tests use mocks.

**Prerequisites:**

```bash
brew install bats-core
brew tap bats-core/bats-core && brew install bats-support bats-assert
pip3 install pytest pyyaml
```

**Run tests:**

```bash
# Shell script tests (BATS)
BATS_LIB_PATH="/opt/homebrew/lib" bats tests/bats/ --recursive

# Python tests (pytest)
pytest tests/pytest/ -v
```

Tests also run automatically on every PR via GitHub Actions (ubuntu + macOS).

## Adding a New CLI

1. Create `<cli-name>/SKILL.md` following the existing pattern (copy any existing one)
2. Create `references/cli-<cli-name>.md` with the four required sections (Identity, Model Selection, Invocation
   Template, Version Matrix)
3. Copy shared files into the skill bundle:
   ```bash
   mkdir -p <cli-name>/references <cli-name>/assets
   cp references/shared-procedure.md references/cli-<cli-name>.md <cli-name>/references/
   cp assets/result-template.md <cli-name>/assets/
   ```
4. Validate frontmatter: `python3 scripts/validate-metadata.py --name <name> --description "<desc>"`
5. Optionally add the CLI to `scripts/query-cli.sh` for maintainer testing and extend `tests/bats/query_cli.bats`
6. Run the full test suite (`bats` + `pytest`)

## Usage with Different Agents

This skill follows the [agentskills.io](https://agentskills.io) open standard. Each CLI has its own skill directory with
a `SKILL.md` entry point.

### Claude Code

| Scope                   | Path                        |
|-------------------------|-----------------------------|
| Personal (all projects) | `~/.claude/skills/x-agent/` |
| Project                 | `.claude/skills/x-agent/`   |

**Invoke:** Ask naturally ("get a second opinion from Cursor") or explicitly with `/codex`, `/cursor`, `/claude`,
`/gemini`, `/junie`, `/qwen`, `/opencode`, `/pi`. Claude loads the skill automatically when relevant.

[Claude Code skills docs](https://code.claude.com/docs/en/skills)

### Cursor

| Scope         | Path                                                   |
|---------------|--------------------------------------------------------|
| User (global) | `~/.cursor/skills/x-agent/`                            |
| Project       | `.cursor/skills/x-agent/` or `.agents/skills/x-agent/` |

**Invoke:** Ask naturally or use the skill name in chat. Cursor auto-discovers skills at startup. You can also install
from GitHub via **Settings > Rules > Add Rule > Remote Rule (Github)**.

[Cursor skills docs](https://cursor.com/docs/context/skills)

### GitHub Copilot / VS Code

| Scope    | Path                                                        |
|----------|-------------------------------------------------------------|
| Personal | `~/.copilot/skills/x-agent/` or `~/.claude/skills/x-agent/` |
| Project  | `.github/skills/x-agent/` or `.claude/skills/x-agent/`      |

**Invoke:** Copilot auto-discovers and loads skills when relevant to the task.

[Copilot skills docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)

### OpenAI Codex

| Scope   | Path                         |
|---------|------------------------------|
| User    | `~/.agents/skills/x-agent/`  |
| Project | `.agents/skills/x-agent/`    |
| System  | `/etc/codex/skills/x-agent/` |

**Invoke:** Reference with `/skills` or `$` mention syntax, or let Codex auto-select based on task context.

[Codex skills docs](https://developers.openai.com/codex/skills/)

### Goose

| Scope   | Path                                                                    |
|---------|-------------------------------------------------------------------------|
| Global  | `~/.config/goose/skills/x-agent/` or `~/.config/agents/skills/x-agent/` |
| Project | `.goose/skills/x-agent/` or `.agents/skills/x-agent/`                   |

**Invoke:** Ask "Use the x-agent skill" or let Goose auto-activate when relevant.

[Goose skills docs](https://block.github.io/goose/docs/guides/context-engineering/using-skills/)

### Roo Code

| Scope   | Path                                                    |
|---------|---------------------------------------------------------|
| Global  | `~/.roo/skills/x-agent/` or `~/.agents/skills/x-agent/` |
| Project | `.roo/skills/x-agent/` or `.agents/skills/x-agent/`     |

**Invoke:** Roo indexes all skills at startup and auto-activates when your request matches. No manual registration
needed.

[Roo Code skills docs](https://docs.roocode.com/features/skills)

### Amp

| Scope   | Path                      |
|---------|---------------------------|
| Project | `.agents/skills/x-agent/` |

[Amp skills docs](https://ampcode.com/manual#agent-skills)

### Junie (JetBrains)

[Junie skills docs](https://junie.jetbrains.com/docs/agent-skills.html)

### Gemini CLI

[Gemini CLI skills docs](https://geminicli.com/docs/cli/skills/)

### Other Agents

For any other [agentskills.io](https://agentskills.io)-compatible agent, place the skill directory where the agent
discovers skills (typically `~/.agents/skills/` globally or `.agents/skills/` per-project). Each `<cli>/SKILL.md` file
is an entry point. The agent loads references and scripts on demand via progressive disclosure.

## License

MIT License. Copyright (c) 2026 Darshit Patel. See [LICENSE](LICENSE) for the full text.
