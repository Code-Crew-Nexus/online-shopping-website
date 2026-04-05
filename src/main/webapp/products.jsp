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
  <title>Shipping Catalog </title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>

    html, body {
      background-color: #0f172a !important; /* Deep Navy Dark Mode */
      color: white !important;
      margin: 0;
      padding: 0;
      min-height: 100vh;
    }
    .btn-premium {
      background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
      color: white !important;
      padding: 12px 20px;
      border-radius: 12px;
      text-decoration: none;
      display: block;
      font-weight: bold;
      text-align: center;
      transition: all 0.3s ease;
      box-shadow: 0 4px 15px rgba(168, 85, 247, 0.4);
      border: none;
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-size: 0.95rem;
      margin-top: 10px;
    }

    .btn-premium:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(168, 85, 247, 0.6);
      filter: brightness(1.1);
      color: white !important;
    }

    .btn-premium:active {
      transform: translateY(0);
    }

    /* Fixing the horizontal nav links so they are also visible */
    a[href*="logout"], a[href*="cart.jsp"] {
      transition: color 0.3s;
    }
    a[href*="logout"]:hover { color: #f87171 !important; }
    a[href*="cart.jsp"]:hover { color: #a855f7 !important; }

    .product-card {
      background: rgba(255, 255, 255, 0.05) !important; /* Glass effect */
      border: 1px solid rgba(255, 255, 255, 0.1) !important;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
    }
    /* Fixed variable resolution for IDE warnings */
    :root {
      --glass: rgba(255, 255, 255, 0.05);
      --glass-border: rgba(255, 255, 255, 0.1);
    }

    .product-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 2.5rem;
      padding: 20px 0;
      align-items: stretch;
    }

    .product-card {
      background: var(--glass);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid var(--glass-border);
      border-radius: 20px;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      transition: transform 0.3s ease, border-color 0.3s ease;
      height: 100%; /* Ensures all cards in a row are same height */
      min-height: 520px;
    }

    .product-card:hover {
      transform: translateY(-10px);
      border-color: rgba(168, 85, 247, 0.4);
    }

    .product-image-container {
      width: 100%;
      height: 230px;
      background: #f8fafc;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0;
      overflow: hidden;
    }

    .product-image-container img {
      width: 100%;
      height: 100%;
      display: block;
      margin: 0;
      object-fit: cover;
      object-position: center center;
    }

    .product-info {
      padding: 1.5rem;
      display: flex;
      flex-direction: column;
      flex-grow: 1;
    }

    .product-name {
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-size: 1.15rem;
      margin: 0;
      color: white;
    }

    .product-desc {
      color: #94a3b8;
      font-size: 0.85rem;
      margin: 10px 0;
      height: 40px;
      overflow: hidden;
    }

    .product-price {
      font-size: 1.4rem;
      font-weight: bold;
      color: #a855f7;
      margin-bottom: 1.25rem;
    }

    .product-actions {
      margin-top: auto;
    }
  </style>
</head>
<body>

<%-- Navbar Section --%>
<div style="display: flex; justify-content: space-between; align-items: center; padding: 1.5rem 5%; background: rgba(0,0,0,0.2);">
  <h2 style="margin:0;">Welcome, <span style="color: #a855f7;"><%= auth.getUsername() %></span>!</h2>
  <div>
    <a href="${pageContext.request.contextPath}/cart.jsp" style="margin-right: 20px; text-decoration:none; color: white; font-weight: bold;">🛒 View Cart</a>
    <a href="${pageContext.request.contextPath}/logout" style="color: #ef4444; text-decoration:none;">Logout</a>
  </div>
</div>

<div style="padding: 2rem 5%;">
  <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; color: white;">Shipping Catalog</h1>

  <%-- Feedback Message --%>
  <% if("added".equals(request.getParameter("status"))) { %>
  <p style="color: #10b981; background: rgba(16, 185, 129, 0.1); padding: 12px; border-radius: 10px; font-weight: bold; border: 1px solid rgba(16, 185, 129, 0.2);">
    ✔ Item added to your shipment!
  </p>
  <% } %>

  <div style="padding: 1rem 0;">
    <h3 style="color: #94a3b8;">Available Shipping Units</h3>

    <div class="product-grid">
      <% if (products != null && !products.isEmpty()) {
        for (Product p : products) { %>
      <%
        String imagePath = p.getImageUrl();
        if (imagePath == null || imagePath.trim().isEmpty()) {
          imagePath = "box1.png";
        }
        imagePath = imagePath.trim();
        if (imagePath.startsWith("/images/")) {
          imagePath = imagePath.substring("/images/".length());
        } else if (imagePath.startsWith("images/")) {
          imagePath = imagePath.substring("images/".length());
        }
        String imageSrc = (imagePath.startsWith("http://") || imagePath.startsWith("https://"))
                ? imagePath
                : (request.getContextPath() + "/images/" + imagePath);
      %>

      <div class="product-card">
        <div class="product-image-container">
          <img src="<%= imageSrc %>"
               alt="<%= p.getName() %>"
               onerror="this.src='https://via.placeholder.com/200?text=No+Image'">
        </div>

        <div class="product-info">
          <h3 class="product-name"><%= p.getName() %></h3>
          <p class="product-desc"><%= (p.getDescription() != null) ? p.getDescription() : "Standard shipping container." %></p>
          <div class="product-price">$<%= p.getPrice() %></div>

          <div class="product-actions">
            <a href="${pageContext.request.contextPath}/add-to-cart?id=<%= p.getId() %>" class="btn-premium">
              Add to Cart
            </a>
          </div>
        </div>
      </div>

      <% } } else { %>
      <p style="color: white;">No products found in the database. Ensure DAO is loading the list.</p>
      <% } %>
    </div>
  </div> <%-- End of inner padding div --%>
</div> <%-- End of outer main padding div --%>

</body>
</html>