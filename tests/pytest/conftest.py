import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


@pytest.fixture
def repo_root():
    return REPO_ROOT


@pytest.fixture
def run_validator():
    """Run validate-metadata.py with given name and description, return CompletedProcess."""
    script = REPO_ROOT / "scripts" / "validate-metadata.py"

    def _run(name: str, description: str):
        return subprocess.run(
            ["python3", str(script), "--name", name, "--description", description],
            capture_output=True,
            text=True,
        )

    return _run
