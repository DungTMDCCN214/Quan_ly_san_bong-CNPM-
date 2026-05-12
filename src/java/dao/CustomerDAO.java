package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Customer;

public class CustomerDAO {
    private static final String URL = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASS = "123456";

    public CustomerDAO() {
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy SQL Server JDBC Driver. Hãy thêm mssql-jdbc.jar vao WEB-INF/lib.", e);
        }
    }

    public List<Customer> searchCustomers(String keyword, String customer_type, String status) {
        List<Customer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Customers WHERE 1 = 1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (fullName LIKE ? OR phone LIKE ?)");
            String likeKeyword = "%" + keyword.trim() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (customer_type != null && !customer_type.trim().isEmpty() && !"ALL".equals(customer_type)) {
            sql.append(" AND customerType = ?");
            params.add(customer_type.trim());
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equals(status)) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        sql.append(" ORDER BY createdAt DESC, customerId DESC");

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCustomer(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Customer getCustomerById(int id) {
        String sql = "SELECT * FROM Customers WHERE customerId = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomer(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean phoneExists(String phone) {
        return phoneExistsExceptId(phone, 0);
    }

    public boolean phoneExistsExceptId(String phone, int customer_id) {
        String sql = "SELECT COUNT(*) FROM Customers WHERE phone = ? AND customerId <> ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, customer_id);

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

    public void insertCustomer(Customer customer) {
        String sql = "INSERT INTO Customers(fullName, phone, address, customerType, status, createdAt) "
                + "VALUES(?, ?, ?, ?, 'ACTIVE', GETDATE())";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customer.getFull_name());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getAddress());
            ps.setString(4, customer.getCustomer_type());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateCustomer(Customer customer) {
        String sql = "UPDATE Customers SET fullName = ?, phone = ?, address = ?, customerType = ? "
                + "WHERE customerId = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customer.getFull_name());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getAddress());
            ps.setString(4, customer.getCustomer_type());
            ps.setInt(5, customer.getCustomer_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int customer_id, String status) {
        String sql = "UPDATE Customers SET status = ? WHERE customerId = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, customer_id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Customer mapCustomer(ResultSet rs) throws SQLException {
        return new Customer(
                rs.getInt("customerId"),
                rs.getString("fullName"),
                rs.getString("phone"),
                rs.getString("address"),
                rs.getString("customerType"),
                rs.getString("status"),
                rs.getTimestamp("createdAt")
        );
    }
}

