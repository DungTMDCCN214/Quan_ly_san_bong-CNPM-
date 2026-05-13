package model;

public class Service {
    private int service_id;
    private String name;
    private double price; 
    private int stock_quantity;
    private String status;
    private String description;
    private String image_path;

    public Service() {
    }

    public Service(int service_id, String name, double price, int stock_quantity, String status, String description, String image_path) {
        this.service_id = service_id;
        this.name = name;
        this.price = price;
        this.stock_quantity = stock_quantity;
        this.status = status;
        this.description = description;
        this.image_path = image_path;
    }

    public int getService_id() {
        return service_id;
    }

    public void setService_id(int service_id) {
        this.service_id = service_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock_quantity() {
        return stock_quantity;
    }

    public void setStock_quantity(int stock_quantity) {
        this.stock_quantity = stock_quantity;
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
    
    public String getImage_path() {
        return image_path == null ? "default-service.png" : image_path;
    }

    public void setImage_path(String image_path) {
        this.image_path = image_path;
    }
}