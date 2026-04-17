<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.onlineshopping.dao.ProductDAO" %>
<%
    User auth = (User) session.getAttribute("authUser");
    if (auth == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    ArrayList<Cart> cart_list = (ArrayList<Cart>) session.getAttribute("cart-list");
    ProductDAO pDao = new ProductDAO();
    List<Cart> cartProducts = pDao.getCartProducts(cart_list);
    double grandTotal = pDao.getTotalCartPrice(cart_list);
    String status = request.getParameter("status");
%>
<html>
<head>
    <title>Your Cart - FlipZon</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="layout">
    <div class="top-nav">
        <div class="links">
            <a class="btn-link" href="${pageContext.request.contextPath}/index.jsp">Home</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/products">Products</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/cart.jsp">Cart</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/orders">Orders</a>
            <a class="btn-link btn-danger" href="${pageContext.request.contextPath}/logout">Logout</a>
        </div>
        <button class="btn" type="button" data-theme-toggle>Switch Mode</button>
    </div>

    <div class="card">
        <h2>Your Cart</h2>
        <p class="muted">Review quantities and confirm your order when ready.</p>

        <% if ("removed".equals(status)) { %>
            <p class="alert alert-ok">Item removed from your cart.</p>
        <% } else if ("updated".equals(status)) { %>
            <p class="alert alert-ok">Quantity updated successfully.</p>
        <% } else if ("invalid".equals(status)) { %>
            <p class="alert alert-err">Please enter a valid quantity (minimum 1).</p>
        <% } else if ("missing".equals(status)) { %>
            <p class="alert alert-err">Cart item was not found. Refresh and try again.</p>
        <% } else if ("checkout-error".equals(status)) { %>
            <p class="alert alert-err">Checkout failed. Run the database setup script so the `products` table is seeded, then try again.</p>
        <% } %>

        <% if (cartProducts != null && !cartProducts.isEmpty()) { %>
            <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Unit Price</th>
                        <th>Quantity</th>
                        <th>Line Total</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Cart c : cartProducts) { %>
                    <tr>
                        <td><%= c.getName() %></td>
                        <td class="price">$<%= String.format("%.2f", c.getPrice()) %></td>
                        <td>
                            <form class="stack" style="grid-template-columns: 90px auto; align-items: center;" action="${pageContext.request.contextPath}/update-cart" method="post">
                                <input type="hidden" name="id" value="<%= c.getId() %>">
                                <input type="number" name="quantity" min="1" value="<%= c.getQuantity() %>">
                                <button class="btn" type="submit">Update</button>
                            </form>
                        </td>
                        <td class="price">$<%= String.format("%.2f", c.getPrice() * c.getQuantity()) %></td>
                        <td>
                            <a class="btn-link btn-danger" href="${pageContext.request.contextPath}/remove-from-cart?id=<%= c.getId() %>">Remove</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            </div>

            <div style="display:flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; margin-top: 12px; align-items: center;">
                <div class="total">Grand Total: $<%= String.format("%.2f", grandTotal) %></div>
                <a class="btn btn-brand" href="${pageContext.request.contextPath}/cart-check-out">Place Order</a>
            </div>
        <% } else { %>
            <p class="muted">Your cart is empty. Add items from the catalog to continue.</p>
            <div style="display:flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; margin-top: 12px; align-items: center;">
                <div class="total">Grand Total: $0.00</div>
                <a class="btn btn-brand" href="${pageContext.request.contextPath}/products">Browse Products</a>
            </div>
        <% } %>
    </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</body>
</html>
