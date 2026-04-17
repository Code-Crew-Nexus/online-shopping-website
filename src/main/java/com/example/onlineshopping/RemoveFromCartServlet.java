package com.example.onlineshopping;

import com.example.onlineshopping.model.Cart;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "RemoveFromCartServlet", value = "/remove-from-cart")
public class RemoveFromCartServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            HttpSession session = request.getSession();
            @SuppressWarnings("unchecked")
            ArrayList<Cart> cartList = (ArrayList<Cart>) session.getAttribute("cart-list");

            if (cartList != null) {
                cartList.removeIf(item -> item.getId() == id);
                if (cartList.isEmpty()) {
                    session.removeAttribute("cart-list");
                }
            }

            response.sendRedirect(request.getContextPath() + "/cart.jsp?status=removed");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp");
        }
    }
}

