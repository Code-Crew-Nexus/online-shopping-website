<%--
  Created by IntelliJ IDEA.
  User: Sai Krishna
  Date: 04-04-2026
  Time: 21:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Login - Online Shopping</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="auth-container">
  <h2>Login to Your Account</h2>
  <%-- Display error if login fails --%>
  <p style="color:red;">${param.error == '1' ? 'Invalid Email or Password' : ''}</p>

  <form action="login" method="post">
    <input type="email" name="email" placeholder="Email" required><br>
    <input type="password" name="password" placeholder="Password" required><br>
    <button type="submit">Login</button>
  </form>
  <p>Don't have an account? <a href="index.jsp">Register here</a></p>
</div>
</body>
</html>