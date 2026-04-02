#!/usr/bin/env bash
# detect-updates.sh — Detect CLI changes by diffing current output against stored snapshots
# Usage: ./detect-updates.sh [cli-name]
# If cli-name is omitted, checks all five CLIs.
# Exits 0 if no changes, 1 if changes detected. Outputs changed CLI names to stdout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../assets"

CLIS=("codex" "cursor" "claude" "gemini" "junie")
CLI_COMMANDS=("codex" "agent" "claude" "gemini" "junie")
# Which CLIs support --list-models (cursor does; others do not or require auth)
LIST_MODELS_SUPPORTED=("false" "true" "false" "false" "false")

if [ "${1:-}" != "" ]; then
  case "$1" in
    codex)  CLIS=("codex");  CLI_COMMANDS=("codex"); LIST_MODELS_SUPPORTED=("false") ;;
    cursor) CLIS=("cursor"); CLI_COMMANDS=("agent"); LIST_MODELS_SUPPORTED=("true") ;;
    claude) CLIS=("claude"); CLI_COMMANDS=("claude"); LIST_MODELS_SUPPORTED=("false") ;;
    gemini) CLIS=("gemini"); CLI_COMMANDS=("gemini"); LIST_MODELS_SUPPORTED=("false") ;;
    junie)  CLIS=("junie");  CLI_COMMANDS=("junie");  LIST_MODELS_SUPPORTED=("false") ;;
    *) echo "Unknown CLI: $1" >&2; exit 2 ;;
  esac
fi

CHANGED=0
for i in "${!CLIS[@]}"; do
  CLI="${CLIS[$i]}"
  CMD="${CLI_COMMANDS[$i]}"
  HAS_LIST_MODELS="${LIST_MODELS_SUPPORTED[$i]}"
  SNAPSHOT="$ASSETS_DIR/${CLI}-snapshot.txt"

  # Check if CLI is installed
  if ! command -v "$CMD" &>/dev/null; then
    echo "SKIP: $CLI ($CMD not found)" >&2
    continue
  fi

  # Capture current output
  CURRENT=$(mktemp)
  {
    echo "=== VERSION ==="
    $CMD --version 2>&1 || echo "(version unavailable)"
    echo ""
    echo "=== HELP ==="
    $CMD --help 2>&1 || echo "(help unavailable)"
    if [ "$HAS_LIST_MODELS" = "true" ]; then
      echo ""
      echo "=== LIST MODELS ==="
      $CMD --list-models 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || echo "(list-models unavailable)"
    fi
  } > "$CURRENT"

  # Compare (filter out metadata lines like LAST_RELEASE= from stored snapshot)
  if [ ! -f "$SNAPSHOT" ]; then
    echo "NEW: $CLI (no previous snapshot)"
    cp "$CURRENT" "$SNAPSHOT"
    CHANGED=1
  else
    SNAPSHOT_FILTERED=$(mktemp)
    grep -v '^LAST_RELEASE=' "$SNAPSHOT" > "$SNAPSHOT_FILTERED" || true
    if ! diff -q "$CURRENT" "$SNAPSHOT_FILTERED" &>/dev/null; then
      echo "CHANGED: $CLI"
      # Preserve metadata lines from existing snapshot
      grep '^LAST_RELEASE=' "$SNAPSHOT" > "$CURRENT.meta" 2>/dev/null || true
      cat "$CURRENT.meta" >> "$CURRENT" 2>/dev/null || true
      cp "$CURRENT" "$SNAPSHOT"
      CHANGED=1
    fi
    rm -f "$SNAPSHOT_FILTERED" "$CURRENT.meta"
  fi

  rm -f "$CURRENT"
done

exit $CHANGED
