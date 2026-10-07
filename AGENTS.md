# AGENTS.md

x-agent is a set of [agentskills.io](https://agentskills.io) skills, one per supported CLI. Each `<cli>/SKILL.md` is a
thin entry point that points at shared references. No application code; the product is Markdown plus a maintainer
shell wrapper.

## Discover, don't assume

This file lists no CLIs or files that change. Look them up:

- Supported CLIs: `ls */SKILL.md` (each top-level dir with a `SKILL.md` is one CLI).
- Everything that must change for a CLI: `git grep -n -i <existing-cli-name>` (use a similar, recent CLI such as the
  latest `git log --stat` addition as the template) and mirror each hit.
- Layout and CI details: `README.md` (directory tree, CI section) and `.github/workflows/`.

## Rules

- **`references/` and `assets/` at the repo root are canonical.** Each skill folder holds byte-identical copies, because
  skills install standalone. After editing a canonical file, copy it into every skill folder that has it. pytest fails
  on drift and prints the `cp` command.
- `SKILL.md` stays thin: frontmatter plus "read shared-procedure, read the CLI reference, follow it". Flags, models and
  version info belong in `references/cli-<cli>.md`.
- Frontmatter limits are enforced by `scripts/validate-metadata.py` (run it with `--help`).
- `scripts/query-cli.sh` is maintainer-only and not shipped; skills never call it.
- No self-call detection: invoking the same CLI with a different model is a supported cross-validation use case.
- **Document only flags you verified.** Check the installed CLI is current (`npm view <pkg> version`, or
  `npx -y <pkg>@latest --help`; for others use the CLI's own update command), then read `<cli> --help`; otherwise cite
  the public docs. Mark anything unverified as such in the reference.
- Changes go through a PR; CI runs integrity, pytest and bats on Ubuntu and macOS.

## Adding a CLI or changing its flags

A CLI is touched in five places; find the exact current files with `git grep` as above rather than trusting a list:

1. Canonical reference `references/cli-<cli>.md`, plus its copy in `<cli>/references/`.
2. Skill folder `<cli>/` (SKILL.md and copies of the shared procedure and result template).
3. The matching `case` in `scripts/query-cli.sh`.
4. bats tests for that case, and the CLI-name lists in the pytest files.
5. README mentions of the CLI.

## Testing

Read the test setup in `README.md` and `.github/workflows/run-tests.yml` for the current commands and dependencies
(pytest and bats; `scripts/run-workflow.sh` runs CI locally via act).
