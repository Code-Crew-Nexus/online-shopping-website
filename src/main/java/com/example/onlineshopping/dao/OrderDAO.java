package com.example.onlineshopping.dao;

import com.example.onlineshopping.model.Order;
import com.example.onlineshopping.model.Product;
import com.example.onlineshopping.util.DBConnection;
import java.sql.DatabaseMetaData;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class OrderDAO {
    private static final String INSERT_ORDER_SQL =
            "INSERT INTO orders (order_group_id, p_id, u_id, o_quantity, o_date, o_address, order_status) VALUES (?,?,?,?,?,?,?)";
    private static final String UPSERT_PRODUCT_SQL =
        "INSERT INTO products (id, name, price, description, image_url) VALUES (?,?,?,?,?) " +
            "ON DUPLICATE KEY UPDATE name = VALUES(name), price = VALUES(price), description = VALUES(description), image_url = VALUES(image_url)";

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

            ensureOrdersSchema(conn);

            if (!ensureProductsExistForOrders(conn, models)) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement pst = conn.prepareStatement(INSERT_ORDER_SQL)) {
                for (Order model : models) {
                    pst.setString(1, model.getOrderGroupId());
                    pst.setInt(2, model.getId());
                    pst.setInt(3, model.getUid());
                    pst.setInt(4, model.getQuantity());
                    pst.setString(5, model.getDate());
                    pst.setString(6, "Hyderabad Hub (PBL Demo)");
                    pst.setString(7, model.getOrderStatus() == null ? "Delivered" : model.getOrderStatus());
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

    private void ensureOrdersSchema(Connection conn) throws SQLException {
        boolean hasOrderGroupId = hasColumn(conn, "orders", "order_group_id");
        boolean hasOrderStatus = hasColumn(conn, "orders", "order_status");

        if (!hasOrderGroupId) {
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("ALTER TABLE orders ADD COLUMN order_group_id VARCHAR(50) NULL AFTER id");
                st.executeUpdate("UPDATE orders SET order_group_id = CONCAT('LEGACY-', id) WHERE order_group_id IS NULL OR order_group_id = ''");
            }
        }

        if (!hasOrderStatus) {
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("ALTER TABLE orders ADD COLUMN order_status VARCHAR(20) NULL DEFAULT 'Delivered' AFTER o_address");
                st.executeUpdate("UPDATE orders SET order_status = 'Delivered' WHERE order_status IS NULL OR order_status = ''");
            }
        }

        if (!hasIndex(conn, "orders", "idx_order_group")) {
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("CREATE INDEX idx_order_group ON orders(order_group_id)");
            }
        }

        if (!hasIndex(conn, "orders", "idx_user_date")) {
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("CREATE INDEX idx_user_date ON orders(u_id, o_date)");
            }
        }
    }

    private boolean hasColumn(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet rs = metaData.getColumns(conn.getCatalog(), null, tableName, columnName)) {
            return rs.next();
        }
    }

    private boolean hasIndex(Connection conn, String tableName, String indexName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet rs = metaData.getIndexInfo(conn.getCatalog(), null, tableName, false, false)) {
            while (rs.next()) {
                String idx = rs.getString("INDEX_NAME");
                if (idx != null && idx.equalsIgnoreCase(indexName)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean ensureProductsExistForOrders(Connection conn, List<Order> models) throws SQLException {
        Set<Integer> requestedProductIds = new HashSet<>();
        for (Order model : models) {
            requestedProductIds.add(model.getId());
        }

        if (requestedProductIds.isEmpty()) {
            return false;
        }

        Set<Integer> existingProductIds = new HashSet<>();
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < requestedProductIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }

        String findExistingSql = "SELECT id FROM products WHERE id IN (" + placeholders + ")";
        try (PreparedStatement pst = conn.prepareStatement(findExistingSql)) {
            int index = 1;
            for (Integer productId : requestedProductIds) {
                pst.setInt(index++, productId);
            }

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    existingProductIds.add(rs.getInt("id"));
                }
            }
        }

        Set<Integer> missingProductIds = new HashSet<>(requestedProductIds);
        missingProductIds.removeAll(existingProductIds);
        if (missingProductIds.isEmpty()) {
            return true;
        }

        ProductDAO productDAO = new ProductDAO();
        Map<Integer, Product> catalog = new HashMap<>();
        for (Product product : productDAO.getAllProducts()) {
            catalog.put(product.getId(), product);
        }

        try (PreparedStatement pst = conn.prepareStatement(UPSERT_PRODUCT_SQL)) {
            for (Integer productId : missingProductIds) {
                Product product = catalog.get(productId);
                if (product == null) {
                    return false;
                }

                pst.setInt(1, product.getId());
                pst.setString(2, product.getName());
                pst.setDouble(3, product.getPrice());
                pst.setString(4, product.getDescription());
                pst.setString(5, product.getImageUrl());
                pst.addBatch();
            }
            pst.executeBatch();
        }

        return true;
    }

    public List<Order> getOrdersByUser(int userId) {
        List<Order> orders = new ArrayList<>();
        String query = "SELECT id, order_group_id, p_id, u_id, o_quantity, o_date, order_status FROM orders WHERE u_id = ? ORDER BY order_group_id DESC, id DESC";

        ProductDAO productDAO = new ProductDAO();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {

            ensureOrdersSchema(conn);

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
            ensureOrdersSchema(conn);
            pst.setString(1, orderGroupId);
            return pst.executeUpdate() > 0;
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Order> getOrdersByGroup(int userId, String orderGroupId) {
        List<Order> orders = new ArrayList<>();
        String query = "SELECT o.id, o.order_group_id, o.p_id, o.u_id, o.o_quantity, o.o_date, o.order_status, " +
                "p.name, p.description, p.price, p.image_url " +
                "FROM orders o LEFT JOIN products p ON o.p_id = p.id " +
                "WHERE o.u_id = ? AND o.order_group_id = ? ORDER BY o.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {

            ensureOrdersSchema(conn);

            pst.setInt(1, userId);
            pst.setString(2, orderGroupId);

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

                    String productName = rs.getString("name");
                    order.setName(productName == null || productName.isBlank() ? "Product #" + productId : productName);
                    order.setDescription(rs.getString("description") == null ? "" : rs.getString("description"));
                    order.setPrice(rs.getDouble("price"));
                    order.setImageUrl(rs.getString("image_url") == null ? "" : rs.getString("image_url"));

                    orders.add(order);
                }
            }
        } catch (SQLException | IllegalStateException e) {
            e.printStackTrace();
        }

        return orders;
    }
}
