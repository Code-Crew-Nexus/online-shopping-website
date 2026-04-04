package com.example.onlineshopping.dao;

import com.example.onlineshopping.model.Order;
import com.example.onlineshopping.util.DBConnection;
import java.sql.*;

public class OrderDAO {

    public boolean insertOrder(Order model) {
        boolean result = false;
        // Mapping our Java Order object to the MySQL columns
        String query = "INSERT INTO orders (p_id, u_id, o_quantity, o_date, o_address) VALUES (?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {

            pst.setInt(1, model.getId());
            pst.setInt(2, model.getUid());
            pst.setInt(3, model.getQuantity());
            pst.setString(4, model.getDate());
            pst.setString(5, "Hyderabad Hub (PBL Demo)"); // Static for demo

            int rowAffected = pst.executeUpdate();
            if (rowAffected > 0) {
                result = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
}