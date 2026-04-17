package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.User;
import com.example.onlineshopping.dao.UserDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

// This URL must match the 'action' attribute in your index.jsp form
@WebServlet(name = "RegisterServlet", value = "/register")
public class RegisterServlet extends HttpServlet {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Retrieve data from the form
        String name = request.getParameter("username");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        if (email == null || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?msg=invalid-email");
            return;
        }

        // 2. Wrap data in the Model object
        User newUser = new User();
        newUser.setUsername(name);
        newUser.setEmail(email.trim());
        newUser.setPassword(pass);

        UserDAO userDAO = new UserDAO();
        if (userDAO.emailExists(newUser.getEmail())) {
            String encodedEmail = URLEncoder.encode(newUser.getEmail(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login.jsp?email=" + encodedEmail + "&msg=exists");
            return;
        }

        // 3. Use DAO to save to Database
        boolean success = userDAO.registerUser(newUser);

        // 4. Redirect based on result
        if (success) {
            // Registration worked! Send them to login (we will create this later)
            response.sendRedirect(request.getContextPath() + "/index.jsp?msg=success");
        } else {
            // Something went wrong (e.g., duplicate email)
            response.sendRedirect(request.getContextPath() + "/index.jsp?msg=error");
        }
    }
}