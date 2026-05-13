package model;

public class InvoiceDetail {
    private int id;
    private int invoice_id;
    private int service_id;
    private int quantity;
    private double unit_price;

    // Các trường phụ lấy từ bảng Services để hiển thị lên UI
    private String service_name;
    private String service_image;

    public InvoiceDetail() {
    }

    public InvoiceDetail(int id, int invoice_id, int service_id, int quantity, double unit_price) {
        this.id = id;
        this.invoice_id = invoice_id;
        this.service_id = service_id;
        this.quantity = quantity;
        this.unit_price = unit_price;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getInvoice_id() { return invoice_id; }
    public void setInvoice_id(int invoice_id) { this.invoice_id = invoice_id; }

    public int getService_id() { return service_id; }
    public void setService_id(int service_id) { this.service_id = service_id; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getUnit_price() { return unit_price; }
    public void setUnit_price(double unit_price) { this.unit_price = unit_price; }

    public String getService_name() { return service_name; }
    public void setService_name(String service_name) { this.service_name = service_name; }

    public String getService_image() { return service_image; }
    public void setService_image(String service_image) { this.service_image = service_image; }
}