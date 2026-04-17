package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.User;
import com.example.onlineshopping.dao.UserDAO;
import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        if (email == null || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid-email");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.loginUser(email.trim(), pass);

        if (user != null) {
            // SUCCESS: Create a session
            HttpSession session = request.getSession();
            session.setAttribute("authUser", user); // Store the whole user object

            // Redirect to products page (we'll make this next)
            response.sendRedirect(request.getContextPath() + "/products");
        } else {
            // FAILURE: Send back to login with error flag
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
        }
    }
}