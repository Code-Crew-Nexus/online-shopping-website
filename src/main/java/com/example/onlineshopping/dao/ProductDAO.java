package com.example.onlineshopping.dao;

import com.example.onlineshopping.model.Cart;
import com.example.onlineshopping.model.Product;
import com.example.onlineshopping.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setImageUrl(rs.getString("image_url"));
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public List<Cart> getCartProducts(ArrayList<Cart> cartList) {
        List<Cart> products = new ArrayList<>();
        if (cartList == null || cartList.isEmpty()) {
            return products;
        }

        String query = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {

            for (Cart cartItem : cartList) {
                pst.setInt(1, cartItem.getId());
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        Cart row = new Cart();
                        row.setId(rs.getInt("id"));
                        row.setName(rs.getString("name"));
                        row.setDescription(rs.getString("description"));
                        row.setPrice(rs.getDouble("price"));
                        row.setImageUrl(rs.getString("image_url"));
                        row.setQuantity(cartItem.getQuantity());
                        products.add(row);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public double getTotalCartPrice(ArrayList<Cart> cartList) {
        double total = 0;
        for (Cart item : getCartProducts(cartList)) {
            total += item.getPrice() * item.getQuantity();
        }
        return total;
    }
}