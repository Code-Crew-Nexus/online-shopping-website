<%--
  Created by IntelliJ IDEA.
  User: Sai Krishna
  Date: 04-04-2026
  Time: 21:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Login - Online Shopping</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      min-height: 100vh;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: radial-gradient(circle at top, #1e293b 0%, #0b1025 45%, #060b1b 100%);
      color: #e2e8f0;
    }

    .auth-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }

    .auth-card {
      width: min(92vw, 420px);
      background: rgba(15, 23, 42, 0.9);
      border: 1px solid rgba(148, 163, 184, 0.2);
      border-radius: 18px;
      box-shadow: 0 20px 60px rgba(2, 6, 23, 0.55);
      padding: 28px 24px;
    }

    .auth-title {
      margin: 0;
      font-size: 1.6rem;
      color: #f8fafc;
    }

    .auth-subtitle {
      margin: 8px 0 20px;
      color: #94a3b8;
      font-size: 0.95rem;
    }

    .auth-message {
      margin: 0 0 14px;
      padding: 10px 12px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 0.92rem;
    }

    .auth-message.success {
      color: #86efac;
      background: rgba(16, 185, 129, 0.12);
      border: 1px solid rgba(16, 185, 129, 0.35);
    }

    .auth-message.error {
      color: #fca5a5;
      background: rgba(239, 68, 68, 0.14);
      border: 1px solid rgba(239, 68, 68, 0.4);
    }

    .auth-form input {
      width: 100%;
      box-sizing: border-box;
      margin: 0 0 12px;
      padding: 12px;
      border-radius: 10px;
      border: 1px solid rgba(148, 163, 184, 0.32);
      background: rgba(30, 41, 59, 0.55);
      color: #f8fafc;
      outline: none;
    }

    .auth-form input:focus {
      border-color: #818cf8;
      box-shadow: 0 0 0 3px rgba(129, 140, 248, 0.18);
    }

    .auth-btn {
      width: 100%;
      border: none;
      border-radius: 10px;
      padding: 12px;
      font-weight: 700;
      color: #fff;
      cursor: pointer;
      background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
      box-shadow: 0 10px 24px rgba(99, 102, 241, 0.35);
    }

    .auth-foot {
      margin: 16px 0 0;
      color: #94a3b8;
      text-align: center;
    }

    .auth-foot a {
      color: #a5b4fc;
      text-decoration: none;
      font-weight: 600;
    }
  </style>
</head>
<body>
<div class="auth-page">
<div class="auth-card">
  <h2 class="auth-title">Login to Your Account</h2>
  <p class="auth-subtitle">Access your shipping catalog and manage orders.</p>

  <%-- Logout Message Handling --%>
  <%
    String msg = request.getParameter("msg");
    if("logout".equals(msg)) {
  %>
  <p class="auth-message success">You have been logged out safely.</p>
  <% } %>

  <%-- Display error if login fails --%>
  <% if ("1".equals(request.getParameter("error"))) { %>
    <p class="auth-message error">Invalid email or password.</p>
  <% } %>

  <form class="auth-form" action="${pageContext.request.contextPath}/login" method="post">
    <input type="email" name="email" placeholder="Email" required>
    <input type="password" name="password" placeholder="Password" required>
    <button class="auth-btn" type="submit">Login</button>
  </form>
  <p class="auth-foot">Don't have an account? <a href="${pageContext.request.contextPath}/index.jsp">Register here</a></p>
</div>
</div>
</body>
</html>