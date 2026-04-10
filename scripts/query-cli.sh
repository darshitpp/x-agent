#!/usr/bin/env bash
# query-cli.sh — Uniform wrapper for querying any CLI in print mode
# Usage: ./query-cli.sh <cli-name> <mode> <model> <prompt-file> [timeout]
#
# cli-name: codex | cursor | claude | gemini | junie | qwen | opencode
# mode:     validation | delegation
# model:    model ID to use
# prompt-file: path to file containing the prompt
# timeout:  seconds (default: 120)
#
# Writes prompt to target CLI via stdin, captures output.
# Exits 0 on success, 1 on failure, 124 on timeout.

set -euo pipefail

# Unified timeout wrapper: prefers GNU timeout/gtimeout, falls back to perl.
# Usage: run_with_timeout <seconds> sh -c '...'
# Returns the command's exit code, or 124 on timeout (matching GNU timeout).
if command -v timeout &>/dev/null; then
  run_with_timeout() { timeout "$@"; }
elif command -v gtimeout &>/dev/null; then
  run_with_timeout() { gtimeout "$@"; }
elif command -v perl &>/dev/null; then
  # Perl fallback for stock macOS: uses fork + process groups to avoid orphans.
  run_with_timeout() {
    perl -e '
      my $t = shift;
      my $pid = fork // die "fork: $!";
      if (!$pid) { setpgrp(0,0); exec @ARGV; die "exec: $!"; }
      $SIG{ALRM} = sub { kill "TERM", -$pid; };
      alarm $t;
      waitpid($pid, 0);
      exit($? & 127 ? 124 : $? >> 8);
    ' "$@"
  }
else
  echo "Error: No timeout mechanism found. Install coreutils (brew install coreutils) or ensure perl is available." >&2
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
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | codex exec -m "$MODEL" --full-auto --ephemeral -'
    else
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | codex exec -m "$MODEL" --ephemeral -'
    fi
    ;;
  cursor)
    if [ "$MODE" = "delegation" ]; then
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | agent -p --model "$MODEL" --trust'
    else
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | agent -p --model "$MODEL"'
    fi
    ;;
  claude)
    run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | claude -p --model "$MODEL" --output-format text'
    ;;
  gemini)
    if [ "$MODE" = "delegation" ]; then
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | gemini -m "$MODEL" -p - -y -o text'
    else
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | gemini -m "$MODEL" -p - -o text'
    fi
    ;;
  junie)
    TIMEOUT_MS=$((TIMEOUT * 1000))
    export TIMEOUT_MS
    run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | junie --model "$MODEL" --output-format text --timeout "$TIMEOUT_MS"'
    ;;
  qwen)
    # Qwen Code does not expose an internal --timeout flag; relies on external process kill.
    if [ "$MODE" = "delegation" ]; then
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | qwen --model "$MODEL" --yolo'
    else
      run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | qwen --model "$MODEL"'
    fi
    ;;
  opencode)
    # OpenCode auto-approves in non-interactive run mode; no separate delegation flag needed.
    run_with_timeout "$TIMEOUT" sh -c 'cat "$PROMPT_FILE" | opencode run -m "$MODEL" --format default 2>/dev/null'
    ;;
  *)
    echo "Error: Unknown CLI '$CLI_NAME'. Supported: codex, cursor, claude, gemini, junie, qwen, opencode" >&2
    exit 1
    ;;
esac
