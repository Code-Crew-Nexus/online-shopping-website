package com.example.onlineshopping.model;

/*
   We extend Product so we automatically have
   id, name, category, price, and image
*/
public class Order extends Product {
    private int orderId;
    private int uid;
    private int quantity;
    private String date;

    public Order() {
    }

    // Getters and Setters
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getUid() { return uid; }
    public void setUid(int uid) { this.uid = uid; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
}