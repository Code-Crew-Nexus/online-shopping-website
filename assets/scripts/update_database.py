#!/usr/bin/env python3
"""Update database config from environment, CLI overrides, and optional MySQL probe."""

from __future__ import annotations

import argparse
import getpass
import json
import os
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
import re

DEFAULT_BASE_CONFIG_PATH = Path(__file__).resolve().parent / "database.txt"
DEFAULT_LOCAL_CONFIG_PATH = Path(__file__).resolve().parent / "database.local.txt"
VALID_NAME_PATTERN = re.compile(r"[A-Za-z0-9_]+")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Refresh database config from local setup")
    parser.add_argument(
        "--base-config",
        type=Path,
        default=DEFAULT_BASE_CONFIG_PATH,
        help="Path to the shared database.txt",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_LOCAL_CONFIG_PATH,
        help="Path to the local override config to write",
    )
    parser.add_argument(
        "--target",
        choices=["local", "shared"],
        default="local",
        help="Write target: local (database.local.txt) or shared (database.txt)",
    )
    parser.add_argument("--db-host", default="", help="Override db_host")
    parser.add_argument("--db-port", type=int, default=0, help="Override db_port")
    parser.add_argument("--db-name", default="", help="Override db_name")
    parser.add_argument("--app-user", default="", help="Override app_user")
    parser.add_argument("--app-password", default="", help="Override app_password")
    parser.add_argument("--root-user", default="", help="Override root_user")
    parser.add_argument(
        "--probe-mysql",
        action="store_true",
        help="Probe local MySQL for existing databases and mark database_exists",
    )
    parser.add_argument("--root-password", default="", help="Root password for --probe-mysql")
    parser.add_argument(
        "--show-commands",
        action="store_true",
        help="Print suggested setup commands after writing config",
    )
    parser.add_argument(
        "--include-metadata",
        action="store_true",
        help="Include script metadata fields in the written config file",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_config(base_path: Path, local_path: Path) -> dict:
    cfg = {
        "db_host": "localhost",
        "db_port": 3306,
        "db_name": "flipzon_shop",
        "app_user": "flipzon_app",
        "app_password": "flipzon_app_password",
        "root_user": "root",
    }
    if base_path.exists():
        cfg.update(load_json(base_path))
    if local_path.exists():
        cfg.update(load_json(local_path))
    return cfg


def apply_env_overrides(cfg: dict) -> dict:
    mapping = {
        "SHOP_DB_HOST": "db_host",
        "SHOP_DB_PORT": "db_port",
        "SHOP_DB_NAME": "db_name",
        "SHOP_DB_USER": "app_user",
        "SHOP_DB_PASSWORD": "app_password",
    }
    for env_key, config_key in mapping.items():
        value = os.getenv(env_key)
        if value and value.strip():
            cfg[config_key] = int(value) if config_key == "db_port" else value.strip()
    return cfg


def apply_cli_overrides(cfg: dict, args: argparse.Namespace) -> dict:
    if args.db_host.strip():
        cfg["db_host"] = args.db_host.strip()
    if args.db_port > 0:
        cfg["db_port"] = args.db_port
    if args.db_name.strip():
        cfg["db_name"] = args.db_name.strip()
    if args.app_user.strip():
        cfg["app_user"] = args.app_user.strip()
    if args.app_password.strip():
        cfg["app_password"] = args.app_password
    if args.root_user.strip():
        cfg["root_user"] = args.root_user.strip()
    return cfg


def validate_config(cfg: dict) -> None:
    db_port = cfg.get("db_port")
    if not isinstance(db_port, int) or db_port <= 0:
        raise ValueError("db_port must be a positive integer")

    for key in ["db_name", "app_user"]:
        value = str(cfg.get(key, ""))
        if not VALID_NAME_PATTERN.fullmatch(value):
            raise ValueError(f"{key} can only contain letters, numbers, and underscore")


def add_metadata(cfg: dict, target_path: Path) -> dict:
    cfg["updated_at_utc"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    cfg["updated_by_script"] = Path(__file__).name
    cfg["target_file"] = str(target_path)
    return cfg


def remove_transient_fields(cfg: dict) -> dict:
    transient_keys = {
        "updated_at_utc",
        "updated_by_script",
        "target_file",
        "mysql_version",
        "detected_databases",
        "database_exists",
        "probe_status",
        "probe_error",
    }
    return {key: value for key, value in cfg.items() if key not in transient_keys}


def probe_mysql(cfg: dict, root_password: str) -> dict:
    if shutil.which("mysql") is None:
        cfg["database_exists"] = False
        cfg["probe_status"] = "mysql command not found"
        return cfg

    version_command = ["mysql", "--version"]
    version_completed = subprocess.run(version_command, capture_output=True, text=True, check=False)
    if version_completed.returncode == 0 and version_completed.stdout.strip():
        cfg["mysql_version"] = version_completed.stdout.strip()

    command = [
        "mysql",
        "--protocol=tcp",
        "-h",
        str(cfg.get("db_host", "localhost")),
        "-P",
        str(cfg.get("db_port", 3306)),
        "-u",
        str(cfg.get("root_user", "root")),
        f"-p{root_password}",
        "-Nse",
        "SHOW DATABASES;",
    ]
    completed = subprocess.run(command, capture_output=True, text=True, check=False)
    if completed.returncode != 0:
        cfg["database_exists"] = False
        cfg["probe_status"] = "probe failed"
        cfg["probe_error"] = (completed.stderr or completed.stdout).strip()[:400]
        return cfg

    databases = [line.strip() for line in completed.stdout.splitlines() if line.strip()]
    cfg["detected_databases"] = databases[:50]
    cfg["database_exists"] = cfg.get("db_name") in databases
    cfg["probe_status"] = "ok"
    return cfg


def main() -> int:
    args = parse_args()
    base_path = args.base_config.resolve()
    local_path = args.config.resolve()

    config_path = base_path if args.target == "shared" else local_path
    cfg = load_config(base_path, local_path)
    cfg = apply_env_overrides(cfg)
    cfg = apply_cli_overrides(cfg, args)

    try:
        validate_config(cfg)
    except ValueError as err:
        print(f"[error] {err}")
        return 1

    if args.probe_mysql:
        root_password = args.root_password or getpass.getpass("MySQL root/admin password: ")
        cfg = probe_mysql(cfg, root_password)

    if args.include_metadata:
        cfg = add_metadata(cfg, config_path)
    else:
        cfg = remove_transient_fields(cfg)

    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text(json.dumps(cfg, indent=2) + "\n", encoding="utf-8")
    print(f"[ok] Updated: {config_path}")

    if args.show_commands:
        print("[info] Suggested next commands:")
        print("  py -3 .\\assets\\scripts\\setup_database.py")
        print("  .\\assets\\scripts\\setup-database.ps1")

    if args.target == "shared":
        print("[warn] You updated shared database.txt. Commit only if project defaults should change.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
