"""Utility helpers for managing .env configuration values."""

from __future__ import annotations

from pathlib import Path
from typing import Dict, Mapping

from dotenv import dotenv_values, load_dotenv, set_key


ENV_PATH = Path(__file__).resolve().parent / ".env"


def load_env_values() -> Dict[str, str]:
    """Load environment values from .env into both a dict and the process."""
    if ENV_PATH.exists():
        load_dotenv(ENV_PATH, override=True)
        return {k: v for k, v in dotenv_values(ENV_PATH).items() if v is not None}
    return {}


def save_env_values(values: Mapping[str, str]) -> Dict[str, str]:
    """Persist provided key/value pairs into the .env file and reload them."""
    if not ENV_PATH.exists():
        ENV_PATH.touch()
    for key, value in values.items():
        set_key(str(ENV_PATH), key, value or "")
    return load_env_values()


def get_default_num_per_page(env_values: Mapping[str, str]) -> int:
    raw_value = env_values.get("NUM_PER_PAGE")
    if not raw_value:
        return 50
    try:
        value = int(raw_value)
    except ValueError:
        return 50
    return max(1, min(100, value))


__all__ = [
    "ENV_PATH",
    "load_env_values",
    "save_env_values",
    "get_default_num_per_page",
]
