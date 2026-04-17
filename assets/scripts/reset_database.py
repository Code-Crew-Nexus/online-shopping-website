#!/usr/bin/env python3
"""Reset user-generated data (orders and registered users) for FlipZon."""

from __future__ import annotations

import argparse
import getpass
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

DEFAULT_CONFIG_PATH = Path(__file__).resolve().parent / "database.txt"
DEFAULT_LOCAL_CONFIG_PATH = Path(__file__).resolve().parent / "database.local.txt"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Clear user-generated data from database (orders + users)."
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        help="Path to shared database config JSON",
    )
    parser.add_argument(
        "--local-config",
        type=Path,
        default=DEFAULT_LOCAL_CONFIG_PATH,
        help="Optional local config JSON override",
    )
    parser.add_argument("--root-password", default="", help="MySQL root/admin password")
    parser.add_argument(
        "--include-admins",
        action="store_true",
        help="Also delete admin users (default deletes USER role only)",
    )
    parser.add_argument("--force", action="store_true", help="Skip interactive confirmation")
    parser.add_argument("--dry-run", action="store_true", help="Print SQL only")
    return parser.parse_args()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_config(path: Path, local_path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {path}")

    data = load_json(path)
    if local_path.exists():
        data.update(load_json(local_path))

    required = ["db_host", "db_port", "db_name", "root_user"]
    missing = [k for k in required if k not in data]
    if missing:
        raise ValueError(f"Missing keys in config: {', '.join(missing)}")
    return data


def validate_identifier(label: str, value: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise ValueError(f"{label} can only contain letters, numbers, and underscore")
    return value


def build_sql(db_name: str, include_admins: bool) -> str:
    delete_users_sql = "DELETE FROM users;" if include_admins else (
        "DELETE FROM users WHERE UPPER(COALESCE(role, 'USER')) = 'USER';"
    )

    return f"""
USE {db_name};
START TRANSACTION;

DELETE FROM orders;
{delete_users_sql}

ALTER TABLE orders AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;

COMMIT;

SELECT 'orders_remaining' AS metric, COUNT(*) AS value FROM orders
UNION ALL
SELECT 'users_remaining', COUNT(*) FROM users;
""".strip()


def main() -> int:
    args = parse_args()

    cfg = load_config(args.config.resolve(), args.local_config.resolve())
    db_name = validate_identifier("db_name", str(cfg["db_name"]))
    sql = build_sql(db_name, args.include_admins)

    if args.dry_run:
        print(sql)
        return 0

    if not args.force:
        print(f"WARNING: This will permanently delete user-generated data from '{db_name}'.")
        if args.include_admins:
            print("It will delete ALL users (including admins) and ALL orders.")
        else:
            print("It will delete USER role accounts and ALL orders.")
        confirmation = input("Type RESET to continue: ").strip()
        if confirmation != "RESET":
            print("Cancelled. No data was changed.")
            return 0

    if shutil.which("mysql") is None:
        print("[error] mysql command not found in PATH")
        return 1

    root_password = args.root_password or getpass.getpass("MySQL root/admin password: ")

    command = [
        "mysql",
        "--protocol=tcp",
        "-h",
        str(cfg["db_host"]),
        "-P",
        str(cfg["db_port"]),
        "-u",
        str(cfg["root_user"]),
        f"-p{root_password}",
    ]

    completed = subprocess.run(command, input=sql, text=True, check=False)
    if completed.returncode != 0:
        print("[error] Failed to reset database records.")
        return completed.returncode

    print("[ok] Reset complete.")
    print("[ok] Orders cleared and user-entered accounts removed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
