package com.example.onlineshopping.model;

/*
   We extend Product so we automatically have
   id, name, category, price, and image
*/
public class Order extends Product {
    private int orderId;
    private String orderGroupId;
    private int uid;
    private int quantity;
    private String date;
    private String orderStatus;

    public Order() {
    }

    // Getters and Setters
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public String getOrderGroupId() { return orderGroupId; }
    public void setOrderGroupId(String orderGroupId) { this.orderGroupId = orderGroupId; }

    public int getUid() { return uid; }
    public void setUid(int uid) { this.uid = uid; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
}