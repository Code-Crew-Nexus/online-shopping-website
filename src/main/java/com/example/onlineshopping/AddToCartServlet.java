package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.Cart;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "AddToCartServlet", value = "/add-to-cart")
public class AddToCartServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();

        // 1. Try to get existing cart from session
        @SuppressWarnings("unchecked")
        ArrayList<Cart> cartList = (ArrayList<Cart>) session.getAttribute("cart-list");

        // 2. If no cart exists, create a new one
        if (cartList == null) {
            cartList = new ArrayList<>();
            Cart cm = new Cart();
            cm.setId(id);
            cm.setQuantity(1);
            cartList.add(cm);
            session.setAttribute("cart-list", cartList);
        } else {
            // 3. If cart exists, check if product is already there
            boolean exist = false;
            for (Cart c : cartList) {
                if (c.getId() == id) {
                    exist = true;
                    c.setQuantity(c.getQuantity() + 1); // Just increase quantity
                }
            }
            // 4. If new product, add to list
            if (!exist) {
                Cart cm = new Cart();
                cm.setId(id);
                cm.setQuantity(1);
                cartList.add(cm);
            }
        }
        // Go back to products page with a success flag
        response.sendRedirect(request.getContextPath() + "/products?status=added");
    }
}