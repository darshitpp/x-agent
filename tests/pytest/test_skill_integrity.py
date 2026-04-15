"""Tests that skill-local copies stay in sync with canonical sources."""

import re
import shutil
import tempfile

import pytest
from pathlib import Path

from conftest import REPO_ROOT

SKILL_DIRS = ["codex", "cursor", "claude", "gemini", "junie", "qwen", "opencode"]

SHARED_FILES = [
    "references/shared-procedure.md",
    "assets/result-template.md",
]


class TestDriftDetection:
    """Verify skill-local copies match the canonical repo-root sources."""

    @pytest.mark.parametrize("skill", SKILL_DIRS)
    @pytest.mark.parametrize("shared_file", SHARED_FILES)
    def test_shared_file_matches_canonical(self, skill, shared_file):
        canonical = (REPO_ROOT / shared_file).read_text()
        local = (REPO_ROOT / skill / shared_file).read_text()
        assert local == canonical, (
            f"{skill}/{shared_file} has drifted from the canonical {shared_file}. "
            f"Update by copying: cp {shared_file} {skill}/{shared_file}"
        )

    @pytest.mark.parametrize("skill", SKILL_DIRS)
    def test_cli_reference_matches_canonical(self, skill):
        filename = f"cli-{skill}.md"
        canonical = (REPO_ROOT / "references" / filename).read_text()
        local = (REPO_ROOT / skill / "references" / filename).read_text()
        assert local == canonical, (
            f"{skill}/references/{filename} has drifted from references/{filename}. "
            f"Update by copying: cp references/{filename} {skill}/references/{filename}"
        )


class TestInstallability:
    """Verify each skill is self-contained — all referenced files resolve."""

    # Pattern to match relative file paths in Read instructions:
    # "Read `references/foo.md`" or "Read references/foo.md"
    PATH_PATTERN = re.compile(
        r'(?:Read\s+)?[`"\']?((?:references|assets)/[\w./-]+\.md)[`"\']?'
    )

    def _collect_references(self, skill_dir: Path) -> set[str]:
        """Scan all .md files in skill_dir for relative path references."""
        refs = set()
        for md_file in skill_dir.rglob("*.md"):
            content = md_file.read_text()
            refs.update(self.PATH_PATTERN.findall(content))
        return refs

    @pytest.mark.parametrize("skill", SKILL_DIRS)
    def test_skill_is_self_contained(self, skill):
        skill_src = REPO_ROOT / skill

        # Copy skill directory to isolated temp location
        with tempfile.TemporaryDirectory() as tmpdir:
            isolated = Path(tmpdir) / skill
            shutil.copytree(skill_src, isolated)

            refs = self._collect_references(isolated)
            assert refs, f"No file references found in {skill}/ — check PATH_PATTERN"

            missing = [ref for ref in refs if not (isolated / ref).exists()]
            assert not missing, (
                f"{skill}/ is not self-contained. Missing files: {missing}"
            )
