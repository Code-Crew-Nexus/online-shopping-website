package com.example.onlineshopping.dao;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.example.onlineshopping.model.Cart;
import com.example.onlineshopping.model.Product;
import com.example.onlineshopping.util.DBConnection;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
    private static final String PRODUCTS_JSON_PATH = "data/products.json";

    public List<Product> getAllProducts() {
        List<Product> fromJson = getProductsFromJson();
        if (!fromJson.isEmpty()) {
            return fromJson;
        }

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
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return products;
    }

    public Product getProductById(int id) {
        for (Product p : getAllProducts()) {
            if (p.getId() == id) {
                return p;
            }
        }
        return null;
    }

    public List<Cart> getCartProducts(ArrayList<Cart> cartList) {
        List<Cart> products = new ArrayList<>();
        if (cartList == null || cartList.isEmpty()) {
            return products;
        }

        for (Cart cartItem : cartList) {
            Product product = getProductById(cartItem.getId());
            if (product != null) {
                Cart row = new Cart();
                row.setId(product.getId());
                row.setName(product.getName());
                row.setDescription(product.getDescription());
                row.setPrice(product.getPrice());
                row.setImageUrl(product.getImageUrl());
                row.setQuantity(cartItem.getQuantity());
                products.add(row);
            }
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

    private List<Product> getProductsFromJson() {
        try (InputStream input = Thread.currentThread()
                .getContextClassLoader()
                .getResourceAsStream(PRODUCTS_JSON_PATH)) {
            if (input == null) {
                return new ArrayList<>();
            }

            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(input, new TypeReference<List<Product>>() {});
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}
