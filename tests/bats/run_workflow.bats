#!/usr/bin/env bats
# Tests for scripts/run-workflow.sh

setup() {
  load test_helper/common-setup
  _common_setup

  # Copy script into temp so REPO_DIR resolves to our temp structure
  mkdir -p "$BATS_TEST_TMPDIR/scripts"
  cp "$REPO_ROOT/scripts/run-workflow.sh" "$BATS_TEST_TMPDIR/scripts/"
  RUN_WORKFLOW="$BATS_TEST_TMPDIR/scripts/run-workflow.sh"

  # Create a fake workflow file for tests that need one
  mkdir -p "$BATS_TEST_TMPDIR/.github/workflows"
  echo "name: Test" > "$BATS_TEST_TMPDIR/.github/workflows/test.yml"
}

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------

@test "exits with error when no workflow file given" {
  run "$RUN_WORKFLOW"
  assert_failure
  assert_output --partial "Usage"
}

@test "exits with error when workflow file does not exist" {
  create_mock_cli act
  run "$RUN_WORKFLOW" nonexistent.yml
  assert_failure
  assert_output --partial "not found"
}

@test "exits with error when act is not installed" {
  # Skip if act is genuinely installed — can't cleanly hide it from PATH in BATS
  command -v act &>/dev/null && skip "act is installed on this system"
  run "$RUN_WORKFLOW" test.yml
  assert_failure
  assert_output --partial "act"
}

# ---------------------------------------------------------------------------
# Successful invocation
# ---------------------------------------------------------------------------

@test "invokes act with correct arguments" {
  create_mock_cli act
  run "$RUN_WORKFLOW" test.yml
  assert_success
  assert_output --partial "workflow_run"
  assert_output --partial "--container-architecture linux/arm64"
  assert_output --partial "--rm"
}

@test "passes extra arguments through to act" {
  create_mock_cli act
  run "$RUN_WORKFLOW" test.yml --job actionlint
  assert_success
  assert_output --partial "--job actionlint"
}
