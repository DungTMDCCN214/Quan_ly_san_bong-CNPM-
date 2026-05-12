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
            conn = DriverManager.getConnection(url, "sa", "123456");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================================================================
    //  COURTS
    // ================================================================

    /**
     * Lấy toàn bộ sân có status = ACTIVE
     */
    public List<Court> getAllActiveCourts() {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT courtId, name, type, pricePerHour, status, description, createdAt " +
                     "FROM Courts WHERE status = 'ACTIVE' ORDER BY courtId";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Court c = new Court();
                c.setCourt_id(rs.getInt("courtId"));
                c.setName(rs.getString("name"));
                c.setType(rs.getString("type"));
                c.setPrice_per_hour(rs.getDouble("pricePerHour"));
                c.setStatus(rs.getString("status"));
                c.setDescription(rs.getString("description"));
                c.setCreated_at(rs.getTimestamp("createdAt"));
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

    /**
     * Lấy toàn bộ TimeSlots (đã sắp xếp theo startTime)
     */
    public List<TimeSlot> getAllTimeSlots() {
        List<TimeSlot> list = new ArrayList<>();
        String sql = "SELECT timeSlotId, CONVERT(VARCHAR(5), startTime, 108) AS startTime, " +
                     "CONVERT(VARCHAR(5), endTime, 108) AS endTime " +
                     "FROM TimeSlots ORDER BY startTime";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TimeSlot ts = new TimeSlot();
                ts.setTimeSlotId(rs.getInt("timeSlotId"));
                ts.setStartTime(rs.getString("startTime"));
                ts.setEndTime(rs.getString("endTime"));
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

    /**
     * Trả về Set các timeSlotId đã bị đặt của một sân trong một ngày cụ thể.
     */
    public Set<Integer> getBookedSlotIds(int courtId, String usageDate) {
        Set<Integer> bookedIds = new HashSet<>();
        String sql = "SELECT bd.timeSlotId " +
                     "FROM BookingDetails bd " +
                     "INNER JOIN Bookings b ON bd.bookingId = b.bookingId " +
                     "WHERE bd.courtId = ? AND bd.usageDate = ? AND bd.status != 'CANCELLED'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courtId);
            ps.setString(2, usageDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookedIds.add(rs.getInt("timeSlotId"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bookedIds;
    }

    /**
     * Lấy map: courtId -> (usageDate -> Set<timeSlotId> đã đặt)
     */
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
        for (int i = 0; i < courtIds.size(); i++) {
            inCourts.append(i == 0 ? "?" : ",?");
        }
        StringBuilder inDates = new StringBuilder();
        for (int i = 0; i < dates.size(); i++) {
            inDates.append(i == 0 ? "?" : ",?");
        }

        String sql = "SELECT bd.courtId, CONVERT(VARCHAR(10), bd.usageDate, 120) AS usageDate, bd.timeSlotId " +
                     "FROM BookingDetails bd " +
                     "INNER JOIN Bookings b ON bd.bookingId = b.bookingId " +
                     "WHERE bd.courtId IN (" + inCourts + ") " +
                     "AND bd.usageDate IN (" + inDates + ") " +
                     "AND bd.status != 'CANCELLED'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (int cId : courtIds) ps.setInt(idx++, cId);
            for (String d : dates)  ps.setString(idx++, d);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int cId   = rs.getInt("courtId");
                    String dt = rs.getString("usageDate");
                    int tsId  = rs.getInt("timeSlotId");
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

    /**
     * Lưu đơn đặt sân (Đổi totalAmount từ int sang double để thống nhất luồng tiền tệ)
     */
    public int saveBooking(int customerId, int managerId, java.sql.Date bookingDate,
                           List<BookingDetail> details, double totalAmount) {
        String sqlBooking = "INSERT INTO Bookings (customerId, managerId, status, bookingDate) " +
                            "VALUES (?, ?, 'BOOKED', ?) ";
        String sqlDetail  = "INSERT INTO BookingDetails (usageDate, status, timeSlotId, courtId, bookingId) " +
                            "VALUES (?, 'BOOKED', ?, ?, ?)";
        String sqlInvoice = "INSERT INTO Invoices (bookingId, totalAmount, discountAmount, netAmount, status) " +
                            "VALUES (?, ?, 0, ?, 'UNPAID')";

        int newBookingId = -1;
        try {
            conn.setAutoCommit(false);

            // 1. Insert Booking
            try (PreparedStatement ps = conn.prepareStatement(sqlBooking, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, managerId);
                ps.setDate(3, bookingDate);
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
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // 3. Insert Invoice (Dùng setDouble)
            try (PreparedStatement ps = conn.prepareStatement(sqlInvoice)) {
                ps.setInt(1, newBookingId);
                ps.setDouble(2, totalAmount);
                ps.setDouble(3, totalAmount); 
                ps.executeUpdate();
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
        String sql = "SELECT customerId, fullName, phone, address, customerType, status, createdAt " +
                     "FROM Customers WHERE phone LIKE ? AND status = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + phone + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer c = new Customer();
                    c.setCustomer_id(rs.getInt("customerId"));
                    c.setFull_name(rs.getString("fullName"));
                    c.setPhone(rs.getString("phone"));
                    c.setAddress(rs.getString("address"));
                    c.setCustomer_type(rs.getString("customerType"));
                    c.setStatus(rs.getString("status"));
                    c.setCreated_at(rs.getTimestamp("createdAt"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Customer getCustomerById(int customerId) {
        String sql = "SELECT customerId, fullName, phone, address, customerType, status, createdAt " +
                     "FROM Customers WHERE customerId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer c = new Customer();
                    c.setCustomer_id(rs.getInt("customerId"));
                    c.setFull_name(rs.getString("fullName"));
                    c.setPhone(rs.getString("phone"));
                    c.setAddress(rs.getString("address"));
                    c.setCustomer_type(rs.getString("customerType"));
                    c.setStatus(rs.getString("status"));
                    c.setCreated_at(rs.getTimestamp("createdAt"));
                    return c;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}