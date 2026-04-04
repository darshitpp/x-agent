#!/usr/bin/env bash
# run-workflow.sh — Run a GitHub Actions workflow locally using `act`
# Usage: ./scripts/run-workflow.sh <workflow-file> [--job <job-name>]
#
# Requires: act (https://github.com/nektos/act)
#   brew install act
#
# Examples:
#   ./scripts/run-workflow.sh lint-workflows.yml          # Run entire workflow
#   ./scripts/run-workflow.sh lint-workflows.yml --job actionlint  # Run specific job
#   ./scripts/run-workflow.sh sync-cli-updates.yml -e      # List events only (dry-run)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
WORKFLOW="${1:?Usage: run-workflow.sh <workflow-file> [--job <job-name>]}"
shift

WORKFLOW_PATH="$REPO_DIR/.github/workflows/$WORKFLOW"

if [ ! -f "$WORKFLOW_PATH" ]; then
  echo "Error: Workflow not found: $WORKFLOW_PATH" >&2
  exit 1
fi

if ! command -v act &>/dev/null; then
  echo "Error: 'act' not found. Install with: brew install act" >&2
  exit 1
fi

echo "Running workflow: $WORKFLOW"
act workflow_run \
  --workflows "$WORKFLOW_PATH" \
  --container-architecture linux/arm64 \
  --rm \
  "$@"
