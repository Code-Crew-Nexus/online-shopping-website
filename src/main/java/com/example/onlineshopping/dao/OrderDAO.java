package com.example.onlineshopping.dao;

import com.example.onlineshopping.model.Order;
import com.example.onlineshopping.model.Product;
import com.example.onlineshopping.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
    private static final String INSERT_ORDER_SQL =
            "INSERT INTO orders (order_group_id, p_id, u_id, o_quantity, o_date, o_address, order_status) VALUES (?,?,?,?,?,?,?)";

    public boolean insertOrder(Order model) {
        if (model == null) {
            return false;
        }
        return insertOrders(List.of(model));
    }

    public boolean insertOrders(List<Order> models) {
        if (models == null || models.isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement pst = conn.prepareStatement(INSERT_ORDER_SQL)) {
                for (Order model : models) {
                    pst.setString(1, model.getOrderGroupId());
                    pst.setInt(2, model.getId());
                    pst.setInt(3, model.getUid());
                    pst.setInt(4, model.getQuantity());
                    pst.setString(5, model.getDate());
                    pst.setString(6, "Hyderabad Hub (PBL Demo)");
                    pst.setString(7, "Delivered");
                    pst.addBatch();
                }
                pst.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException | IllegalStateException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public List<Order> getOrdersByUser(int userId) {
        List<Order> orders = new ArrayList<>();
        String query = "SELECT id, order_group_id, p_id, u_id, o_quantity, o_date, order_status FROM orders WHERE u_id = ? ORDER BY order_group_id DESC, id DESC";

        ProductDAO productDAO = new ProductDAO();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {

            pst.setInt(1, userId);

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    int productId = rs.getInt("p_id");

                    order.setOrderId(rs.getInt("id"));
                    order.setOrderGroupId(rs.getString("order_group_id"));
                    order.setId(productId);
                    order.setUid(rs.getInt("u_id"));
                    order.setQuantity(rs.getInt("o_quantity"));
                    order.setDate(rs.getString("o_date"));
                    order.setOrderStatus(rs.getString("order_status"));

                    Product product = productDAO.getProductById(productId);
                    if (product != null) {
                        order.setName(product.getName());
                        order.setDescription(product.getDescription());
                        order.setPrice(product.getPrice());
                        order.setImageUrl(product.getImageUrl());
                    } else {
                        order.setName("Product #" + productId);
                        order.setDescription("Product details unavailable");
                        order.setPrice(0);
                        order.setImageUrl("");
                    }

                    orders.add(order);
                }
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }

        return orders;
    }

    public boolean deleteOrderByGroup(String orderGroupId) {
        String query = "DELETE FROM orders WHERE order_group_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setString(1, orderGroupId);
            return pst.executeUpdate() > 0;
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
            return false;
        }
    }
}
