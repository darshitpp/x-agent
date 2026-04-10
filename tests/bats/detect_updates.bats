#!/usr/bin/env bats
# Tests for scripts/detect-updates.sh
#
# The script derives ASSETS_DIR from its own location (SCRIPT_DIR/../assets).
# We copy it into $BATS_TEST_TMPDIR/scripts/ so assets resolve to a temp dir.

setup() {
  load test_helper/common-setup
  _common_setup

  # Copy script into isolated temp structure
  mkdir -p "$BATS_TEST_TMPDIR/scripts" "$BATS_TEST_TMPDIR/assets"
  cp "$REPO_ROOT/scripts/detect-updates.sh" "$BATS_TEST_TMPDIR/scripts/"
  DETECT_UPDATES="$BATS_TEST_TMPDIR/scripts/detect-updates.sh"
  ASSETS_DIR="$BATS_TEST_TMPDIR/assets"
}

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------

@test "exits 2 for unknown CLI argument" {
  run "$DETECT_UPDATES" foobar
  [ "$status" -eq 2 ]
  assert_output --partial "Unknown CLI"
}

# ---------------------------------------------------------------------------
# CLI not found
# ---------------------------------------------------------------------------

@test "skips CLI when command not found" {
  # No mock created — codex is not on PATH
  run "$DETECT_UPDATES" codex
  assert_success
  assert_output --partial "SKIP:"
}

# ---------------------------------------------------------------------------
# New snapshot (no previous)
# ---------------------------------------------------------------------------

@test "creates new snapshot when none exists" {
  create_mock_cli codex
  run "$DETECT_UPDATES" codex
  assert_failure  # exit 1 = changes detected
  assert_output --partial "NEW: codex"
  # Snapshot file should exist with expected sections
  [ -f "$ASSETS_DIR/codex-snapshot.txt" ]
  grep -q "=== VERSION ===" "$ASSETS_DIR/codex-snapshot.txt"
  grep -q "=== HELP ===" "$ASSETS_DIR/codex-snapshot.txt"
}

# ---------------------------------------------------------------------------
# ANSI stripping
# ---------------------------------------------------------------------------

@test "strips ANSI escape codes from snapshot" {
  # Create a mock that outputs ANSI-colored text
  cat > "$BATS_TEST_TMPDIR/bin/codex" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  --version) printf '\033[31mcodex 1.0.0\033[0m\n' ;;
  --help)    printf '\033[32mUsage: codex\033[0m\n' ;;
esac
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/codex"

  run "$DETECT_UPDATES" codex
  assert_failure  # NEW snapshot

  # Snapshot should contain clean text without ANSI codes
  grep -q "codex 1.0.0" "$ASSETS_DIR/codex-snapshot.txt"
  # Verify no ANSI escape sequences remain (use $'\x1b' for portability — BSD grep lacks -P)
  run grep -c $'\x1b' "$ASSETS_DIR/codex-snapshot.txt"
  assert_failure
}

# ---------------------------------------------------------------------------
# Changed output
# ---------------------------------------------------------------------------

@test "reports CHANGED when output differs from snapshot" {
  create_mock_cli codex

  # Create an old snapshot with different content
  cat > "$ASSETS_DIR/codex-snapshot.txt" <<'EOF'
=== VERSION ===
codex 0.9.0

=== HELP ===
Old help text
EOF

  run "$DETECT_UPDATES" codex
  assert_failure
  assert_output --partial "CHANGED: codex"
}

# ---------------------------------------------------------------------------
# No change
# ---------------------------------------------------------------------------

@test "reports no change when output matches snapshot" {
  create_mock_cli codex

  # Run once to create the snapshot
  run "$DETECT_UPDATES" codex
  assert_failure  # NEW

  # Run again — same mock output, should match
  run "$DETECT_UPDATES" codex
  assert_success
  refute_output --partial "CHANGED"
  refute_output --partial "NEW"
}

# ---------------------------------------------------------------------------
# LAST_RELEASE metadata preservation
# ---------------------------------------------------------------------------

@test "preserves LAST_RELEASE metadata across updates" {
  create_mock_cli codex

  # Create an old snapshot with LAST_RELEASE metadata and different content
  cat > "$ASSETS_DIR/codex-snapshot.txt" <<'EOF'
=== VERSION ===
codex 0.9.0

=== HELP ===
Old help text
LAST_RELEASE=v1.2.3
EOF

  run "$DETECT_UPDATES" codex
  assert_failure  # CHANGED

  # Updated snapshot should contain the LAST_RELEASE line
  grep -q "LAST_RELEASE=v1.2.3" "$ASSETS_DIR/codex-snapshot.txt"
}

@test "LAST_RELEASE is filtered during comparison" {
  create_mock_cli codex

  # Run once to create snapshot
  run "$DETECT_UPDATES" codex
  assert_failure  # NEW

  # Append LAST_RELEASE to snapshot (content otherwise identical)
  echo 'LAST_RELEASE=v1.0.0' >> "$ASSETS_DIR/codex-snapshot.txt"

  # Should still report no change since LAST_RELEASE is filtered before diff
  run "$DETECT_UPDATES" codex
  assert_success
}
