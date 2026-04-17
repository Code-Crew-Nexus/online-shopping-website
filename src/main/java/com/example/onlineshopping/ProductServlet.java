package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.Product;
import com.example.onlineshopping.dao.ProductDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "ProductServlet", value = "/products")
public class ProductServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Fetch products from DAO
        ProductDAO productDAO = new ProductDAO();
        List<Product> productList = productDAO.getAllProducts();
        List<Product> shuffledProductList = new ArrayList<>(productList);

        // Randomize sequence on each page load while preserving product IDs.
        Collections.shuffle(shuffledProductList);

        // 2. Pass the list to the request object
        request.setAttribute("productList", shuffledProductList);

        // 3. Forward to the JSP page
        request.getRequestDispatcher("products.jsp").forward(request, response);
    }
}