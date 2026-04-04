package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.User;
import com.example.onlineshopping.dao.UserDAO;
import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.loginUser(email, pass);

        if (user != null) {
            // SUCCESS: Create a session
            HttpSession session = request.getSession();
            session.setAttribute("authUser", user); // Store the whole user object

            // Redirect to products page (we'll make this next)
            response.sendRedirect("products");
        } else {
            // FAILURE: Send back to login with error flag
            response.sendRedirect("login.jsp?error=1");
        }
    }
}