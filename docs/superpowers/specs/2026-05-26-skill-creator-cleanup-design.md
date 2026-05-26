# Skill-creator cleanup design

**Date:** 2026-05-26  
**Status:** Implemented (validated by Claude Sonnet 2.1.x, 2026-05-26)

## Problem

x-agent mixed **runtime skill assets** (`result-template.md`) with **maintainer drift baselines** (`*-snapshot.txt`) and automated them via `sync-cli-updates.yml`. CLI reference docs mentioned repo-only `query-cli.sh`, which is not bundled in self-contained skill installs.

## Goal

Align the repo with agentskills.io / skill-creator: `assets/` holds only files agents read at runtime; maintainer-only tooling stays out of skill paths and optional automation.

## Approach (recommended)

**Strip snapshot pipeline; keep quality gates.**

| Action | Rationale |
|--------|-----------|
| Remove `assets/*-snapshot.txt` | Not referenced by any skill procedure |
| Remove `scripts/detect-updates.sh` + BATS tests | Only existed for snapshots |
| Remove `.github/workflows/sync-cli-updates.yml` | Only updated snapshots |
| Keep `assets/result-template.md` | Required at validation runtime |
| Keep `scripts/validate-metadata.py` + `run-tests.yml` | Enforces skill-creator metadata checklist |
| Keep `scripts/query-cli.sh` | Maintainer/local testing; remove from skill docs |
| Reword `cli-qwen.md` / `cli-opencode.md` timeout notes | Replace `query-cli.sh` mention with explicit agent responsibility per shared-procedure Step 6 (120s kill) |
| Sync bundled copies | Apply CLI reference edits to `references/` **and** `qwen/references/`, `opencode/references/` (and `codex/references/cli-codex.md`) |
| Fix `cli-codex.md` version matrix | Replace “populate from first snapshot” with npm/help-based wording |
| Update README + `run-workflow.sh` | Remove snapshot/sync-cli docs; drop `sync-cli-updates.yml` from `run-workflow.sh` examples; note `query-cli.sh` is maintainer-only |

## Validation (Claude Sonnet)

**Verdict:** Approve with changes.

- Deleting snapshot pipeline is sound; snapshots were only consumed by weekly GHA.
- Keep `query-cli.sh` as maintainer tooling (timeout wrapper still useful); do not delete.
- Do not only delete timeout sentences in CLI refs — **replace** with shared-procedure Step 6 wording so agents retain guidance.
- `run-tests.yml` runs `bats tests/bats/ --recursive`; deleting `detect_updates.bats` is safe (no hardcoded path).
- Bring `cli-codex.md` snapshot placeholder into scope.

## Out of scope

- Per-skill `scripts/` bundles
- Removing `query-cli.sh` or its BATS tests
- Changing shared-procedure behavior (Step 6 already defines 120s timeout)

## Success criteria

- All pytest and BATS tests pass
- No `*-snapshot` or `sync-cli` references remain in repo
- Seven skills remain self-contained with `assets/result-template.md` only
