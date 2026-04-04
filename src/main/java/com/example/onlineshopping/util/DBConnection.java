package com.example.onlineshopping.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // DO NOT make the connection static and persistent
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Every time this is called, we return a fresh connection
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/shop_db", "root", "saikrishna011");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
//public class DBConnection {
//    private static Connection connection = null;
//
//    public static Connection getConnection() {
//        if (connection == null) {
//            try {
//                // The Driver for MySQL 8+
//                Class.forName("com.mysql.cj.jdbc.Driver");
//                // Replace 'shop_db', 'root', and 'password' with your MySQL details
//                connection = DriverManager.getConnection(
//                        "jdbc:mysql://localhost:3306/shop_db", "root", "saikrishna011");
//            } catch (ClassNotFoundException | SQLException e) {
//                e.printStackTrace();
////                log.error("Ops!", e);
//            }
//        }
//        return connection;
//    }
//}