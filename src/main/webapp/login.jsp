<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Login - FlipZon</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="layout">
  <div class="top-nav">
    <div class="links">
      <a class="btn-link" href="${pageContext.request.contextPath}/index.jsp">Home</a>
    </div>
    <button class="btn" type="button" data-theme-toggle>Switch Mode</button>
  </div>

  <div class="card" style="max-width: 480px; margin: 6vh auto 0;">
    <div style="text-align: center; margin-bottom: 20px;">
      <img src="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg" alt="FlipZon Logo" style="width: 80px; height: 80px;">
    </div>
    <h2 style="text-align: center; margin: 10px 0;">Welcome Back</h2>
    <p class="muted" style="text-align: center;">Sign in to your account to continue shopping</p>

    <%
      String msg = request.getParameter("msg");
      if("logout".equals(msg)) {
    %>
      <p class="alert alert-ok">✓ You have been logged out successfully.</p>
    <% } %>

    <% if ("1".equals(request.getParameter("error"))) { %>
      <p class="alert alert-err">✗ Invalid email or password. Please try again.</p>
    <% } %>

    <form class="auth-form" action="${pageContext.request.contextPath}/login" method="post" style="margin-top: 20px;">
      <input type="email" name="email" placeholder="Email address" required>
      <input type="password" name="password" placeholder="Password" required>
      <button class="btn btn-brand" type="submit">Sign In</button>
    </form>

    <p class="footer-note" style="text-align: center;">Don't have an account? <a href="${pageContext.request.contextPath}/index.jsp">Create one here</a>.</p>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</body>
</html>