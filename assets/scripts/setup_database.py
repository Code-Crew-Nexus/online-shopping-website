#!/usr/bin/env python3
"""Set up MySQL database and app user from assets/scripts/database.txt."""

from __future__ import annotations

import argparse
import getpass
import json
import re
import shutil
import subprocess
from pathlib import Path

DEFAULT_CONFIG_PATH = Path(__file__).resolve().parent / "database.txt"
DEFAULT_LOCAL_CONFIG_PATH = Path(__file__).resolve().parent / "database.local.txt"
DEFAULT_PRODUCTS_PATH = Path(__file__).resolve().parents[1] / "data" / "products.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create MySQL DB and user from database.txt")
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        help="Path to the shared database.txt (JSON format)",
    )
    parser.add_argument(
        "--local-config",
        type=Path,
        default=DEFAULT_LOCAL_CONFIG_PATH,
        help="Optional local override file (kept out of git)",
    )
    parser.add_argument(
        "--products",
        type=Path,
        default=DEFAULT_PRODUCTS_PATH,
        help="Path to products.json used to seed the products table",
    )
    parser.add_argument("--root-password", default="", help="MySQL root/admin password")
    parser.add_argument("--dry-run", action="store_true", help="Print SQL but do not execute")
    return parser.parse_args()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_config(path: Path, local_path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {path}")

    data = load_json(path)
    if local_path.exists():
        data.update(load_json(local_path))

    required = ["db_host", "db_port", "db_name", "app_user", "app_password", "root_user"]
    missing = [k for k in required if k not in data]
    if missing:
        raise ValueError(f"Missing keys in config: {', '.join(missing)}")
    return data


def escape_sql_string(value: str) -> str:
    return value.replace("\\", "\\\\").replace("'", "''")


def validate_identifier(label: str, value: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise ValueError(f"{label} can only contain letters, numbers, and underscore.")
    return value


def load_products(path: Path) -> list[dict]:
    if not path.exists():
        return []
    data = json.loads(path.read_text(encoding="utf-8"))
    return data if isinstance(data, list) else []


def build_seed_products_sql(products: list[dict]) -> str:
    if not products:
        return ""

    rows = []
    for product in products:
        rows.append(
            "({id}, '{name}', {price}, '{description}', '{image_url}')".format(
                id=int(product["id"]),
                name=escape_sql_string(str(product.get("name", ""))),
                price=float(product.get("price", 0)),
                description=escape_sql_string(str(product.get("description", ""))),
                image_url=escape_sql_string(str(product.get("imageUrl", ""))),
            )
        )

    return """
INSERT INTO products (id, name, price, description, image_url)
VALUES
    {rows}
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    price = VALUES(price),
    description = VALUES(description),
    image_url = VALUES(image_url);
""".strip().format(rows=",\n    ".join(rows))


def build_sql(cfg: dict, products: list[dict]) -> str:
    db_name = validate_identifier("db_name", str(cfg["db_name"]))
    app_user = validate_identifier("app_user", str(cfg["app_user"]))
    app_password = escape_sql_string(str(cfg["app_password"]))
    products_sql = build_seed_products_sql(products)

    sections = [f"""
CREATE DATABASE IF NOT EXISTS {db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '{app_user}'@'localhost' IDENTIFIED BY '{app_password}';
GRANT ALL PRIVILEGES ON {db_name}.* TO '{app_user}'@'localhost';
FLUSH PRIVILEGES;
USE {db_name};

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'USER'
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    p_id INT NOT NULL,
    u_id INT NOT NULL,
    o_quantity INT NOT NULL,
    o_date VARCHAR(20) NOT NULL,
    o_address VARCHAR(255),
    FOREIGN KEY (p_id) REFERENCES products(id),
    FOREIGN KEY (u_id) REFERENCES users(id)
);
""".strip()]

    if products_sql:
        sections.append(products_sql)

    return "\n\n".join(sections)


def main() -> int:
    args = parse_args()
    cfg = load_config(args.config.resolve(), args.local_config.resolve())
    products = load_products(args.products.resolve())
    sql = build_sql(cfg, products)

    if args.dry_run:
        print(sql)
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
        print("[error] Failed to set up database.")
        return completed.returncode

    print("[ok] Database setup completed.")
    if products:
        print(f"[ok] Seeded {len(products)} products into the products table.")
    print("[info] Suggested environment variables:")
    print(f"  SHOP_DB_HOST={cfg['db_host']}")
    print(f"  SHOP_DB_PORT={cfg['db_port']}")
    print(f"  SHOP_DB_NAME={cfg['db_name']}")
    print(f"  SHOP_DB_USER={cfg['app_user']}")
    print(f"  SHOP_DB_PASSWORD={cfg['app_password']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
