<%--
  Created by IntelliJ IDEA.
  User: Sai Krishna
  Date: 04-04-2026
  Time: 21:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Register - Online Shopping</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<h2>Create an Account</h2>
<form action="register" method="post">
  <input type="text" name="username" placeholder="Username" required><br>
  <input type="email" name="email" placeholder="Email" required><br>
  <input type="password" name="password" placeholder="Password" required><br>
  <button type="submit">Register</button>

  <p>Already have an account? <a href="login.jsp">Login here</a></p>
</form>
</body>
</html>
