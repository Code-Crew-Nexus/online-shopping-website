package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.*;
import com.example.onlineshopping.dao.OrderDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

@WebServlet(name = "CheckOutServlet", value = "/cart-check-out")
public class CheckOutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. Get the current date for the order
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            String date = formatter.format(new Date());

            // 2. Get User and Cart from Session
            User auth = (User) request.getSession().getAttribute("authUser");
            ArrayList<Cart> cart_list = (ArrayList<Cart>) request.getSession().getAttribute("cart-list");

            // 3. If everything exists, process the checkout
            if (cart_list != null && auth != null) {
                OrderDAO oDao = new OrderDAO();

                for (Cart c : cart_list) {
                    Order order = new Order();
                    order.setId(c.getId());
                    order.setUid(auth.getId());
                    order.setQuantity(c.getQuantity());
                    order.setDate(date);

                    oDao.insertOrder(order);
                }

                // 4. CLEAR the cart session so it's ready for the next order
                request.getSession().removeAttribute("cart-list");
                response.sendRedirect("orders.jsp?status=success");
            } else {
                response.sendRedirect("index.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}