package model;

import java.sql.Timestamp;

public class Invoice {
    private int invoice_id;
    // ĐÃ ĐỔI TÊN: booking_id -> booking_detail_id
    private int booking_detail_id; 
    private double total_amount;
    private double discount_amount;
    private double net_amount;
    private String status;
    private Timestamp created_at;
    private String payment_method;

    // --- CÁC TRƯỜNG PHỤ ĐỂ HIỂN THỊ LÊN GIAO DIỆN ---
    private String customer_name;
    private String customer_phone;
    private String created_date_str;
    private double deposit_amount;
    
    public Invoice() {}

    public Invoice(int invoice_id, int booking_detail_id, double total_amount, double discount_amount, double net_amount, String status, Timestamp created_at) {
        this.invoice_id = invoice_id;
        this.booking_detail_id = booking_detail_id;
        this.total_amount = total_amount;
        this.discount_amount = discount_amount;
        this.net_amount = net_amount;
        this.status = status;
        this.created_at = created_at;
    }

    // Getters / Setters chuẩn
    public int getInvoice_id() { return invoice_id; }
    public void setInvoice_id(int invoice_id) { this.invoice_id = invoice_id; }

    // ĐÃ ĐỔI TÊN Ở ĐÂY
    public int getBooking_detail_id() { return booking_detail_id; }
    public void setBooking_detail_id(int booking_detail_id) { this.booking_detail_id = booking_detail_id; }

    public double getTotal_amount() { return total_amount; }
    public void setTotal_amount(double total_amount) { this.total_amount = total_amount; }

    public double getDiscount_amount() { return discount_amount; }
    public void setDiscount_amount(double discount_amount) { this.discount_amount = discount_amount; }

    public double getNet_amount() { return net_amount; }
    public void setNet_amount(double net_amount) { this.net_amount = net_amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    // Getters / Setters phụ
    public String getCustomer_name() { return customer_name; }
    public void setCustomer_name(String customer_name) { this.customer_name = customer_name; }

    public String getCustomer_phone() { return customer_phone; }
    public void setCustomer_phone(String customer_phone) { this.customer_phone = customer_phone; }

    public String getCreated_date_str() { return created_date_str; }
    public void setCreated_date_str(String created_date_str) { this.created_date_str = created_date_str; }
    
    public double getDeposit_amount() { return deposit_amount; }
    public void setDeposit_amount(double deposit_amount) { this.deposit_amount = deposit_amount; }
    
    public String getPayment_method() { return payment_method; }
    public void setPayment_method(String payment_method) { this.payment_method = payment_method; }
}