<%--
  Created by IntelliJ IDEA.
  User: Sai Krishna
  Date: 04-04-2026
  Time: 22:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.User" %>
<%@ page import="com.example.onlineshopping.model.Product" %>
<%@ page import="java.util.List" %>
<%
  User auth = (User) session.getAttribute("authUser");
  if (auth == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  List<Product> products = (List<Product>) request.getAttribute("products");
%>
<html>
<head><title>Product Catalog</title></head>
<body>
<h2>Welcome, <%= auth.getUsername() %>!</h2>
<hr>
<h3>Available Shipping Items</h3>
<table border="1">
  <tr>
    <th>Name</th>
    <th>Price</th>
    <th>Action</th>
  </tr>
  <% if (products != null) {
    for (Product p : products) { %>
  <tr>
    <td><%= p.getName() %></td>
    <td>$<%= p.getPrice() %></td>
    <td><a href="add-to-cart?id=<%= p.getId() %>">Add to Cart</a></td>
  </tr>
  <% } } %>
</table>
</body>
</html>