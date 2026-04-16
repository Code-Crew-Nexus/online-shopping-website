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

@WebServlet(name = "UpdateCartServlet", value = "/update-cart")
public class UpdateCartServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String quantityParam = request.getParameter("quantity");

        if (idParam == null || quantityParam == null) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp?status=invalid");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            int quantity = Integer.parseInt(quantityParam);

            if (quantity < 1) {
                response.sendRedirect(request.getContextPath() + "/cart.jsp?status=invalid");
                return;
            }

            HttpSession session = request.getSession();
            ArrayList<Cart> cartList = (ArrayList<Cart>) session.getAttribute("cart-list");

            if (cartList == null || cartList.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart.jsp?status=missing");
                return;
            }

            boolean updated = false;
            for (Cart item : cartList) {
                if (item.getId() == id) {
                    item.setQuantity(quantity);
                    updated = true;
                    break;
                }
            }

            if (updated) {
                response.sendRedirect(request.getContextPath() + "/cart.jsp?status=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/cart.jsp?status=missing");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp?status=invalid");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/cart.jsp");
    }
}

