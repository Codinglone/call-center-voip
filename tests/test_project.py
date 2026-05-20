"""Basic sanity tests for the project structure."""

import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent


def test_project_structure():
    """Verify expected directories exist."""
    expected = [
        "asterisk",
        "orchestrator",
        "chatbots",
        "shared",
        "docs",
        "scripts",
        "tests",
    ]
    for name in expected:
        assert (PROJECT_ROOT / name).is_dir(), f"Missing directory: {name}"


def test_docker_compose_exists():
    """Verify docker-compose.yml exists."""
    assert (PROJECT_ROOT / "docker-compose.yml").is_file()


def test_readme_exists():
    """Verify README.md exists."""
    assert (PROJECT_ROOT / "README.md").is_file()


def test_license_exists():
    """Verify LICENSE exists."""
    assert (PROJECT_ROOT / "LICENSE").is_file()


def test_asterisk_config_exists():
    """Verify Asterisk config directory exists."""
    config_dir = PROJECT_ROOT / "asterisk" / "config"
    assert config_dir.is_dir()
