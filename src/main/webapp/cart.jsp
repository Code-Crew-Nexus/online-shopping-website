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
    <title>Your Shipment Queue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        html, body {
            margin: 0;
            padding: 0;
            min-height: 100vh;
            background: #0f172a;
            color: #e2e8f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .cart-wrap {
            max-width: 980px;
            margin: 40px auto;
            padding: 0 16px 32px;
        }

        .cart-card {
            background: rgba(15, 23, 42, 0.88);
            border: 1px solid rgba(148, 163, 184, 0.2);
            border-radius: 16px;
            box-shadow: 0 18px 45px rgba(2, 6, 23, 0.45);
            overflow: hidden;
        }

        .cart-head {
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(148, 163, 184, 0.2);
        }

        .cart-head h2 {
            margin: 0;
            color: #f8fafc;
        }

        .link-muted {
            color: #a5b4fc;
            text-decoration: none;
            font-weight: 600;
        }

        .notice {
            margin: 14px 20px 0;
            padding: 10px 12px;
            border-radius: 10px;
            background: rgba(16, 185, 129, 0.12);
            border: 1px solid rgba(16, 185, 129, 0.35);
            color: #86efac;
            font-weight: 600;
        }

        .cart-table {
            width: 100%;
            border-collapse: collapse;
            background: transparent !important;
            box-shadow: none !important;
        }

        .cart-table th, .cart-table td {
            padding: 14px 16px;
            border-bottom: 1px solid rgba(148, 163, 184, 0.18);
            text-align: left;
        }

        .cart-table th {
            color: #e2e8f0;
            font-size: 0.88rem;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            background: #374151 !important;
        }

        .cart-table td {
            color: #e2e8f0;
            background: rgba(15, 23, 42, 0.7) !important;
        }

        .cart-table tbody tr:nth-child(even) td {
            background: rgba(30, 41, 59, 0.7) !important;
        }

        .cart-table tbody tr:hover td {
            background: rgba(51, 65, 85, 0.72) !important;
        }

        .price {
            color: #a78bfa;
            font-weight: 700;
        }

        .remove-btn {
            display: inline-block;
            text-decoration: none;
            color: #fda4af;
            border: 1px solid rgba(244, 63, 94, 0.35);
            border-radius: 8px;
            padding: 6px 10px;
            font-size: 0.9rem;
        }

        .qty-form {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .qty-input {
            width: 70px;
            padding: 6px 8px;
            border-radius: 8px;
            border: 1px solid rgba(148, 163, 184, 0.35);
            background: rgba(15, 23, 42, 0.75);
            color: #f8fafc;
        }

        .update-btn {
            border: 1px solid rgba(99, 102, 241, 0.5);
            border-radius: 8px;
            background: rgba(99, 102, 241, 0.2);
            color: #c7d2fe;
            padding: 6px 10px;
            font-size: 0.86rem;
            font-weight: 600;
            cursor: pointer;
        }

        .update-btn:hover {
            background: rgba(99, 102, 241, 0.32);
        }

        .cart-summary {
            padding: 16px 20px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .total {
            font-size: 1.1rem;
            font-weight: 700;
            color: #f8fafc;
        }

        .checkout-btn {
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            color: #fff;
            text-decoration: none;
            font-weight: 700;
            border-radius: 10px;
            padding: 10px 16px;
            display: inline-block;
        }

        .empty-state {
            padding: 28px 20px;
            color: #94a3b8;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="cart-wrap">
    <div class="cart-card">
        <div class="cart-head">
            <h2>Your Shipment Queue</h2>
            <a class="link-muted" href="${pageContext.request.contextPath}/products">+ Add more items</a>
        </div>

        <% if ("removed".equals(status)) { %>
            <div class="notice">Item removed from your cart.</div>
        <% } else if ("updated".equals(status)) { %>
            <div class="notice">Quantity updated successfully.</div>
        <% } else if ("invalid".equals(status)) { %>
            <div class="notice">Please enter a valid quantity (minimum 1).</div>
        <% } else if ("missing".equals(status)) { %>
            <div class="notice">Cart item was not found. Refresh and try again.</div>
        <% } %>

        <% if (cartProducts != null && !cartProducts.isEmpty()) { %>
            <table class="cart-table">
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
                            <form class="qty-form" action="${pageContext.request.contextPath}/update-cart" method="post">
                                <input type="hidden" name="id" value="<%= c.getId() %>">
                                <input class="qty-input" type="number" name="quantity" min="1" value="<%= c.getQuantity() %>">
                                <button class="update-btn" type="submit">Update</button>
                            </form>
                        </td>
                        <td class="price">$<%= String.format("%.2f", c.getPrice() * c.getQuantity()) %></td>
                        <td>
                            <a class="remove-btn" href="${pageContext.request.contextPath}/remove-from-cart?id=<%= c.getId() %>">Remove</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <div class="cart-summary">
                <div class="total">Grand Total: $<%= String.format("%.2f", grandTotal) %></div>
                <a class="checkout-btn" href="${pageContext.request.contextPath}/cart-check-out">Confirm Shipment</a>
            </div>
        <% } else { %>
            <div class="empty-state">Your queue is empty. Add items from the catalog to continue.</div>
            <div class="cart-summary">
                <div class="total">Grand Total: $0.00</div>
                <a class="checkout-btn" href="${pageContext.request.contextPath}/products">Browse Products</a>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>