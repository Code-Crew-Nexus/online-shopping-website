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
      <img
        src="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
        alt="FlipZon Logo"
        style="width: 80px; height: 80px;"
        data-theme-logo
        data-logo-light="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg"
        data-logo-dark="${pageContext.request.contextPath}/assets/images/flipzon-logo-dark.svg">
    </div>
    <h2 style="text-align: center; margin: 10px 0;">Welcome Back</h2>
    <p class="muted" style="text-align: center;">Sign in to your account to continue shopping</p>

    <%
      String msg = request.getParameter("msg");
      if("logout".equals(msg)) {
    %>
      <p class="alert alert-ok">✓ You have been logged out successfully.</p>
    <% } else if ("exists".equals(msg)) { %>
      <p class="alert alert-err" data-login-exists-alert>✗ An account already exists with this email. Please sign in.</p>
    <% } %>

    <% if ("1".equals(request.getParameter("error"))) { %>
      <p class="alert alert-err">✗ Invalid email or password. Please try again.</p>
    <% } else if ("invalid-email".equals(request.getParameter("error"))) { %>
      <p class="alert alert-err">✗ Please enter a valid email address.</p>
    <% } %>

    <form class="auth-form" action="${pageContext.request.contextPath}/login" method="post" style="margin-top: 20px;">
      <input
        type="email"
        name="email"
        placeholder="Email address"
        required
        autocomplete="email"
        pattern="[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
        title="Enter a valid email address like name@example.com"
        data-login-email>
      <p class="field-feedback" data-login-email-feedback aria-live="polite"></p>
      <input type="password" name="password" placeholder="Password" required autocomplete="current-password" data-login-password>
      <button class="btn btn-brand" type="submit">Sign In</button>
    </form>

    <p class="footer-note" style="text-align: center;">Don't have an account? <a href="${pageContext.request.contextPath}/index.jsp">Create one here</a>.</p>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
<script>
  (function () {
    var params = new URLSearchParams(window.location.search);
    if (params.get('msg') !== 'exists') {
      return;
    }

    var passwordInput = document.querySelector('[data-login-password]');
    var alertNode = document.querySelector('[data-login-exists-alert]') ||
      Array.prototype.find.call(document.querySelectorAll('.alert.alert-err'), function (item) {
        return /already exists with this email/i.test(item.textContent || '');
      });

    if (!passwordInput || !alertNode) {
      return;
    }

    function dismissExistsAlert() {
      alertNode.style.display = 'none';
    }

    passwordInput.addEventListener('focus', dismissExistsAlert);
    passwordInput.addEventListener('keydown', dismissExistsAlert);
    passwordInput.addEventListener('input', dismissExistsAlert);
  })();
</script>
</body>
</html>