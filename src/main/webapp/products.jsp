<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.onlineshopping.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%
  // 1. Session Guard
  User auth = (User) session.getAttribute("authUser");
  if (auth == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  // 2. Data Retrieval
  List<Product> products = (List<Product>) request.getAttribute("productList");
  if (products == null) {
    // Keep the JSP renderable when accessed directly; do not bounce back to servlet.
    products = Collections.emptyList();
  }
%>
<html>
<head>
  <title>Products - FlipZon</title>
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

  <div class="logo-shell" style="margin-bottom: 16px; display: inline-block;">
    <img src="${pageContext.request.contextPath}/assets/images/flipzon-logo.svg" alt="FlipZon Logo">
  </div>

  <div class="card" style="margin-bottom: 16px;">
    <h2 style="margin-bottom: 6px;">Welcome, <%= auth.getUsername() %></h2>
    <p class="muted" style="margin: 0;">Explore curated products, add them to your cart, and track every order from the new Orders page.</p>
  </div>

  <% if("added".equals(request.getParameter("status"))) { %>
    <p class="alert alert-ok">Item added to your cart.</p>
  <% } %>

  <h1 style="margin: 16px 0 10px;">Shopping Catalog</h1>
  <div class="products-grid">
      <% if (products != null && !products.isEmpty()) {
        for (Product p : products) { %>
      <%
        String imagePath = p.getImageUrl();
        if (imagePath == null || imagePath.trim().isEmpty()) {
          imagePath = "box1.png";
        }
        imagePath = imagePath.trim();
        if (imagePath.startsWith("/assets/images/")) {
          imagePath = imagePath.substring("/assets/images/".length());
        } else if (imagePath.startsWith("assets/images/")) {
          imagePath = imagePath.substring("assets/images/".length());
        } else if (imagePath.startsWith("/images/")) {
          imagePath = imagePath.substring("/images/".length());
        } else if (imagePath.startsWith("images/")) {
          imagePath = imagePath.substring("images/".length());
        }
        String imageSrc = (imagePath.startsWith("http://") || imagePath.startsWith("https://"))
                ? imagePath
                : (request.getContextPath() + "/assets/images/" + imagePath);
      %>

      <div class="product-card">
        <img src="<%= imageSrc %>" alt="<%= p.getName() %>" onerror="this.src='https://via.placeholder.com/500x300?text=No+Image'">
        <div class="product-body">
          <h3><%= p.getName() %></h3>
          <p class="muted"><%= (p.getDescription() != null) ? p.getDescription() : "Quality item." %></p>
          <div class="price">$<%= String.format("%.2f", p.getPrice()) %></div>
          <a href="${pageContext.request.contextPath}/add-to-cart?id=<%= p.getId() %>" class="btn btn-brand">Add to Cart</a>
        </div>
      </div>

      <% } } else { %>
      <p class="muted">No products found in source data.</p>
      <% } %>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

</body>
</html>