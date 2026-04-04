#!/usr/bin/env bash
# query-cli.sh — Uniform wrapper for querying any CLI in print mode
# Usage: ./query-cli.sh <cli-name> <mode> <model> <prompt-file> [timeout]
#
# cli-name: codex | cursor | claude | gemini | junie | qwen | antigravity
# mode:     validation | delegation
# model:    model ID to use
# prompt-file: path to file containing the prompt
# timeout:  seconds (default: 120)
#
# Writes prompt to target CLI via stdin, captures output.
# Exits 0 on success, 1 on failure, 124 on timeout.

set -euo pipefail

# Detect timeout command (GNU timeout on Linux, gtimeout via coreutils on macOS)
if command -v timeout &>/dev/null; then
  TIMEOUT_CMD="timeout"
elif command -v gtimeout &>/dev/null; then
  TIMEOUT_CMD="gtimeout"
else
  echo "Error: 'timeout' command not found. Install coreutils (brew install coreutils on macOS)." >&2
  exit 1
fi

CLI_NAME="${1:?Usage: query-cli.sh <cli-name> <mode> <model> <prompt-file> [timeout]}"
MODE="${2:?Mode required (validation|delegation)}"
MODEL="${3:?Model required}"
PROMPT_FILE="${4:?Prompt file required}"
TIMEOUT="${5:-120}"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

if [ "$MODE" != "validation" ] && [ "$MODE" != "delegation" ]; then
  echo "Error: Mode must be 'validation' or 'delegation', got '$MODE'" >&2
  exit 1
fi

export MODEL PROMPT_FILE TIMEOUT

case "$CLI_NAME" in
  codex)
    if [ "$MODE" = "delegation" ]; then
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | codex exec -m "$MODEL" --full-auto --ephemeral -'
    else
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | codex exec -m "$MODEL" --ephemeral -'
    fi
    ;;
  cursor)
    if [ "$MODE" = "delegation" ]; then
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | agent -p --model "$MODEL" --trust'
    else
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | agent -p --model "$MODEL"'
    fi
    ;;
  claude)
    "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | claude -p --model "$MODEL" --output-format text'
    ;;
  gemini)
    if [ "$MODE" = "delegation" ]; then
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | gemini -m "$MODEL" -p - -y -o text'
    else
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | gemini -m "$MODEL" -p - -o text'
    fi
    ;;
  junie)
    TIMEOUT_MS=$((TIMEOUT * 1000))
    export TIMEOUT_MS
    "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | junie --model "$MODEL" --output-format text --timeout "$TIMEOUT_MS"'
    ;;
  qwen)
    # Qwen Code does not expose an internal --timeout flag; relies on external process kill.
    if [ "$MODE" = "delegation" ]; then
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | qwen --model "$MODEL" --yolo'
    else
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | qwen --model "$MODEL"'
    fi
    ;;
  antigravity)
    # Antigravity CLI does not expose an internal --timeout flag; relies on external process kill.
    if [ "$MODE" = "delegation" ]; then
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | antigravity chat --model "$MODEL" --yolo'
    else
      "$TIMEOUT_CMD" "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | antigravity chat --model "$MODEL"'
    fi
    ;;
  *)
    echo "Error: Unknown CLI '$CLI_NAME'. Supported: codex, cursor, claude, gemini, junie, qwen, antigravity" >&2
    exit 1
    ;;
esac
