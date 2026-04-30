package dao;

import java.sql.*;
import java.util.Map;
import java.util.LinkedHashMap;

public class DashboardDAO {

    Connection connection;

    public DashboardDAO() {
        try {
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_Pick;encrypt=true;trustServerCertificate=true";
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
        String sqlCourt = "SELECT ISNULL(SUM(total_amount), 0) FROM Invoices WHERE payment_status = 'paid'";
        try (PreparedStatement ps = connection.prepareStatement(sqlCourt); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                courtRevenue = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Doanh thu từ dịch vụ (Service_Usage)
        String sqlService = "SELECT ISNULL(SUM(total_price), 0) FROM Service_Usage";
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
        String sql = "SELECT ISNULL(SUM(total_price),0) FROM Service_Usage";
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
        String sql = "SELECT ISNULL(SUM(court_amount),0) FROM Invoices WHERE payment_status = 'paid'";
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
        String sql = "SELECT ISNULL(SUM(quantity),0) FROM Service_Usage";
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

        String sql = "SELECT TOP 7 CAST(created_at AS DATE) as RevenueDate, SUM(total_amount) as DailyRevenue "
                + "FROM Invoices "
                + "WHERE payment_status = 'paid' "
                + "GROUP BY CAST(created_at AS DATE) "
                + "ORDER BY CAST(created_at AS DATE) ASC";

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

        String sql = "SELECT TOP 7 CAST(created_at AS DATE) as RevenueDate, SUM(total_price) as DailyRevenue "
                + "FROM Service_Usage "
                + "GROUP BY CAST(created_at AS DATE) "
                + "ORDER BY CAST(created_at AS DATE) ASC";

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

        String sql = "SELECT TOP 5 s.service_name, SUM(su.quantity) as total_sold "
                + "FROM Service_Usage su "
                + "JOIN Services s ON su.service_id = s.service_id "
                + "GROUP BY s.service_name "
                + "ORDER BY total_sold DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String serviceName = rs.getString("service_name");
                int totalSold = rs.getInt("total_sold");
                topServices.put(serviceName, totalSold);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return topServices;
    }
}
