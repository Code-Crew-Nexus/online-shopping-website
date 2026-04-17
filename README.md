<div align="center">

# FlipZon

![Project Status: Active](https://img.shields.io/badge/status-active-brightgreen)
![Platform: Windows + Linux](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![Build: Maven WAR](https://img.shields.io/badge/build-Maven-orange)
![Java](https://img.shields.io/badge/Java-17--26-red)

![GitHub forks](https://img.shields.io/github/forks/Code-Crew-Nexus/online-shopping-website?style=social)
![GitHub stars](https://img.shields.io/github/stars/Code-Crew-Nexus/online-shopping-website?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/Code-Crew-Nexus/online-shopping-website?style=social)

---

## Languages & Tools

![Java](https://img.shields.io/badge/Java-17--26-red?logo=openjdk&logoColor=white)
![Jakarta Servlet](https://img.shields.io/badge/Jakarta%20Servlet-6.0.0-orange)
![JSP](https://img.shields.io/badge/JSP-View%20Layer-blue)
![JDBC](https://img.shields.io/badge/JDBC-MySQL-informational)
![MySQL](https://img.shields.io/badge/MySQL-Connector%2FJ%209.6.0-4479A1?logo=mysql&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-WAR-C71A36?logo=apachemaven&logoColor=white)
![Tomcat](https://img.shields.io/badge/Tomcat-10.1%2B-F8DC75?logo=apachetomcat&logoColor=black)

</div>

---

## Overview

A Java web application (J2EE-style) that simulates an e-commerce and logistics flow: user registration, login, product browsing, cart/session management, and checkout with persistent order storage in MySQL.

This repository is packaged as a Maven WAR project named `flipzon`.

---

## What It Does

- Handles user registration and login with `HttpSession` tracking
- Loads and displays a product catalog from MySQL
- Maintains a session-based shopping cart (`cart-list`) across requests
- Executes checkout by persisting orders to the `orders` table
- Uses a clean MVC + DAO architecture with JSP views, Servlet controllers, and JDBC data access

---

## Project Structure

```text
online-shopping-website/
|- pom.xml
|- mvnw / mvnw.cmd
|- assets/
|  |- data/
|  |  `- products.json
|  |- scripts/
|  |  |- requirements.txt
|  |  |- setup_dependencies.py
|  |  |- update_requirements.py
|  |  |- database.txt
|  |  |- database.local.txt (optional, local only)
|  |  |- setup_database.py
|  |  |- update_database.py
|  |  `- setup-database.ps1
|  `- webapp/
|     |- css/style.css
|     |- js/theme.js
|     `- images/
`- src/
   `- main/
      |- java/com/example/onlineshopping/
      |  |- AddToCartServlet.java
      |  |- CheckOutServlet.java
      |  |- LoginServlet.java
      |  |- LogoutServlet.java
      |  |- ProductServlet.java
      |  |- RegisterServlet.java
      |  |- RemoveFromCartServlet.java
      |  |- dao/
      |  |  |- OrderDAO.java
      |  |  |- ProductDAO.java
      |  |  `- UserDAO.java
      |  |- model/
      |  |  |- Cart.java
      |  |  |- Order.java
      |  |  |- Product.java
      |  |  `- User.java
      |  `- util/
      |     `- DBConnection.java
      `- webapp/
         |- index.jsp
         |- login.jsp
         |- products.jsp
         |- cart.jsp
         |- orders.jsp
         `- WEB-INF/web.xml
```

### Notes on Structure

- `src/main/java/com/example/onlineshopping/model/` contains POJOs (`User`, `Product`, `Cart`, `Order`)
- `Cart` and `Order` use inheritance from `Product`
- `src/main/java/com/example/onlineshopping/dao/` isolates SQL operations (`UserDAO`, `ProductDAO`, `OrderDAO`)
- `src/main/java/com/example/onlineshopping/util/DBConnection.java` centralizes DB connectivity
- `src/main/webapp/` contains JSP pages and servlet mappings
- `assets/webapp/` stores static resources (`css`, `js`, `images`) copied into WAR at build time under `/assets`
- `assets/data/` stores JSON application data copied to classpath at build time
- `assets/scripts/` stores dependency and database automation scripts

---

## Technical Architecture (MVC + DAO)

- **Model**: POJOs in `src/main/java/com/example/onlineshopping/model/`
  - `User`, `Product`, `Cart`, `Order`
  - `Cart` and `Order` extend `Product`
- **View**: JSP pages in `src/main/webapp/`
  - `index.jsp`, `login.jsp`, `products.jsp`, `cart.jsp`, `orders.jsp`
- **Controller**: Servlets in `src/main/java/com/example/onlineshopping/`
  - `RegisterServlet`, `LoginServlet`, `ProductServlet`, `AddToCartServlet`, `CheckOutServlet`, `LogoutServlet`, `RemoveFromCartServlet`
- **DAO layer**: JDBC data operations in `src/main/java/com/example/onlineshopping/dao/`
  - `UserDAO`, `ProductDAO`, `OrderDAO`
- **DB Utility**: `DBConnection` in `src/main/java/com/example/onlineshopping/util/`

---

## Requirements

To build and run this project successfully, ensure the following prerequisites are installed and configured:

### General

- A working `git` installation
- Java JDK **17, 21, 24, 25, or 26**
- Maven Wrapper (`mvnw` / `mvnw.cmd`) or Maven installed globally
- MySQL server running locally
- Apache Tomcat 10.1+ for deployment

### On Linux (Arch/Ubuntu)

- OpenJDK (version matching project target)
- Maven and Git
- MySQL Server

Example:

```bash
# Arch
sudo pacman -S jdk-openjdk maven git mysql

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk maven git mysql-server
```

### On Windows 11

- JDK installed and added to `PATH`
- Maven (optional if using Maven Wrapper)
- MySQL Server and Workbench (optional)
- PowerShell terminal

### Optional Tools

- VS Code / IntelliJ IDEA
- GitHub Desktop
- Postman (for endpoint testing)

### Java Compatibility Policy

- This project now supports building with **JDK 17 through JDK 26**.
- `pom.xml` enforces allowed JDK versions via Maven Enforcer range: `[17,27)`.
- Compilation target is Java 17 bytecode (`maven.compiler.release=17`) for broader runtime compatibility.
- You can still override compiler release if needed:

```powershell
.\mvnw.cmd -Dmaven.compiler.release=21 clean package
```

---

## Repository Setup

### Clone the Repository

```bash
git clone <your-repository-url>
cd online-shopping-website
```

---

## Script Automation

The `assets/scripts/` folder includes Python and PowerShell scripts for dependency and database automation.

### 1. Setup dependencies from requirements

```powershell
py -3 assets/scripts/setup_dependencies.py
```

Dry run preview:

```powershell
py -3 assets/scripts/setup_dependencies.py --dry-run
```

### 2. Update requirements for new implementations

Append new packages:

```powershell
py -3 assets/scripts/update_requirements.py --mode append --packages requests==2.32.3
```

Overwrite requirements completely:

```powershell
py -3 assets/scripts/update_requirements.py --mode overwrite --packages flask==3.1.0 requests==2.32.3
```

Overwrite from current environment (`pip freeze`):

```powershell
py -3 assets/scripts/update_requirements.py --mode overwrite --from-freeze
```

### 3. Database scripts (new)

- `assets/scripts/database.txt`: shared default DB config committed to git
- `assets/scripts/database.local.txt`: optional local override file for each contributor, ignored by git
- `assets/scripts/setup_database.py`: reads shared config + local override, then creates DB, user, tables, and seeds products
- `assets/scripts/update_database.py`: updates DB config from env/CLI and can write either local or shared target
- `assets/scripts/update_dependencies.py`: compatibility wrapper that updates shared `database.txt` by default
- `assets/scripts/setup-database.ps1`: PowerShell setup option for Windows with the same shared + local config merge

---

## Cross-Platform Git Line Endings

This project includes `.gitattributes` to reduce CRLF/LF conflicts between Windows 11 and Arch Linux:

- LF is enforced for source/config/documentation files (`.java`, `.jsp`, `.xml`, `.md`, `.py`, etc.)
- CRLF is enforced for Windows command scripts (`.bat`, `.cmd`, `.ps1`)
- Binary assets are marked as binary to avoid EOL conversions

---

## Compilation & Execution

### Option A: Maven Wrapper

```powershell
.\mvnw.cmd clean package
```

This generates `target/flipzon-1.0-SNAPSHOT.war`.

### Option B: Maven installed globally

```powershell
mvn clean package
```

### Deploy on Tomcat

1. Copy `target/flipzon-1.0-SNAPSHOT.war` into Tomcat `webapps/`
2. Start Tomcat
3. Open:
  - `http://localhost:8080/flipzon-1.0-SNAPSHOT/index.jsp` (registration)
  - `http://localhost:8080/flipzon-1.0-SNAPSHOT/login.jsp` (login)

---

## Servlet Endpoints

- `POST /register` -> register a new user
- `POST /login` -> authenticate and create session
- `GET /products` -> load products and forward to `products.jsp`
- `GET /add-to-cart?id=<productId>` -> add/increment cart item in session
- `GET /cart-check-out` -> persist orders from cart
- `GET /logout` -> invalidate session

---

## Main Logic of the Code

The request lifecycle follows:

1. User authenticates (`LoginServlet`) and session stores `authUser`
2. Product catalog is fetched via `ProductDAO` and rendered by `products.jsp`
3. Cart operations mutate `cart-list` inside `HttpSession`
4. Checkout iterates cart lines and persists each order through `OrderDAO`
5. Orders are displayed in `orders.jsp` for authenticated users

---

## Database Setup (Automated)

### Why credentials should not be hardcoded

Hardcoding database credentials creates security and portability problems:

- Personal usernames/passwords get exposed in Git history.
- Every contributor must edit source code before running.
- CI/CD and deployment environments cannot inject their own secrets cleanly.

This project now uses environment variables with project-scoped defaults in `DBConnection.java`.

`assets/scripts/database.txt` is safe to keep in the repo as a shared template because it contains project defaults, not personal machine secrets. If a contributor needs different local values, they should create `assets/scripts/database.local.txt` instead of editing the tracked file.

### Environment variables used by the app

- `SHOP_DB_HOST` (default: `localhost`)
- `SHOP_DB_PORT` (default: `3306`)
- `SHOP_DB_NAME` (default: `flipzon_shop`)
- `SHOP_DB_USER` (default: `flipzon_app`)
- `SHOP_DB_PASSWORD` (default: `flipzon_app_password`)

### One-command database bootstrap script (Windows PowerShell)

Run from project root:

```powershell
.\assets\scripts\setup-database.ps1
```

What this script does:

- Creates database `flipzon_shop`
- Creates app user `flipzon_app`
- Grants required privileges on project database
- Creates tables: `users`, `products`, `orders`
- Seeds the `products` table from `assets/data/products.json` so checkout works on a fresh clone

You can override defaults while running:

```powershell
.\assets\scripts\setup-database.ps1 -RootUser root -DbHost localhost -Port 3306 -DbName flipzon_shop -AppUser flipzon_app -AppPassword flipzon_app_password
```

### Python database setup/update workflow

1. Review the shared defaults:

```powershell
notepad .\assets\scripts\database.txt
```

2. Optional: create a machine-specific override without changing the tracked file:

```powershell
py -3 .\assets\scripts\update_database.py
```

This writes `assets/scripts/database.local.txt`, which is ignored by git.

3. Optional: update shared `database.txt` for your current system session flow:

```powershell
py -3 .\assets\scripts\update_dependencies.py --probe-mysql
```

Use this only when shared defaults should be refreshed.

4. Apply setup from the merged config:

```powershell
py -3 .\assets\scripts\setup_database.py
```

5. Optional: probe current MySQL instance and annotate your local override:

```powershell
py -3 .\assets\scripts\update_database.py --probe-mysql
```

In IntelliJ, run these commands in the built-in Terminal from the project root using PowerShell.

After script execution, persist env vars (new terminal required):

```powershell
setx SHOP_DB_HOST localhost
setx SHOP_DB_PORT 3306
setx SHOP_DB_NAME flipzon_shop
setx SHOP_DB_USER flipzon_app
setx SHOP_DB_PASSWORD flipzon_app_password
```

### Manual SQL alternative (if not using script)

```sql
CREATE DATABASE IF NOT EXISTS flipzon_shop;
USE flipzon_shop;

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
```

### Product data note

- Product catalog is JSON-first (`assets/data/products.json`) with DB fallback.
- The setup scripts also seed the `products` table from that JSON so the `orders` foreign key works correctly on a new local database.
- User and order persistence still use MySQL.

---

## Test

```powershell
.\mvnw.cmd test
```

---

## Key Features

- **Session state management**: Stores cart in `HttpSession` as `ArrayList<Cart>`
- **Session guarding**: `products.jsp` and `cart.jsp` redirect unauthenticated users to `login.jsp`
- **Checkout workflow**: Creates an order record for each cart line item and clears the session cart after success
- **DAO abstraction**: SQL logic isolated in DAO classes
- **OOP modeling**: Inheritance used in `Cart` and `Order`

---

## Conclusion

This project demonstrates end-to-end enterprise web application fundamentals using Java Servlets, JSP, JDBC, and MySQL. It is designed for academic learning and practical understanding of MVC/DAO architecture, session management, and order processing workflows.

---

## Contributors

- M. Sai Krishna
- Md. Abdul Rayain
- Rishit Ghosh
- Y. Karthik

> Future contributors welcome! Fork the repo, submit pull requests, and help improve the project.

---

## Notes

- Passwords are currently stored in plain text (for academic/demo use). In production, use hashing (for example, BCrypt).
- Database connection settings are read from environment variables in `DBConnection.java`.
- `CheckOutServlet` currently writes a static shipping address (`Hyderabad Hub (PBL Demo)`).
- Developed as part of Year II, Semester 2 PBL (Problem-Based Learning) coursework.
