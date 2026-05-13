package dao;

import model.BookingDetailView;
import model.BookingSearchResult;

import java.sql.*;
import java.util.*;

public class SearchBookingDAO {

    private Connection conn;

    public SearchBookingDAO() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
            conn = DriverManager.getConnection(url, "sa", "123456");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<BookingSearchResult> searchBookings(String phone, String bookingDate) {
        List<BookingSearchResult> results = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT b.booking_id, " +
            "       b.status AS bookingStatus, " +
            "       CONVERT(VARCHAR(10), b.booking_date, 120) AS bookingDate, " +
            "       c.full_name, " +
            "       c.phone, " +

            // Tiền còn phải thu
            "       ( " +
            "           ISNULL( " +
            "               ( " +
            "                   SELECT SUM( " +
            "                       CASE " +
            "                           WHEN i.invoice_id IS NOT NULL " +
            "                                AND i.status <> 'CANCELLED' " +
            "                           THEN i.net_amount " +

            "                           ELSE bd.price_per_hour " +
            "                       END " +
            "                   ) " +
            "                   FROM booking_details bd " +
            "                   LEFT JOIN invoices i " +
            "                       ON bd.booking_detail_id = i.booking_detail_id " +
            "                   WHERE bd.booking_id = b.booking_id " +
            "                     AND bd.status <> 'CANCELLED' " +
            "               ), " +
            "               0 " +
            "           ) " +
            "       ) AS netAmount, " +

            // Trạng thái hóa đơn
            "       ISNULL( " +
            "           ( " +
            "               SELECT CASE " +
            "                   WHEN COUNT(CASE WHEN i.status <> 'CANCELLED' THEN 1 END) = 0 " +
            "                        THEN 'NO INVOICE' " +

            "                   WHEN SUM(CASE WHEN i.status = 'UNPAID' THEN 1 ELSE 0 END) > 0 " +
            "                        THEN 'UNPAID' " +

            "                   ELSE 'PAID' " +
            "               END " +

            "               FROM invoices i " +
            "               JOIN booking_details bd " +
            "                   ON i.booking_detail_id = bd.booking_detail_id " +
            "               WHERE bd.booking_id = b.booking_id " +
            "           ), " +
            "           'NO INVOICE' " +
            "       ) AS invoiceStatus " +

            "FROM bookings b " +
            "INNER JOIN customers c " +
            "    ON b.customer_id = c.customer_id " +
            "WHERE 1 = 1 "
        );

        List<Object> params = new ArrayList<>();

        if (phone != null && !phone.isBlank()) {
            sql.append("AND c.phone LIKE ? ");
            params.add("%" + phone.trim() + "%");
        }
        if (bookingDate != null && !bookingDate.isBlank()) {
            sql.append("AND b.booking_date = ? ");
            params.add(bookingDate.trim());
        }
        sql.append("ORDER BY b.booking_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingSearchResult r = new BookingSearchResult();
                    r.setBookingId(rs.getInt("booking_id"));
                    r.setBookingStatus(rs.getString("bookingStatus"));
                    r.setBookingDate(rs.getString("bookingDate"));
                    r.setCustomerName(rs.getString("full_name"));
                    r.setCustomerPhone(rs.getString("phone"));
                    r.setNetAmount(rs.getInt("netAmount"));
                    r.setInvoiceStatus(rs.getString("invoiceStatus"));
                    results.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (BookingSearchResult r : results) {
            r.setSlots(getSlotsForBooking(r.getBookingId()));
        }
        return results;
    }

    private List<BookingSearchResult.BookingDetailSlot> getSlotsForBooking(int bookingId) {
        List<BookingSearchResult.BookingDetailSlot> list = new ArrayList<>();
        String sql = "SELECT c.name AS courtName, " +
                     "       CONVERT(VARCHAR(5), ts.start_time, 108) AS slotStart, " +
                     "       CONVERT(VARCHAR(5), ts.end_time,   108) AS slotEnd " +
                     "FROM booking_details bd " +
                     "INNER JOIN courts c  ON bd.court_id = c.court_id " +
                     "INNER JOIN time_slots ts ON bd.time_slot_id = ts.time_slot_id " +
                     "WHERE bd.booking_id = ? AND bd.status != 'CANCELLED' " +
                     "ORDER BY bd.usage_date, ts.start_time";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new BookingSearchResult.BookingDetailSlot(
                        rs.getString("courtName"),
                        rs.getString("slotStart"),
                        rs.getString("slotEnd")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getBookingHeader(int bookingId) {
        Map<String, Object> map = new HashMap<>();
        // ĐÃ SỬA: Bỏ JOIN trực tiếp, dùng Subquery để lấy tổng tiền, gán invoiceId = 0 để tránh lỗi UI
        String sql = "SELECT b.booking_id, b.status AS bookingStatus, " +
                     "       CONVERT(VARCHAR(10), b.booking_date, 120) AS bookingDate, " +
                     "       c.full_name, c.phone, " +
                     "       0 AS invoiceId, " +
                     "       ISNULL((SELECT SUM(i.net_amount) FROM invoices i JOIN booking_details bd ON i.booking_detail_id = bd.booking_detail_id WHERE bd.booking_id = b.booking_id), 0) AS netAmount, " +
                     "       ISNULL((SELECT CASE WHEN COUNT(i.invoice_id) = 0 THEN 'NO INVOICE' WHEN SUM(CASE WHEN i.status = 'UNPAID' THEN 1 ELSE 0 END) > 0 THEN 'UNPAID' ELSE 'PAID' END FROM invoices i JOIN booking_details bd ON i.booking_detail_id = bd.booking_detail_id WHERE bd.booking_id = b.booking_id), 'NO INVOICE') AS invoiceStatus " +
                     "FROM bookings b " +
                     "INNER JOIN customers c ON b.customer_id = c.customer_id " +
                     "WHERE b.booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    map.put("bookingId",      rs.getInt("booking_id"));
                    map.put("bookingStatus",  rs.getString("bookingStatus"));
                    map.put("bookingDate",    rs.getString("bookingDate"));
                    map.put("customerName",   rs.getString("full_name"));
                    map.put("customerPhone",  rs.getString("phone"));
                    map.put("invoiceId",      rs.getInt("invoiceId"));
                    map.put("netAmount",      rs.getInt("netAmount"));
                    map.put("invoiceStatus",  rs.getString("invoiceStatus"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public List<BookingDetailView> getBookingDetails(int bookingId) {
        List<BookingDetailView> list = new ArrayList<>();
        String sql = "SELECT bd.booking_detail_id, " +
                     "       CONVERT(VARCHAR(10), bd.usage_date, 120) AS usageDate, " +
                     "       bd.status AS detailStatus, " +
                     "       c.name AS courtName, c.type AS courtType, bd.price_per_hour, " +
                     "       CONVERT(VARCHAR(5), ts.start_time, 108) AS slotStart, " +
                     "       CONVERT(VARCHAR(5), ts.end_time,   108) AS slotEnd " +
                     "FROM booking_details bd " +
                     "INNER JOIN courts c  ON bd.court_id = c.court_id " +
                     "INNER JOIN time_slots ts ON bd.time_slot_id = ts.time_slot_id " +
                     "WHERE bd.booking_id = ? " +
                     "ORDER BY bd.usage_date, ts.start_time";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingDetailView v = new BookingDetailView();
                    v.setBookingDetailId(rs.getInt("booking_detail_id"));
                    v.setUsageDate(rs.getString("usageDate"));
                    v.setDetailStatus(rs.getString("detailStatus"));
                    v.setCourtName(rs.getString("courtName"));
                    v.setCourtType(rs.getString("courtType"));
                    v.setPricePerHour(rs.getInt("price_per_hour"));
                    v.setSlotStart(rs.getString("slotStart"));
                    v.setSlotEnd(rs.getString("slotEnd"));
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateDetailStatuses(Map<Integer, String> updates, int bookingId) {
        String sqlUpdate = "UPDATE booking_details SET status = ? WHERE booking_detail_id = ?";
        // ĐÃ XÓA sqlRecalc ở đây vì SearchBooking không còn can thiệp vào Invoices nữa

        try {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                for (Map.Entry<Integer, String> e : updates.entrySet()) {
                    ps.setString(1, e.getValue());
                    ps.setInt(2, e.getKey());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // GỌI HÀM CẬP NHẬT THÔNG MINH (Trạng thái cha)
            updateBookingStatusIfNeeded(bookingId);

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (Exception e) { e.printStackTrace(); }
        }
    }

    // Logic tính toán trạng thái thông minh
    private void updateBookingStatusIfNeeded(int bookingId) {
        String sqlCheck  = "SELECT status FROM booking_details WHERE booking_id = ?";
        String sqlUpdate = "UPDATE bookings SET status = ? WHERE booking_id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean hasInProgress = false;
                boolean hasBooked = false;
                boolean hasFinished = false;
                boolean allCancelled = true;

                while (rs.next()) {
                    String st = rs.getString("status");
                    if (!"CANCELLED".equals(st)) allCancelled = false;
                    if ("IN PROGRESS".equals(st)) hasInProgress = true;
                    if ("BOOKED".equals(st)) hasBooked = true;
                    if ("FINISHED".equals(st)) hasFinished = true;
                }

                String finalStatus = "BOOKED";
                if (allCancelled) {
                    finalStatus = "CANCELLED";
                } else if (hasInProgress) {
                    finalStatus = "IN PROGRESS"; 
                } else if (hasFinished && !hasBooked) {
                    finalStatus = "FINISHED"; 
                }

                try (PreparedStatement ps2 = conn.prepareStatement(sqlUpdate)) {
                    ps2.setString(1, finalStatus);
                    ps2.setInt(2, bookingId);
                    ps2.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}