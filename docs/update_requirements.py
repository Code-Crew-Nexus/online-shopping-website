#!/usr/bin/env python3
"""Append to or overwrite docs/requirements.txt for new implementations."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Append or overwrite a requirements.txt file.")
    parser.add_argument(
        "--requirements",
        type=Path,
        default=Path(__file__).resolve().parent / "requirements.txt",
        help="Path to requirements.txt.",
    )
    parser.add_argument(
        "--mode",
        choices=["append", "overwrite"],
        required=True,
        help="Update mode.",
    )
    parser.add_argument(
        "--packages",
        nargs="*",
        default=[],
        help="Packages (for example requests==2.32.3).",
    )
    parser.add_argument(
        "--from-freeze",
        action="store_true",
        help="Use `pip freeze` output as package source (typically with --mode overwrite).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without writing.",
    )
    return parser.parse_args()


def normalized(lines: list[str]) -> list[str]:
    cleaned = []
    for line in lines:
        value = line.strip()
        if not value or value.startswith("#"):
            continue
        cleaned.append(value)
    return cleaned


def read_existing(path: Path) -> list[str]:
    if not path.exists():
        return []
    return normalized(path.read_text(encoding="utf-8").splitlines())


def read_freeze() -> list[str]:
    process = subprocess.run(
        [sys.executable, "-m", "pip", "freeze"],
        check=False,
        capture_output=True,
        text=True,
    )
    if process.returncode != 0:
        raise RuntimeError(process.stderr.strip() or "pip freeze failed")
    return normalized(process.stdout.splitlines())


def write_requirements(path: Path, packages: list[str], dry_run: bool) -> None:
    body = "\n".join(packages)
    if body:
        body += "\n"

    print(f"[info] target: {path}")
    print(f"[info] entries: {len(packages)}")

    if dry_run:
        print("[dry-run] No file changes written.")
        return

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8", newline="\n")
    print("[ok] requirements file updated.")


def main() -> int:
    args = parse_args()
    req_path = args.requirements.resolve()

    try:
        source_packages = normalized(args.packages)
        if args.from_freeze:
            source_packages = read_freeze()

        if args.mode == "overwrite":
            if not source_packages:
                print("[error] overwrite mode requires --packages or --from-freeze.")
                return 1
            final_packages = sorted(dict.fromkeys(source_packages))
            write_requirements(req_path, final_packages, args.dry_run)
            return 0

        existing = read_existing(req_path)
        final_packages = existing[:]
        for package in source_packages:
            if package not in final_packages:
                final_packages.append(package)

        write_requirements(req_path, final_packages, args.dry_run)
        return 0
    except RuntimeError as err:
        print(f"[error] {err}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
