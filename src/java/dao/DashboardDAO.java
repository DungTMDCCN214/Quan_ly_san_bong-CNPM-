package dao;

import java.sql.*;
import java.util.Map;
import java.util.LinkedHashMap;

public class DashboardDAO {

    Connection connection;

    public DashboardDAO() {
        try {
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
            String user = "sa";
            String pass = "123456";

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== THỐNG KÊ SÂN ==========
    public int getTotalCourts() {
        String sql = "SELECT COUNT(*) FROM Courts";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== THỐNG KÊ BOOKING ==========
    public int getTotalBookings() {
        String sql = "SELECT COUNT(*) FROM Bookings";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== TỔNG DOANH THU (SÂN + DỊCH VỤ) ==========
    public double getTotalRevenue() {
        double courtRevenue = 0;
        double serviceRevenue = 0;

        // Doanh thu từ sân (Invoices)
        String sqlCourt = "SELECT ISNULL(SUM(netAmount), 0) FROM Invoices WHERE status = 'PAID'";
        try (PreparedStatement ps = connection.prepareStatement(sqlCourt); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                courtRevenue = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Doanh thu từ dịch vụ (InvoiceDetails)
        String sqlService = "SELECT ISNULL(SUM(quantity * unitPrice), 0) FROM InvoiceDetails id JOIN Invoices i ON id.invoiceId = i.invoiceId WHERE i.status = 'PAID'";
        try (PreparedStatement ps = connection.prepareStatement(sqlService); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                serviceRevenue = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return courtRevenue + serviceRevenue;
    }

    // ========== DOANH THU DỊCH VỤ RIÊNG ==========
    public double getServiceRevenue() {
        String sql = "SELECT ISNULL(SUM(id.quantity * id.unitPrice),0) FROM InvoiceDetails id JOIN Invoices i ON id.invoiceId = i.invoiceId WHERE i.status = 'PAID'";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== DOANH THU SÂN RIÊNG ==========
    public double getCourtRevenue() {
        String sql = "SELECT ISNULL(SUM(netAmount),0) FROM Invoices WHERE status = 'PAID'";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== TỔNG SỐ LƯỢNG DỊCH VỤ ĐÃ BÁN ==========
    public int getTotalServiceQuantity() {
        String sql = "SELECT ISNULL(SUM(quantity),0) FROM InvoiceDetails";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== DOANH THU THEO NGÀY (SÂN + DỊCH VỤ) ==========
    public Map<String, Double> getRevenueByDate() {
        Map<String, Double> revenueMap = new LinkedHashMap<>();

        String sql = "SELECT TOP 7 CAST(createdAt AS DATE) as RevenueDate, SUM(netAmount) as DailyRevenue "
                + "FROM Invoices "
                + "WHERE status = 'PAID' "
                + "GROUP BY CAST(createdAt AS DATE) "
                + "ORDER BY CAST(createdAt AS DATE) ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String date = rs.getDate("RevenueDate").toString();
                double revenue = rs.getDouble("DailyRevenue");
                revenueMap.put(date, revenue);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return revenueMap;
    }

    // ========== DOANH THU DỊCH VỤ THEO NGÀY ==========
    public Map<String, Double> getServiceRevenueByDate() {
        Map<String, Double> revenueMap = new LinkedHashMap<>();

        String sql = "SELECT TOP 7 CAST(i.createdAt AS DATE) as RevenueDate, SUM(id.quantity * id.unitPrice) as DailyRevenue "
                + "FROM InvoiceDetails id JOIN Invoices i ON id.invoiceId = i.invoiceId "
                + "WHERE i.status = 'PAID' "
                + "GROUP BY CAST(i.createdAt AS DATE) "
                + "ORDER BY CAST(i.createdAt AS DATE) ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String date = rs.getDate("RevenueDate").toString();
                double revenue = rs.getDouble("DailyRevenue");
                revenueMap.put(date, revenue);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return revenueMap;
    }

    // ========== TOP DỊCH VỤ BÁN CHẠY ==========
    public Map<String, Integer> getTopServices() {
        Map<String, Integer> topServices = new LinkedHashMap<>();

        String sql = "SELECT TOP 5 s.name, SUM(id.quantity) as total_sold "
                + "FROM InvoiceDetails id "
                + "JOIN Services s ON id.serviceId = s.serviceId "
                + "GROUP BY s.name "
                + "ORDER BY total_sold DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String serviceName = rs.getString("name");
                int totalSold = rs.getInt("total_sold");
                topServices.put(serviceName, totalSold);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return topServices;
    }
}
