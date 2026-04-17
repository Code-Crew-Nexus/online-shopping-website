#!/usr/bin/env python3
"""Install documentation helper dependencies from docs/requirements.txt."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install Python dependencies required by docs automation scripts.")
    parser.add_argument(
        "--requirements",
        type=Path,
        default=Path(__file__).resolve().parent / "requirements.txt",
        help="Path to the requirements.txt file.",
    )
    parser.add_argument(
        "--upgrade-pip",
        action="store_true",
        help="Upgrade pip before installing dependencies.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands without executing them.",
    )
    return parser.parse_args()


def run_command(command: list[str], dry_run: bool) -> int:
    print("[cmd]", " ".join(command))
    if dry_run:
        return 0
    completed = subprocess.run(command, check=False)
    return completed.returncode


def main() -> int:
    args = parse_args()
    requirements_path = args.requirements.resolve()

    if not requirements_path.exists():
        print(f"[error] requirements file not found: {requirements_path}")
        return 1

    if args.upgrade_pip:
        code = run_command([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], args.dry_run)
        if code != 0:
            return code

    return run_command(
        [sys.executable, "-m", "pip", "install", "-r", str(requirements_path)],
        args.dry_run,
    )


if __name__ == "__main__":
    raise SystemExit(main())
