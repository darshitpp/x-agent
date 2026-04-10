#!/usr/bin/env bats
# Tests for scripts/query-cli.sh

setup() {
  load test_helper/common-setup
  _common_setup
  QUERY_CLI="$REPO_ROOT/scripts/query-cli.sh"
  PROMPT=$(create_prompt_file "test prompt content")
}

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------

@test "exits with error when no arguments given" {
  run "$QUERY_CLI"
  assert_failure
  assert_output --partial "Usage"
}

@test "exits with error when prompt file does not exist" {
  create_mock_cli codex
  run "$QUERY_CLI" codex validation test-model /nonexistent/file.txt
  assert_failure
  assert_output --partial "not found"
}

@test "exits with error for invalid mode" {
  create_mock_cli codex
  run "$QUERY_CLI" codex foobar test-model "$PROMPT"
  assert_failure
  assert_output --partial "must be"
}

@test "exits with error for unknown CLI name" {
  run "$QUERY_CLI" unknown validation test-model "$PROMPT"
  assert_failure
  assert_output --partial "Unknown CLI"
}

# ---------------------------------------------------------------------------
# Codex invocation
# ---------------------------------------------------------------------------

@test "codex validation passes --ephemeral without --full-auto" {
  create_mock_cli codex
  run "$QUERY_CLI" codex validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "exec -m test-model --ephemeral -"
  refute_output --partial "--full-auto"
}

@test "codex delegation passes --full-auto --ephemeral" {
  create_mock_cli codex
  run "$QUERY_CLI" codex delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "exec -m test-model --full-auto --ephemeral -"
}

# ---------------------------------------------------------------------------
# Cursor invocation (binary is "agent")
# ---------------------------------------------------------------------------

@test "cursor validation passes -p --model without --trust" {
  create_mock_cli agent
  run "$QUERY_CLI" cursor validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-p --model test-model"
  refute_output --partial "--trust"
}

@test "cursor delegation passes --trust" {
  create_mock_cli agent
  run "$QUERY_CLI" cursor delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-p --model test-model --trust"
}

# ---------------------------------------------------------------------------
# Claude invocation (same for both modes)
# ---------------------------------------------------------------------------

@test "claude validation passes correct flags" {
  create_mock_cli claude
  run "$QUERY_CLI" claude validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-p --model test-model --output-format text"
}

@test "claude delegation passes same flags as validation" {
  create_mock_cli claude
  run "$QUERY_CLI" claude delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-p --model test-model --output-format text"
}

# ---------------------------------------------------------------------------
# Gemini invocation
# ---------------------------------------------------------------------------

@test "gemini validation passes -m -p -o without -y" {
  create_mock_cli gemini
  run "$QUERY_CLI" gemini validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-m test-model -p - -o text"
  refute_output --partial " -y "
}

@test "gemini delegation passes -y" {
  create_mock_cli gemini
  run "$QUERY_CLI" gemini delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "-m test-model -p - -y -o text"
}

# ---------------------------------------------------------------------------
# Junie invocation (same for both modes, adds --timeout in ms)
# ---------------------------------------------------------------------------

@test "junie validation passes --timeout in milliseconds" {
  create_mock_cli junie
  run "$QUERY_CLI" junie validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "--model test-model --output-format text --timeout 10000"
}

@test "junie delegation passes same flags as validation" {
  create_mock_cli junie
  run "$QUERY_CLI" junie delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "--model test-model --output-format text --timeout 10000"
}

# ---------------------------------------------------------------------------
# Qwen invocation
# ---------------------------------------------------------------------------

@test "qwen validation passes --model without --yolo" {
  create_mock_cli qwen
  run "$QUERY_CLI" qwen validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "--model test-model"
  refute_output --partial "--yolo"
}

@test "qwen delegation passes --yolo" {
  create_mock_cli qwen
  run "$QUERY_CLI" qwen delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "--model test-model --yolo"
}

# ---------------------------------------------------------------------------
# OpenCode invocation (same for both modes)
# ---------------------------------------------------------------------------

@test "opencode validation passes run -m --format default" {
  create_mock_cli opencode
  run "$QUERY_CLI" opencode validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "run -m test-model --format default"
}

@test "opencode delegation passes same flags as validation" {
  create_mock_cli opencode
  run "$QUERY_CLI" opencode delegation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "run -m test-model --format default"
}

# ---------------------------------------------------------------------------
# Timeout behavior
# ---------------------------------------------------------------------------

@test "returns exit code 124 on timeout" {
  create_hanging_cli codex 30
  run "$QUERY_CLI" codex validation test-model "$PROMPT" 2
  [ "$status" -eq 124 ]
}

# ---------------------------------------------------------------------------
# Stdin piping
# ---------------------------------------------------------------------------

@test "prompt file content is piped to CLI stdin" {
  create_echo_stdin_cli codex
  run "$QUERY_CLI" codex validation test-model "$PROMPT" 10
  assert_success
  assert_output --partial "test prompt content"
}
