/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author Admin
 */
public class Court {
    private int court_id;
    private String name;
    private String type;              // Thêm trường type
    private double price_per_hour;
    private String status;
    private String description;
    private Timestamp created_at;     // Thêm trường created_at
    
    public Court(){}

    // Constructor cũ (giữ lại để tương thích ngược nếu cần)
    public Court(int court_id, String name, double price_per_hour, String status, String description) {
        this.court_id = court_id;
        this.name = name;
        this.price_per_hour = price_per_hour;
        this.status = status;
        this.description = description;
    }
    
    // Constructor mới đầy đủ (có type và created_at)
    public Court(int court_id, String name, String type, double price_per_hour, String status, String description, Timestamp created_at) {
        this.court_id = court_id;
        this.name = name;
        this.type = type;
        this.price_per_hour = price_per_hour;
        this.status = status;
        this.description = description;
        this.created_at = created_at;
    }
    
    // Constructor không có created_at (dùng khi insert mới)
    public Court(int court_id, String name, String type, double price_per_hour, String status, String description) {
        this.court_id = court_id;
        this.name = name;
        this.type = type;
        this.price_per_hour = price_per_hour;
        this.status = status;
        this.description = description;
    }

    // Getters and Setters
    public int getCourt_id() {
        return court_id;
    }

    public void setCourt_id(int court_id) {
        this.court_id = court_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }

    public double getPrice_per_hour() {
        return price_per_hour;
    }

    public void setPrice_per_hour(double price_per_hour) {
        this.price_per_hour = price_per_hour;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    public Timestamp getCreated_at() {
        return created_at;
    }
    
    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
    
    // Optional: Thêm toString() để debug dễ dàng
    @Override
    public String toString() {
        return "Court{" +
                "court_id=" + court_id +
                ", name='" + name + '\'' +
                ", type='" + type + '\'' +
                ", price_per_hour=" + price_per_hour +
                ", status='" + status + '\'' +
                ", description='" + description + '\'' +
                ", created_at=" + created_at +
                '}';
    }
}