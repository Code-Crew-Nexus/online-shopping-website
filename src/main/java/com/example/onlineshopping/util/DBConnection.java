package com.example.onlineshopping.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String DEFAULT_DB_HOST = "localhost";
    private static final String DEFAULT_DB_PORT = "3306";
    private static final String DEFAULT_DB_NAME = "flipzon_shop";
    private static final String DEFAULT_DB_USER = "flipzon_app";
    private static final String DEFAULT_DB_PASSWORD = "flipzon_app_password";
    private static final String JDBC_OPTIONS =
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static String resolve(String envKey, String defaultValue) {
        String value = System.getenv(envKey);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbHost = resolve("SHOP_DB_HOST", DEFAULT_DB_HOST);
            String dbPort = resolve("SHOP_DB_PORT", DEFAULT_DB_PORT);
            String dbName = resolve("SHOP_DB_NAME", DEFAULT_DB_NAME);
            String dbUser = resolve("SHOP_DB_USER", DEFAULT_DB_USER);
            String dbPassword = resolve("SHOP_DB_PASSWORD", DEFAULT_DB_PASSWORD);

            String jdbcUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + JDBC_OPTIONS;

            return DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
        } catch (Exception e) {
            throw new IllegalStateException("Unable to connect to the FlipZon database.", e);
        }
    }
}
