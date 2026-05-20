"""Test configuration and shared fixtures."""

import pytest


@pytest.fixture
def sample_config():
    """Return a sample configuration dict."""
    return {
        "sip_port": 5060,
        "rtp_start": 10000,
        "rtp_end": 10100,
        "redis_url": "redis://localhost:6379",
        "log_level": "INFO",
    }
