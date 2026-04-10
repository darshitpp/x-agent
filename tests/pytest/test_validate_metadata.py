"""Tests for scripts/validate-metadata.py"""

import yaml
import pytest

from conftest import REPO_ROOT

SKILL_DIRS = ["codex", "cursor", "claude", "gemini", "junie", "qwen", "opencode"]


# ---------------------------------------------------------------------------
# Name validation
# ---------------------------------------------------------------------------

class TestNameValidation:
    def test_valid_simple_name(self, run_validator):
        result = run_validator("codex", "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_valid_hyphenated_name(self, run_validator):
        result = run_validator("my-cool-tool", "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_valid_name_with_numbers(self, run_validator):
        result = run_validator("tool2", "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_valid_single_char(self, run_validator):
        result = run_validator("a", "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_valid_exactly_64_chars(self, run_validator):
        name = "a" * 64
        result = run_validator(name, "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_invalid_name_too_long(self, run_validator):
        name = "a" * 65
        result = run_validator(name, "Delegates tasks to external CLIs.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr

    def test_invalid_uppercase(self, run_validator):
        result = run_validator("Codex", "Delegates tasks to external CLIs.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr

    def test_invalid_consecutive_hyphens(self, run_validator):
        result = run_validator("my--tool", "Delegates tasks to external CLIs.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr

    def test_invalid_leading_hyphen(self, run_validator):
        # argparse treats "-tool" as a flag (exit 2), so we just verify it's rejected
        result = run_validator("-tool", "Delegates tasks to external CLIs.")
        assert result.returncode != 0

    def test_invalid_trailing_hyphen(self, run_validator):
        result = run_validator("tool-", "Delegates tasks to external CLIs.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr

    def test_invalid_underscore(self, run_validator):
        result = run_validator("my_tool", "Delegates tasks to external CLIs.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr


# ---------------------------------------------------------------------------
# Description validation
# ---------------------------------------------------------------------------

class TestDescriptionValidation:
    def test_valid_third_person(self, run_validator):
        result = run_validator("codex", "Delegates tasks to external CLIs.")
        assert result.returncode == 0

    def test_valid_exactly_1024_chars(self, run_validator):
        desc = "x" * 1024
        result = run_validator("codex", desc)
        assert result.returncode == 0

    def test_invalid_too_long(self, run_validator):
        desc = "x" * 1025
        result = run_validator("codex", desc)
        assert result.returncode == 1
        assert "DESCRIPTION ERROR" in result.stderr

    def test_invalid_first_person_i(self, run_validator):
        result = run_validator("codex", "I delegate tasks to external CLIs.")
        assert result.returncode == 1
        assert "STYLE WARNING" in result.stderr

    def test_invalid_second_person_your(self, run_validator):
        result = run_validator("codex", "Check your code for errors.")
        assert result.returncode == 1
        assert "STYLE WARNING" in result.stderr

    def test_invalid_first_person_we(self, run_validator):
        result = run_validator("codex", "We validate plans and architecture.")
        assert result.returncode == 1
        assert "STYLE WARNING" in result.stderr

    def test_word_boundary_not_false_positive(self, run_validator):
        """'mysterious' contains 'my' but should not trigger as a standalone word."""
        result = run_validator("codex", "Mysterious tool for code analysis.")
        assert result.returncode == 0


# ---------------------------------------------------------------------------
# Combined validation
# ---------------------------------------------------------------------------

class TestCombinedValidation:
    def test_multiple_errors_reported(self, run_validator):
        result = run_validator("INVALID--NAME", "I do things for you.")
        assert result.returncode == 1
        assert "NAME ERROR" in result.stderr
        assert "STYLE WARNING" in result.stderr


# ---------------------------------------------------------------------------
# Integration: validate real SKILL.md files
# ---------------------------------------------------------------------------

def _parse_skill_frontmatter(skill_dir):
    """Parse YAML frontmatter from a SKILL.md file."""
    path = REPO_ROOT / skill_dir / "SKILL.md"
    content = path.read_text()
    # Extract between --- markers
    parts = content.split("---", 2)
    if len(parts) < 3:
        pytest.fail(f"No YAML frontmatter found in {path}")
    return yaml.safe_load(parts[1])


@pytest.mark.parametrize("skill_dir", SKILL_DIRS)
def test_real_skill_metadata_is_valid(run_validator, skill_dir):
    """Each real SKILL.md should pass validation."""
    meta = _parse_skill_frontmatter(skill_dir)
    result = run_validator(meta["name"], meta["description"])
    assert result.returncode == 0, (
        f"{skill_dir}/SKILL.md failed validation:\n{result.stderr}"
    )
