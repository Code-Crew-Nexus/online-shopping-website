<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.*" %>
<%@ page import="java.util.ArrayList" %>
<%
    User auth = (User) session.getAttribute("authUser");
    if (auth == null) { response.sendRedirect("login.jsp"); return; }

    ArrayList<Cart> cart_list = (ArrayList<Cart>) session.getAttribute("cart-list");
%>
<html>
<head>
    <title>Your Shipment Queue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<h2>Items in your Shipping Queue</h2>
<table border="1" style="width: 80%; border-collapse: collapse;">
    <tr style="background:#3498db; color:white;">
        <th>Product ID</th>
        <th>Quantity</th>
    </tr>
    <% if (cart_list != null && !cart_list.isEmpty()) {
        for (Cart c : cart_list) { %>
    <tr>
        <td><%= c.getId() %></td>
        <td><%= c.getQuantity() %></td>
    </tr>
    <% } } else { %>
    <tr><td colspan="2" style="text-align:center;">Your queue is empty.</td></tr>
    <% } %>
</table>
<br>
<!-- This link sends the request to our new CheckOutServlet -->
<a href="cart-check-out">
    <button style="background-color: green; color: white; padding: 10px;">Confirm Shipment</button>
</a>
</body>
</html>