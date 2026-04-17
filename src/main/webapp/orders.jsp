<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.User" %>
<%
    User auth = (User) session.getAttribute("authUser");
    String status = request.getParameter("status");
    String total = request.getParameter("total");
    boolean success = "success".equalsIgnoreCase(status);
    boolean neutral = (status == null || status.trim().isEmpty());
%>
<html>
    <head>
        <title>Shipment Confirmation</title>
        <style>
            html, body {
                margin: 0;
                padding: 0;
                min-height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: radial-gradient(circle at top, #1e293b 0%, #0b1025 45%, #060b1b 100%);
                color: #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .confirm-card {
                width: min(92vw, 680px);
                border: 1px solid rgba(148, 163, 184, 0.2);
                background: rgba(15, 23, 42, 0.88);
                box-shadow: 0 24px 60px rgba(2, 6, 23, 0.6);
                border-radius: 20px;
                padding: 32px;
            }

            .badge {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 8px 14px;
                border-radius: 999px;
                font-weight: 700;
                font-size: 0.9rem;
                margin-bottom: 14px;
            }

            .badge.success {
                color: #10b981;
                background: rgba(16, 185, 129, 0.12);
                border: 1px solid rgba(16, 185, 129, 0.35);
            }

            .badge.neutral {
                color: #f59e0b;
                background: rgba(245, 158, 11, 0.12);
                border: 1px solid rgba(245, 158, 11, 0.35);
            }

            h2 {
                margin: 0 0 10px 0;
                font-size: 1.9rem;
                color: #f8fafc;
            }

            p {
                margin: 0;
                line-height: 1.65;
                color: #cbd5e1;
            }

            .muted {
                margin-top: 14px;
                font-size: 0.95rem;
                color: #94a3b8;
            }

            .actions {
                margin-top: 26px;
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
            }

            .btn {
                text-decoration: none;
                color: #ffffff;
                padding: 10px 16px;
                border-radius: 10px;
                border: 1px solid transparent;
                font-weight: 600;
            }

            .btn-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
                box-shadow: 0 8px 24px rgba(99, 102, 241, 0.35);
            }

            .btn-secondary {
                background: rgba(148, 163, 184, 0.16);
                border-color: rgba(148, 163, 184, 0.4);
            }
        </style>
    </head>
<body>
    <div class="confirm-card">
        <% if (success) { %>
            <div class="badge success">✔ Shipment Confirmed</div>
            <h2>Your order is successfully placed</h2>
            <p>Your items are now logged in the shipping system and ready for processing.</p>
            <% if (total != null && !total.trim().isEmpty()) { %>
                <p class="muted">Total charged: <strong>$<%= total %></strong></p>
            <% } %>
            <p class="muted">You can continue browsing and add more shipping units anytime.</p>
        <% } else if (neutral) { %>
            <div class="badge neutral">ℹ Confirmation Page</div>
            <h2>No recent shipment status found</h2>
            <p>You opened this page directly, so there is no checkout status to show.</p>
            <p class="muted">Use the catalog to continue shopping or go to cart to review items.</p>
        <% } else { %>
            <div class="badge neutral">⚠ Status: <%= status %></div>
            <h2>Shipment update received</h2>
            <p>We got a non-standard status from checkout flow. Please review your cart and try again if needed.</p>
        <% } %>

        <div class="actions">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/products">Order More Items</a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/cart.jsp">View Cart</a>
            <% if (auth == null) { %>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/login.jsp">Login</a>
            <% } else { %>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/logout">Logout</a>
            <% } %>
        </div>
    </div>
</body>
</html>