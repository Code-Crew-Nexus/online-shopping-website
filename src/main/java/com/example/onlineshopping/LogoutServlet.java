package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "LogoutServlet", value = "/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Get the current session
        HttpSession session = request.getSession(false);

        if (session != null) {
            // 2. Destroy the session and all its attributes (authUser, cart-list, etc.)
            session.invalidate();
        }

        // 3. Redirect to login page with a logged-out message
        response.sendRedirect("login.jsp?msg=logout");
    }
}