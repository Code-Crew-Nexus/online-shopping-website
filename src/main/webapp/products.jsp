<%--
  Created by IntelliJ IDEA.
  User: Sai Krishna
  Date: 04-04-2026
  Time: 22:12
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.*" %>
<%@ page import="java.util.List" %>
<%
  // 1. Session Guard: Ensure user is logged in
  User auth = (User) session.getAttribute("authUser");
  if (auth == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  // 2. Data Retrieval: Match the attribute name from ProductServlet
  List<Product> products = (List<Product>) request.getAttribute("productList");
%>
<html>
<head>
  <title>Shipping Catalog</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div style="display: flex; justify-content: space-between; align-items: center; padding: 10px 5%;">
  <h2>Welcome, <%= auth.getUsername() %>!</h2>
  <div>
    <!-- Link to see the items added to the session -->
    <a href="cart.jsp" style="margin-right: 20px; font-weight: bold;">🛒 View Cart</a>
    <a href="logout" style="color: #ef4444; text-decoration:none;">Logout</a>
  </div>
</div>
<hr>

<div style="padding: 0 5%;">
  <h3>Available Shipping Items</h3>

  <%-- Success message if redirected back from AddToCartServlet --%>
  <% if("added".equals(request.getParameter("status"))) { %>
  <p style="color: green;">✔ Item added to your shipment!</p>
  <% } %>

  <table border="1" style="width: 100%; border-collapse: collapse;">
    <tr style="background-color: #f2f2f2;">
      <th>Product Name</th>
      <th>Price</th>
      <th>Action</th>
    </tr>
    <% if (products != null && !products.isEmpty()) {
      for (Product p : products) { %>
    <tr>
      <td style="padding: 10px;"><%= p.getName() %></td>
      <td style="padding: 10px;">$<%= p.getPrice() %></td>
      <td style="padding: 10px;">
        <!-- This hits AddToCartServlet.java -->
        <a href="add-to-cart?id=<%= p.getId() %>">
          <button type="button">Add to Cart</button>
        </a>
      </td>
    </tr>
    <% } } else { %>
    <tr>
      <td colspan="3" style="text-align: center; padding: 20px;">
        No products found in the database.
      </td>
    </tr>
    <% } %>
  </table>
</div>
</body>
</html>

<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<%@ page import="com.example.onlineshopping.model.User" %>--%>
<%--<%@ page import="com.example.onlineshopping.model.Product" %>--%>
<%--<%@ page import="java.util.List" %>--%>
<%--<%--%>
<%--  User auth = (User) session.getAttribute("authUser");--%>
<%--  if (auth == null) {--%>
<%--    response.sendRedirect("login.jsp");--%>
<%--    return;--%>
<%--  }--%>
<%--  List<Product> products = (List<Product>) request.getAttribute("products");--%>
<%--%>--%>
<%--<html>--%>
<%--<head><title>Product Catalog</title></head>--%>
<%--<body>--%>
<%--<h2>Welcome, <%= auth.getUsername() %>!</h2>--%>
<%--<hr>--%>
<%--<h3>Available Shipping Items</h3>--%>
<%--<table border="1">--%>
<%--  <tr>--%>
<%--    <th>Name</th>--%>
<%--    <th>Price</th>--%>
<%--    <th>Action</th>--%>
<%--  </tr>--%>
<%--  <% if (products != null) {--%>
<%--    for (Product p : products) { %>--%>
<%--  <tr>--%>
<%--    <td><%= p.getName() %></td>--%>
<%--    <td>$<%= p.getPrice() %></td>--%>
<%--    <td><a href="add-to-cart?id=<%= p.getId() %>">Add to Cart</a></td>--%>
<%--  </tr>--%>
<%--  <% } } %>--%>
<%--</table>--%>
<%--</body>--%>
<%--</html>--%>