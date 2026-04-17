<div align="center">

# Logistics & E-Commerce Management System

![Project Status: Active](https://img.shields.io/badge/status-active-brightgreen)
![Platform: Windows + Linux](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![Build: Maven WAR](https://img.shields.io/badge/build-Maven-orange)
![Java](https://img.shields.io/badge/Java-25-red)

![GitHub forks](https://img.shields.io/github/forks/Code-Crew-Nexus/online-shopping-website?style=social)
![GitHub stars](https://img.shields.io/github/stars/Code-Crew-Nexus/online-shopping-website?style=social)
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

This repository is packaged as a Maven WAR project named `OnlineShopping`.

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
|- docs/
|  |- requirements.txt
|  |- setup_dependencies.py
|  `- update_requirements.py
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
         |- css/style.css
         `- WEB-INF/web.xml
```

### Notes on Structure

- `src/main/java/com/example/onlineshopping/model/` contains POJOs (`User`, `Product`, `Cart`, `Order`)
- `Cart` and `Order` use inheritance from `Product`
- `src/main/java/com/example/onlineshopping/dao/` isolates SQL operations (`UserDAO`, `ProductDAO`, `OrderDAO`)
- `src/main/java/com/example/onlineshopping/util/DBConnection.java` centralizes DB connectivity
- `src/main/webapp/` contains JSP pages for UI and request flow

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
- Java JDK (target currently configured as Java 25 in `pom.xml`)
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

> Note: If your local JDK is lower than 25 (for example Java 17), update `maven.compiler.source` and `maven.compiler.target` in `pom.xml` accordingly.

---

## Repository Setup

### Clone the Repository

```bash
git clone https://github.com/Code-Crew-Nexus/online-shopping-website.git
cd online-shopping-website
```

---

## Docs Dependency Automation

The `docs/` folder includes Python scripts for managing dependency setup and ongoing requirement updates.

### 1. Setup dependencies from requirements

```powershell
py -3 docs/setup_dependencies.py
```

Dry run preview:

```powershell
py -3 docs/setup_dependencies.py --dry-run
```

### 2. Update requirements for new implementations

Append new packages:

```powershell
py -3 docs/update_requirements.py --mode append --packages requests==2.32.3
```

Overwrite requirements completely:

```powershell
py -3 docs/update_requirements.py --mode overwrite --packages flask==3.1.0 requests==2.32.3
```

Overwrite from current environment (`pip freeze`):

```powershell
py -3 docs/update_requirements.py --mode overwrite --from-freeze
```

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

This generates `target/OnlineShopping-1.0-SNAPSHOT.war`.

### Option B: Maven installed globally

```powershell
mvn clean package
```

### Deploy on Tomcat

1. Copy `target/OnlineShopping-1.0-SNAPSHOT.war` into Tomcat `webapps/`
2. Start Tomcat
3. Open:
   - `http://localhost:8080/OnlineShopping-1.0-SNAPSHOT/index.jsp` (registration)
   - `http://localhost:8080/OnlineShopping-1.0-SNAPSHOT/login.jsp` (login)

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

## Database Setup

The app expects a MySQL database named `shop_db` (based on `DBConnection.java`).

### 1. Create database and tables

```sql
CREATE DATABASE IF NOT EXISTS shop_db;
USE shop_db;

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
    o_id INT PRIMARY KEY AUTO_INCREMENT,
    p_id INT NOT NULL,
    u_id INT NOT NULL,
    o_quantity INT NOT NULL,
    o_date VARCHAR(20) NOT NULL,
    o_address VARCHAR(255),
    FOREIGN KEY (p_id) REFERENCES products(id),
    FOREIGN KEY (u_id) REFERENCES users(id)
);
```

### 2. Seed sample products

```sql
INSERT INTO products (id, name, price, description, image_url) VALUES
(1, 'Container A', 120.00, 'Standard dry container', NULL),
(2, 'Container B', 250.00, 'Refrigerated container', NULL),
(3, 'Pallet Bundle', 75.50, 'Bulk pallet pack', NULL)
ON DUPLICATE KEY UPDATE name = VALUES(name), price = VALUES(price);
```

### 3. Configure DB credentials

Update `src/main/java/com/example/onlineshopping/util/DBConnection.java` if needed:

- URL: `jdbc:mysql://localhost:3306/shop_db`
- Username/password: your local MySQL credentials

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
- Database connection settings are hardcoded in `DBConnection.java`.
- `CheckOutServlet` currently writes a static shipping address (`Hyderabad Hub (PBL Demo)`).
- Developed as part of Year II, Semester 2 PBL (Problem-Based Learning) coursework.

