<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.User" %>
<%
  User auth = (User) session.getAttribute("authUser");
  String msg = request.getParameter("msg");
%>
<html>
<head>
  <title>FlipZon - Premium Shopping Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="layout">
  <div class="top-nav">
    <div class="links">
      <a class="btn-link" href="${pageContext.request.contextPath}/index.jsp">Home</a>
      <% if (auth == null) { %>
        <a class="btn-link" href="${pageContext.request.contextPath}/login.jsp">Login</a>
      <% } else { %>
        <a class="btn-link" href="${pageContext.request.contextPath}/products">Products</a>
        <a class="btn-link" href="${pageContext.request.contextPath}/orders">Orders</a>
        <a class="btn-link" href="${pageContext.request.contextPath}/logout">Logout</a>
      <% } %>
    </div>
    <button class="btn" type="button" data-theme-toggle>Switch Mode</button>
  </div>

  <% if (auth != null) { %>
    <!-- Authenticated User View -->
    <div class="hero">
      <div class="card stack">
        <div class="logo-shell">
          <img
            src="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
            alt="FlipZon Logo"
            data-theme-logo
            data-logo-light="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
            data-logo-dark="${pageContext.request.contextPath}/assets/images/flipzon-logo-dark.svg">
        </div>
        <h1>Welcome Back, <%= auth.getUsername() %>!</h1>
        <p class="muted">Your premium shopping destination awaits. Discover curated products with seamless checkout.</p>
        <a class="btn btn-brand" href="${pageContext.request.contextPath}/products">Explore Products</a>
      </div>

      <div class="card stack" style="justify-content: space-between;">
        <div>
          <h3>Quick Access</h3>
          <div style="display: grid; gap: 10px; margin-top: 10px;">
            <a class="btn btn-link" href="${pageContext.request.contextPath}/orders" style="text-align: center;">📦 View Orders</a>
            <a class="btn btn-link" href="${pageContext.request.contextPath}/products" style="text-align: center;">🛍️ New Arrivals</a>
            <a class="btn btn-link btn-danger" href="${pageContext.request.contextPath}/logout" style="text-align: center;">🚪 Sign Out</a>
          </div>
        </div>
      </div>
    </div>
  <% } else { %>
    <!-- Unauthenticated User View -->
    <section class="hero">
      <div class="card stack">
        <div class="logo-shell">
          <img
            src="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
            alt="FlipZon Logo"
            data-theme-logo
            data-logo-light="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
            data-logo-dark="${pageContext.request.contextPath}/assets/images/flipzon-logo-dark.svg">
        </div>
        <h1>FlipZon</h1>
        <p class="muted">Premium marketplace for everything you need</p>
        <p style="font-size: 0.95rem; line-height: 1.6; color: var(--text-muted); margin: 0;">
          Discover a curated selection of premium products. Fast checkout, secure payments, and exceptional customer service.
        </p>
        <% if ("success".equals(msg)) { %>
          <p class="alert alert-ok">✓ Registration successful. You can login now.</p>
        <% } else if ("invalid-email".equals(msg)) { %>
          <p class="alert alert-err">✗ Please enter a valid email address.</p>
        <% } else if ("error".equals(msg)) { %>
          <p class="alert alert-err">✗ Registration failed. Email may already exist.</p>
        <% } %>
      </div>

      <div class="card">
        <h2>Create Your Account</h2>
        <p class="muted">Join thousands of happy shoppers</p>

        <form class="auth-form" action="${pageContext.request.contextPath}/register" method="post">
          <input type="text" name="username" placeholder="Full name" required>
          <input
            type="email"
            name="email"
            placeholder="Email address"
            required
            autocomplete="email"
            pattern="[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
            title="Enter a valid email address like name@example.com"
            data-register-email>
          <p class="field-feedback" data-register-email-feedback aria-live="polite"></p>
          <input type="password" name="password" placeholder="Password (min 6 characters)" required minlength="6" autocomplete="new-password" data-register-password>
          <button class="btn btn-brand" type="submit" data-register-submit>Get Started</button>
        </form>

        <p class="footer-note">Already a member? <a href="${pageContext.request.contextPath}/login.jsp">Sign in here</a>.</p>
      </div>
    </section>
  <% } %>
</div>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</body>
</html>
