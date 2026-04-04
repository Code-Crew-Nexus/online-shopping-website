package com.example.onlineshopping;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.onlineshopping.model.User;
import com.example.onlineshopping.dao.UserDAO;
import java.io.IOException;

// This URL must match the 'action' attribute in your index.jsp form
@WebServlet(name = "RegisterServlet", value = "/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Retrieve data from the form
        String name = request.getParameter("username");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        // 2. Wrap data in the Model object
        User newUser = new User();
        newUser.setUsername(name);
        newUser.setEmail(email);
        newUser.setPassword(pass);

        // 3. Use DAO to save to Database
        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.registerUser(newUser);

        // 4. Redirect based on result
        if (success) {
            // Registration worked! Send them to login (we will create this later)
            response.sendRedirect("index.jsp?msg=success");
        } else {
            // Something went wrong (e.g., duplicate email)
            response.sendRedirect("index.jsp?msg=error");
        }
    }
}