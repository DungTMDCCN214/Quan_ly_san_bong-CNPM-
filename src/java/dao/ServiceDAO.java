package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Service;

public class ServiceDAO {
    private static final String URL = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASS = "123456"; 

    public ServiceDAO() {
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy SQL Server JDBC Driver.", e);
        }
    }

    public List<Service> searchServices(String keyword, String status) {
        List<Service> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM services WHERE 1 = 1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND name LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equals(status)) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        sql.append(" ORDER BY service_id DESC");

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapService(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Service getServiceById(int id) {
        String sql = "SELECT * FROM services WHERE service_id = ?";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapService(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Phục vụ rule BR4.1-2 và BR4.2-2: Tên không được trùng
    public boolean nameExistsExceptId(String name, int service_id) {
        String sql = "SELECT COUNT(*) FROM services WHERE name = ? AND service_id <> ?";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, service_id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void insertService(Service service) {
        String sql = "INSERT INTO services(name, price, stock_quantity, status, description, image_path) "
                + "VALUES(?, ?, ?, 'ACTIVE', ?, ?)";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, service.getName());
            ps.setDouble(2, service.getPrice());
            ps.setInt(3, service.getStock_quantity());
            ps.setString(4, service.getDescription());
            ps.setString(5, service.getImage_path()); 
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateService(Service service) {
        String sql = "UPDATE services SET name = ?, price = ?, stock_quantity = ?, description = ?, image_path = ? "
                + "WHERE service_id = ?";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, service.getName());
            ps.setDouble(2, service.getPrice());
            ps.setInt(3, service.getStock_quantity());
            ps.setString(4, service.getDescription());
            ps.setString(5, service.getImage_path()); 
            ps.setInt(6, service.getService_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Xóa mềm: Chuyển status thành INACTIVE (BR4.3-2)
    public void updateStatus(int service_id, String status) {
        String sql = "UPDATE services SET status = ? WHERE service_id = ?";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, service_id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Kiểm tra xem dịch vụ có trong hóa đơn chưa thanh toán không (BR4.3-1)
    public boolean checkServiceInUnpaidInvoice(int service_id) {
        String sql = "SELECT COUNT(*) FROM invoice_details idet "
                   + "JOIN invoices i ON idet.invoice_id = i.invoice_id "
                   + "WHERE idet.service_id = ? AND i.status = 'UNPAID'";
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, service_id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Service mapService(ResultSet rs) throws SQLException {
        return new Service(
                rs.getInt("service_id"),
                rs.getString("name"),
                rs.getDouble("price"),
                rs.getInt("stock_quantity"),
                rs.getString("status"),
                rs.getString("description"),
                rs.getString("image_path") 
        );
    }
}