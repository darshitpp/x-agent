#!/usr/bin/env bash
# common-setup.bash — Shared setup for all BATS test files
# Loads bats-assert/bats-support, sets up PATH shadowing for mock CLIs.

_common_setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"

  # Per-test mock bin directory — prepended to PATH so mocks resolve first
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

# Create a mock CLI that echoes its arguments and consumes stdin.
# Usage: create_mock_cli <name>
create_mock_cli() {
  local name="$1"
  cat > "$BATS_TEST_TMPDIR/bin/$name" <<'MOCK'
#!/usr/bin/env bash
echo "ARGS: $@"
cat > /dev/null
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/$name"
}

# Create a mock CLI that sleeps longer than the timeout (for timeout tests).
# Usage: create_hanging_cli <name> <sleep_seconds>
create_hanging_cli() {
  local name="$1"
  local seconds="${2:-30}"
  cat > "$BATS_TEST_TMPDIR/bin/$name" <<MOCK
#!/usr/bin/env bash
sleep $seconds
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/$name"
}

# Create a mock CLI that exits with a specific code.
# Usage: create_failing_cli <name> <exit_code>
create_failing_cli() {
  local name="$1"
  local code="${2:-1}"
  cat > "$BATS_TEST_TMPDIR/bin/$name" <<MOCK
#!/usr/bin/env bash
exit $code
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/$name"
}

# Create a mock CLI that echoes stdin (for verifying prompt piping).
# Usage: create_echo_stdin_cli <name>
create_echo_stdin_cli() {
  local name="$1"
  cat > "$BATS_TEST_TMPDIR/bin/$name" <<'MOCK'
#!/usr/bin/env bash
cat
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/$name"
}

# Write a prompt file with given content and echo its path.
# Usage: PROMPT=$(create_prompt_file "some content")
create_prompt_file() {
  local content="${1:-Review this code for correctness.}"
  local file="$BATS_TEST_TMPDIR/prompt.txt"
  echo "$content" > "$file"
  echo "$file"
}
