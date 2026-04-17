#!/usr/bin/env python3
"""Compatibility wrapper to update database dependencies/config in database.txt.

This script forwards to update_database.py and defaults to writing shared config,
which matches teams that treat database.txt as the session-level dependency/config source.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    update_database_script = script_dir / "update_database.py"

    # Keep defaults aligned with the described workflow: update database.txt unless overridden.
    user_args = sys.argv[1:]
    if "--target" not in user_args and "--config" not in user_args and "--base-config" not in user_args:
        user_args = ["--target", "shared", *user_args]

    command = [sys.executable, str(update_database_script), *user_args]
    completed = subprocess.run(command, check=False)
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
