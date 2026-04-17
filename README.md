<div align="center">

# FlipZon Logistics & E-Commerce Management System

![Project Status: Active](https://img.shields.io/badge/status-active-brightgreen)
![Platform: Windows + Linux](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![Build: Maven WAR](https://img.shields.io/badge/build-Maven-orange)
![Java](https://img.shields.io/badge/Java-25-red)

![GitHub forks](https://img.shields.io/github/forks/Code-Crew-Nexus/online-shopping-website?style=social)
![GitHub stars](https://img.shields.io/github/stars/Code-Crew-Nexus/online-shopping-website?style=social&label=Stars)
![GitHub watchers](https://img.shields.io/github/watchers/Code-Crew-Nexus/online-shopping-website?style=social)

---

## Languages & Tools

![Java](https://img.shields.io/badge/Java-25-red?logo=openjdk&logoColor=white)
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

This repository is packaged as a Maven WAR project named `OnlineShopping` (artifactId: `flipzon`).

---

## What It Does

- Handles user registration and login with `HttpSession` tracking
- Loads and displays a product catalog from MySQL
- Maintains a session-based shopping cart (`cart-list`) across requests
- Executes checkout by persisting orders to the `orders` table
- Uses a clean MVC + DAO architecture with JSP views, Servlet controllers, and JDBC data access

---

## Updated Project Structure

```text
online-shopping-website/
├─ pom.xml
├─ mvnw
├─ mvnw.cmd
├─ README.md
├─ .gitignore
├─ .gitattributes
├─ assets/
│  ├─ data/
│  │  └─ products.json
│  ├─ images/
│  │  └─ flipzon-logo.svg
│  ├─ scripts/
│  │  ├─ database.txt
│  │  ├─ requirements.txt
│  │  ├─ setup-database.ps1
│  │  ├─ setup_database.py
│  │  ├─ setup_dependencies.py
│  │  ├─ update_database.py
│  │  ├─ update_dependencies.py
│  │  └─ update_requirements.py
│  └─ webapp/
│     ├─ css/
│     │  └─ style.css
│     ├─ images/
│     │  ├─ box1.png
│     │  ├─ box2.png
│     │  ├─ flipzon-logo.svg
│     │  ├─ headphones.png
│     │  ├─ hub.png
│     │  ├─ keyboard.png
│     │  ├─ multimeter.png
│     │  ├─ phone.png
│     │  └─ transformer.png
│     └─ js/
│        └─ theme.js
├─ src/
│  └─ main/
│     ├─ java/com/example/onlineshopping/
│     │  ├─ AddToCartServlet.java
│     │  ├─ CheckOutServlet.java
│     │  ├─ LoginServlet.java
│     │  ├─ LogoutServlet.java
│     │  ├─ OrdersServlet.java
│     │  ├─ ProductServlet.java
│     │  ├─ RegisterServlet.java
│     │  ├─ RemoveFromCartServlet.java
│     │  ├─ UpdateCartServlet.java
│     │  ├─ dao/
│     │  │  ├─ OrderDAO.java
│     │  │  ├─ ProductDAO.java
│     │  │  └─ UserDAO.java
│     │  ├─ model/
│     │  │  ├─ Cart.java
│     │  │  ├─ Order.java
│     │  │  ├─ Product.java
│     │  │  └─ User.java
│     │  └─ util/
│     │     └─ DBConnection.java
│     └─ webapp/
│        ├─ index.jsp
│        ├─ login.jsp
│        ├─ products.jsp
│        ├─ cart.jsp
│        ├─ orders.jsp
│        └─ WEB-INF/
│           └─ web.xml
└─ target/                      (generated build output)
```

## Run Guide: Windows 11 (Detailed)

### 1. Install prerequisites

1. Install JDK (17 to 26) and verify:

```powershell
java -version
javac -version
```

2. Install MySQL Server 8 and confirm it is running.

3. Install Apache Tomcat 10.1+.

4. Clone project:

```powershell
git clone https://github.com/Code-Crew-Nexus/online-shopping-website.git
cd online-shopping-website
```

### 2. Setup database

Use the PowerShell setup script:

```powershell
.\assets\scripts\setup-database.ps1
```

Optional explicit config:

```powershell
.\assets\scripts\setup-database.ps1 -RootUser root -DbHost localhost -Port 3306 -DbName flipzon_shop -AppUser flipzon_app -AppPassword flipzon_app_password
```

### 3. Set environment variables

```powershell
setx SHOP_DB_HOST localhost
setx SHOP_DB_PORT 3306
setx SHOP_DB_NAME flipzon_shop
setx SHOP_DB_USER flipzon_app
setx SHOP_DB_PASSWORD flipzon_app_password
```

Close and reopen terminal/IDE after `setx`.

### 4. Build project

```powershell
.\mvnw.cmd clean package
```

WAR output:

- `target/flipzon-1.0-SNAPSHOT.war`

### 5. Deploy and run

1. Copy WAR to Tomcat `webapps/`.
2. Start Tomcat.
3. Open:

- `http://localhost:8080/flipzon-1.0-SNAPSHOT/index.jsp`

### 6. Smoke test flow

1. Register
2. Login
3. Add products to cart
4. Checkout
5. Verify grouped orders and invoice view

## Run Guide: Linux (Arch Preferred, Detailed)

### 1. Install prerequisites (Arch)

```bash
sudo pacman -Syu
sudo pacman -S jdk-openjdk git maven mysql tomcat10 python
```

Verify:

```bash
java -version
mvn -v
mysql --version
```

### 2. Configure MySQL

Initialize once if required:

```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mysqld
```

Confirm login:

```bash
mysql -u root -p
```

### 3. Clone project

```bash
git clone https://github.com/Code-Crew-Nexus/online-shopping-website.git
cd online-shopping-website
```

### 4. Setup database

```bash
python assets/scripts/setup_database.py
```

### 5. Export environment variables

```bash
export SHOP_DB_HOST=localhost
export SHOP_DB_PORT=3306
export SHOP_DB_NAME=flipzon_shop
export SHOP_DB_USER=flipzon_app
export SHOP_DB_PASSWORD=flipzon_app_password
```

Persist by adding to `~/.bashrc` or `~/.zshrc`.

### 6. Build project

```bash
./mvnw clean package
```

### 7. Deploy and run

```bash
sudo cp target/flipzon-1.0-SNAPSHOT.war /var/lib/tomcat10/webapps/
sudo systemctl restart tomcat10
```

Open:

- `http://localhost:8080/flipzon-1.0-SNAPSHOT/index.jsp`

## Endpoint Summary

- `POST /register`
- `POST /login`
- `GET /products`
- `GET /add-to-cart?id=<productId>`
- `GET /remove-from-cart?id=<productId>`
- `POST /update-cart`
- `GET /cart-check-out`
- `GET /orders`
- `GET /logout`

## Build and Validation

```bash
# Linux
./mvnw validate
./mvnw clean package

# Windows
.\mvnw.cmd validate
.\mvnw.cmd clean package
```

## Troubleshooting

### IntelliJ shows unresolved Maven plugins

1. Disable Maven offline mode.
2. Use Maven Wrapper in IntelliJ Maven settings.
3. Reload Maven projects.
4. Run:

```powershell
.\mvnw.cmd -U validate
```

5. Invalidate IntelliJ caches and restart if needed.

### Tomcat returns 404

- Use Tomcat 10.1+ only (Jakarta namespace requirement).

### Database connection errors

- Ensure MySQL service is up.
- Check environment variables.
- Re-run setup script.

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
- Database connection settings are managed in `DBConnection.java` (environment variables with defaults).
- `CheckOutServlet` currently writes a static shipping address (`Hyderabad Hub (PBL Demo)`).
- Developed as part of Year II, Semester 2 PBL (Problem-Based Learning) coursework.
