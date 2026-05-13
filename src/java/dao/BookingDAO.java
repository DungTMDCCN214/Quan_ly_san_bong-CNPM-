package dao;

import model.*;

import java.sql.*;
import java.util.*;

public class BookingDAO {

    private Connection conn;

    public BookingDAO() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
            conn = DriverManager.getConnection(url, "sa", "123456"); // Đổi mật khẩu nếu cần
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================================================================
    //  COURTS
    // ================================================================
    public List<Court> getAllActiveCourts() {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT court_id, name, type, price_per_hour, status, description, created_at " +
                     "FROM courts WHERE status = 'AVAILABLE' ORDER BY court_id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Court c = new Court();
                c.setCourt_id(rs.getInt("court_id"));
                c.setName(rs.getString("name"));
                c.setType(rs.getString("type"));
                c.setPrice_per_hour(rs.getDouble("price_per_hour"));
                c.setStatus(rs.getString("status"));
                c.setDescription(rs.getString("description"));
                c.setCreated_at(rs.getTimestamp("created_at"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================================================================
    //  TIMESLOTS
    // ================================================================
    public List<TimeSlot> getAllTimeSlots() {
        List<TimeSlot> list = new ArrayList<>();
        String sql = "SELECT time_slot_id, CONVERT(VARCHAR(5), start_time, 108) AS start_time, " +
                     "CONVERT(VARCHAR(5), end_time, 108) AS end_time " +
                     "FROM time_slots ORDER BY start_time";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TimeSlot ts = new TimeSlot();
                ts.setTimeSlotId(rs.getInt("time_slot_id"));
                ts.setStartTime(rs.getString("start_time"));
                ts.setEndTime(rs.getString("end_time"));
                list.add(ts);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================================================================
    //  VALIDATE – Kiểm tra slot đã được đặt chưa
    // ================================================================
    public Set<Integer> getBookedSlotIds(int courtId, String usageDate) {
        Set<Integer> bookedIds = new HashSet<>();
        String sql = "SELECT bd.time_slot_id " +
                     "FROM booking_details bd " +
                     "INNER JOIN bookings b ON bd.booking_id = b.booking_id " +
                     "WHERE bd.court_id = ? AND bd.usage_date = ? AND bd.status != 'CANCELLED'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courtId);
            ps.setString(2, usageDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookedIds.add(rs.getInt("time_slot_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bookedIds;
    }

    public Map<Integer, Map<String, Set<Integer>>> getBookedSlotMatrix(List<Integer> courtIds, List<String> dates) {
        Map<Integer, Map<String, Set<Integer>>> matrix = new HashMap<>();
        if (courtIds.isEmpty() || dates.isEmpty()) return matrix;

        for (int cId : courtIds) {
            matrix.put(cId, new HashMap<>());
            for (String d : dates) {
                matrix.get(cId).put(d, new HashSet<>());
            }
        }

        StringBuilder inCourts = new StringBuilder();
        for (int i = 0; i < courtIds.size(); i++) inCourts.append(i == 0 ? "?" : ",?");
        
        StringBuilder inDates = new StringBuilder();
        for (int i = 0; i < dates.size(); i++) inDates.append(i == 0 ? "?" : ",?");

        String sql = "SELECT bd.court_id, CONVERT(VARCHAR(10), bd.usage_date, 120) AS usage_date, bd.time_slot_id " +
                     "FROM booking_details bd " +
                     "INNER JOIN bookings b ON bd.booking_id = b.booking_id " +
                     "WHERE bd.court_id IN (" + inCourts + ") " +
                     "AND bd.usage_date IN (" + inDates + ") " +
                     "AND bd.status != 'CANCELLED'";
                     
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (int cId : courtIds) ps.setInt(idx++, cId);
            for (String d : dates)  ps.setString(idx++, d);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int cId   = rs.getInt("court_id");
                    String dt = rs.getString("usage_date");
                    int tsId  = rs.getInt("time_slot_id");
                    matrix.get(cId).get(dt).add(tsId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return matrix;
    }

    // ================================================================
    //  LƯU ĐẶT SÂN – Transaction
    // ================================================================
    // Đã thêm tham số double depositAmount
    public int saveBooking(int customerId, int managerId, java.sql.Date bookingDate,
                           List<BookingDetail> details, double totalAmount, double depositAmount) {
        
        // Bổ sung cột deposit_amount vào câu lệnh INSERT
        String sqlBooking = "INSERT INTO bookings (customer_id, manager_id, status, booking_date, deposit_amount) " +
                            "VALUES (?, ?, 'BOOKED', ?, ?) ";
        
        String sqlDetail  = "INSERT INTO booking_details (usage_date, status, time_slot_id, court_id, booking_id, price_per_hour) " +
                            "VALUES (?, 'BOOKED', ?, ?, ?, ?)";

        int newBookingId = -1;
        try {
            conn.setAutoCommit(false);

            // 1. Insert Booking
            try (PreparedStatement ps = conn.prepareStatement(sqlBooking, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, managerId);
                ps.setDate(3, bookingDate);
                ps.setDouble(4, depositAmount);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) newBookingId = rs.getInt(1);
                }
            }

            if (newBookingId <= 0) { conn.rollback(); return -1; }

            // 2. Insert BookingDetails (batch)
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                for (BookingDetail d : details) {
                    ps.setDate(1, d.getUsageDate());
                    ps.setInt(2, d.getTimeSlotId());
                    ps.setInt(3, d.getCourtId());
                    ps.setInt(4, newBookingId);
                    ps.setDouble(5, d.getPricePerHour()); 
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            newBookingId = -1;
        } finally {
            try { conn.setAutoCommit(true); } catch (Exception e) { e.printStackTrace(); }
        }
        return newBookingId;
    }

    // ================================================================
    //  CUSTOMER
    // ================================================================
    public List<Customer> searchCustomersByPhone(String phone) {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT customer_id, full_name, phone, address, customer_type, status, created_at " +
                     "FROM customers WHERE phone LIKE ? AND status = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + phone + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer c = new Customer();
                    c.setCustomer_id(rs.getInt("customer_id"));
                    c.setFull_name(rs.getString("full_name"));
                    c.setPhone(rs.getString("phone"));
                    c.setAddress(rs.getString("address"));
                    c.setCustomer_type(rs.getString("customer_type"));
                    c.setStatus(rs.getString("status"));
                    c.setCreated_at(rs.getTimestamp("created_at"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Customer getCustomerById(int customerId) {
        String sql = "SELECT customer_id, full_name, phone, address, customer_type, status, created_at " +
                     "FROM customers WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer c = new Customer();
                    c.setCustomer_id(rs.getInt("customer_id"));
                    c.setFull_name(rs.getString("full_name"));
                    c.setPhone(rs.getString("phone"));
                    c.setAddress(rs.getString("address"));
                    c.setCustomer_type(rs.getString("customer_type"));
                    c.setStatus(rs.getString("status"));
                    c.setCreated_at(rs.getTimestamp("created_at"));
                    return c;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}