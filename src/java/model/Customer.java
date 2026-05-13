package model;

import java.sql.Timestamp;

public class Customer {
    private int customer_id;
    private String full_name;
    private String phone;
    private String address;
    private String customer_type;
    private String status;
    private Timestamp created_at;

    public Customer() {
    }

    public Customer(int customer_id, String full_name, String phone, String address,
            String customer_type, String status, Timestamp created_at) {
        this.customer_id = customer_id;
        this.full_name = full_name;
        this.phone = phone;
        this.address = address;
        this.customer_type = customer_type;
        this.status = status;
        this.created_at = created_at;
    }

    public Customer(int customer_id, String full_name, String phone, String address,
            String customer_type, String status) {
        this.customer_id = customer_id;
        this.full_name = full_name;
        this.phone = phone;
        this.address = address;
        this.customer_type = customer_type;
        this.status = status;
    }

    public int getCustomer_id() {
        return customer_id;
    }

    public void setCustomer_id(int customer_id) {
        this.customer_id = customer_id;
    }

    public String getFull_name() {
        return full_name;
    }

    public void setFull_name(String full_name) {
        this.full_name = full_name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCustomer_type() {
        return customer_type;
    }

    public void setCustomer_type(String customer_type) {
        this.customer_type = customer_type;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
