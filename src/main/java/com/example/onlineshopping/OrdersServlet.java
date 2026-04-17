package com.example.onlineshopping;

import com.example.onlineshopping.dao.OrderDAO;
import com.example.onlineshopping.model.Order;
import com.example.onlineshopping.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "OrdersServlet", value = "/orders")
public class OrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User auth = (User) request.getSession().getAttribute("authUser");
        if (auth == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orderList = orderDAO.getOrdersByUser(auth.getId());

        // Group orders by orderGroupId and calculate totals
        Map<String, List<Order>> groupedOrders = new LinkedHashMap<>();
        for (Order order : orderList) {
            groupedOrders.computeIfAbsent(order.getOrderGroupId(), k -> new ArrayList<>()).add(order);
        }

        // Delete orders endpoint handler
        String deleteOrderId = request.getParameter("deleteOrderId");
        if (deleteOrderId != null && !deleteOrderId.isEmpty()) {
            orderDAO.deleteOrderByGroup(deleteOrderId);
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        request.setAttribute("groupedOrders", groupedOrders);
        request.getRequestDispatcher("orders.jsp").forward(request, response);
    }
}
