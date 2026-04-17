package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.*;
import com.example.onlineshopping.dao.ProductDAO;
import com.example.onlineshopping.dao.OrderDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "CheckOutServlet", value = "/cart-check-out")
public class CheckOutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. Get the current date for the order
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            String date = formatter.format(new Date());

            // 2. Generate unique order group ID (all items in one checkout get same ID)
            String orderGroupId = "ORD-" + System.currentTimeMillis() + "-" + (int)(Math.random() * 10000);

            // 3. Get User and Cart from Session
            User auth = (User) request.getSession().getAttribute("authUser");
            @SuppressWarnings("unchecked")
            ArrayList<Cart> cart_list = (ArrayList<Cart>) request.getSession().getAttribute("cart-list");

            // 4. If everything exists, process the checkout
            if (cart_list != null && auth != null) {
                if (cart_list.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/cart.jsp");
                    return;
                }

                OrderDAO oDao = new OrderDAO();
                ProductDAO pDao = new ProductDAO();
                double totalAmount = pDao.getTotalCartPrice(cart_list);
                List<Order> ordersToInsert = new ArrayList<>();

                // All items get the same order group ID
                for (Cart c : cart_list) {
                    Order order = new Order();
                    order.setId(c.getId());
                    order.setOrderGroupId(orderGroupId);
                    order.setUid(auth.getId());
                    order.setQuantity(c.getQuantity());
                    order.setDate(date);
                    order.setOrderStatus("Delivered");
                    ordersToInsert.add(order);
                }

                if (oDao.insertOrders(ordersToInsert)) {
                    request.getSession().removeAttribute("cart-list");
                    String totalText = String.format(Locale.US, "%.2f", totalAmount);
                    response.sendRedirect(request.getContextPath() + "/orders?status=success&total="
                            + URLEncoder.encode(totalText, StandardCharsets.UTF_8));
                } else {
                    response.sendRedirect(request.getContextPath() + "/cart.jsp?status=checkout-error");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart.jsp?status=checkout-error");
        }
    }
}
