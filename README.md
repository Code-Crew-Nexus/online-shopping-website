# Logistics & E-Commerce Management System

A Java web application (J2EE-style) that simulates an e-commerce and logistics flow: user registration, login, product browsing, cart/session management, and checkout with persistent order storage in MySQL.

This repository is packaged as a Maven WAR project named `OnlineShopping`.

## Project Overview

This project demonstrates:
- User authentication with session tracking (`authUser` in `HttpSession`)
- Product catalog loading from MySQL
- Session-based cart (`cart-list`) across multiple requests
- Checkout flow that persists orders to the `orders` table
- A clean MVC + DAO structure with JSP views, Servlet controllers, and JDBC data access

## Technical Architecture (MVC + DAO)

- **Model**: POJOs in `src/main/java/com/example/onlineshopping/model/`
  - `User`, `Product`, `Cart`, `Order`
  - `Cart` and `Order` extend `Product`
- **View**: JSP pages in `src/main/webapp/`
  - `index.jsp`, `login.jsp`, `products.jsp`, `cart.jsp`, `orders.jsp`
- **Controller**: Servlets in `src/main/java/com/example/onlineshopping/`
  - `RegisterServlet`, `LoginServlet`, `ProductServlet`, `AddToCartServlet`, `CheckOutServlet`, `LogoutServlet`
- **DAO layer**: JDBC data operations in `src/main/java/com/example/onlineshopping/dao/`
  - `UserDAO`, `ProductDAO`, `OrderDAO`
- **DB Utility**: `DBConnection` in `src/main/java/com/example/onlineshopping/util/`

## Tech Stack

- Java (configured in `pom.xml` with source/target `25`)
- Jakarta Servlet API 6.0.0
- JSP + JSTL-style EL usage in pages
- JDBC
- MySQL Connector/J 9.6.0
- Maven (WAR packaging)
- Apache Tomcat 10.1+ (recommended)

> Note: If your local JDK is lower than 25 (for example Java 17), update `maven.compiler.source` and `maven.compiler.target` in `pom.xml` accordingly.

## Project Structure

```text
OnlineShopping/
|- pom.xml
|- mvnw / mvnw.cmd
`- src/
   `- main/
      |- java/com/example/onlineshopping/
      |  |- AddToCartServlet.java
      |  |- CheckOutServlet.java
      |  |- LoginServlet.java
      |  |- LogoutServlet.java
      |  |- ProductServlet.java
      |  |- RegisterServlet.java
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

## Key Features

- **Session state management**: Stores cart in `HttpSession` as `ArrayList<Cart>`
- **Session guarding**: `products.jsp` and `cart.jsp` redirect unauthenticated users to `login.jsp`
- **Checkout workflow**: Creates an order record for each cart line item and clears the session cart after success
- **DAO abstraction**: SQL logic isolated in DAO classes
- **OOP modeling**: Inheritance used in `Cart` and `Order`

## Servlet Endpoints

- `POST /register` -> register a new user
- `POST /login` -> authenticate and create session
- `GET /products` -> load products and forward to `products.jsp`
- `GET /add-to-cart?id=<productId>` -> add/increment cart item in session
- `GET /cart-check-out` -> persist orders from cart
- `GET /logout` -> invalidate session

## Database Setup

The app expects a MySQL database named `shop_db` (based on `DBConnection.java`).

### 1) Create database and tables

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

### 2) Seed sample products

```sql
INSERT INTO products (id, name, price, description, image_url) VALUES
(1, 'Container A', 120.00, 'Standard dry container', NULL),
(2, 'Container B', 250.00, 'Refrigerated container', NULL),
(3, 'Pallet Bundle', 75.50, 'Bulk pallet pack', NULL)
ON DUPLICATE KEY UPDATE name = VALUES(name), price = VALUES(price);
```

### 3) Configure DB credentials

Update `src/main/java/com/example/onlineshopping/util/DBConnection.java` if needed:
- URL: `jdbc:mysql://localhost:3306/shop_db`
- Username/password: your local MySQL credentials

## Build and Run

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

## Test

```powershell
.\mvnw.cmd test
```

## Known Notes

- Passwords are currently stored in plain text (for academic/demo use). In production, use hashing (e.g., BCrypt).
- Database connection settings are hardcoded in `DBConnection.java`.
- `CheckOutServlet` currently writes a static shipping address (`Hyderabad Hub (PBL Demo)`).

## Academic Context

Developed as part of Year II, Semester 2 PBL (Problem-Based Learning) coursework to demonstrate end-to-end enterprise web application concepts using Java, Servlets, JSP, JDBC, and MySQL.

