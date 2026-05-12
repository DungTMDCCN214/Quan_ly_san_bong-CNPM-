package dao;

import model.BookingDetailView;
import model.BookingSearchResult;
import model.Customer;

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

    // ================================================================
    //  TÌM KIẾM ĐƠN ĐẶT SÂN
    //  Tìm theo SĐT và/hoặc ngày đặt (bookingDate)
    //  Trả về danh sách BookingSearchResult để render trang search
    // ================================================================

    public List<BookingSearchResult> searchBookings(String phone, String bookingDate) {
        List<BookingSearchResult> results = new ArrayList<>();

        // Câu lệnh lấy header đơn + thông tin KH + invoice
        StringBuilder sql = new StringBuilder(
            "SELECT b.bookingId, b.status AS bookingStatus, " +
            "       CONVERT(VARCHAR(10), b.bookingDate, 120) AS bookingDate, " +
            "       c.fullName, c.phone, " +
            "       ISNULL(i.netAmount, 0) AS netAmount, ISNULL(i.status, 'UNPAID') AS invoiceStatus " +
            "FROM Bookings b " +
            "INNER JOIN Customers c ON b.customerId = c.customerId " +
            "LEFT  JOIN Invoices  i ON i.bookingId  = b.bookingId " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (phone != null && !phone.isBlank()) {
            sql.append("AND c.phone LIKE ? ");
            params.add("%" + phone.trim() + "%");
        }
        if (bookingDate != null && !bookingDate.isBlank()) {
            sql.append("AND b.bookingDate = ? ");
            params.add(bookingDate.trim());
        }
        sql.append("ORDER BY b.bookingId DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingSearchResult r = new BookingSearchResult();
                    r.setBookingId(rs.getInt("bookingId"));
                    r.setBookingStatus(rs.getString("bookingStatus"));
                    r.setBookingDate(rs.getString("bookingDate"));
                    r.setCustomerName(rs.getString("fullName"));
                    r.setCustomerPhone(rs.getString("phone"));
                    r.setNetAmount(rs.getInt("netAmount"));
                    r.setInvoiceStatus(rs.getString("invoiceStatus"));
                    results.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Gắn danh sách slot vào từng booking
        for (BookingSearchResult r : results) {
            r.setSlots(getSlotsForBooking(r.getBookingId()));
        }
        return results;
    }

    /**
     * Lấy danh sách slot (courtName + giờ) cho một booking – dùng để hiển thị tags trong card
     */
    private List<BookingSearchResult.BookingDetailSlot> getSlotsForBooking(int bookingId) {
        List<BookingSearchResult.BookingDetailSlot> list = new ArrayList<>();
        String sql = "SELECT c.name AS courtName, " +
                     "       CONVERT(VARCHAR(5), ts.startTime, 108) AS slotStart, " +
                     "       CONVERT(VARCHAR(5), ts.endTime,   108) AS slotEnd " +
                     "FROM BookingDetails bd " +
                     "INNER JOIN Courts    c  ON bd.courtId    = c.courtId " +
                     "INNER JOIN TimeSlots ts ON bd.timeSlotId = ts.timeSlotId " +
                     "WHERE bd.bookingId = ? AND bd.status != 'CANCELLED' " +
                     "ORDER BY bd.usageDate, ts.startTime";
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

    // ================================================================
    //  CHI TIẾT ĐƠN ĐẶT SÂN
    //  Lấy đầy đủ header + danh sách chi tiết để render trang detail
    // ================================================================

    /**
     * Lấy thông tin header của một booking (customer, ngày đặt, tổng tiền)
     */
    public Map<String, Object> getBookingHeader(int bookingId) {
        Map<String, Object> map = new HashMap<>();
        String sql = "SELECT b.bookingId, b.status AS bookingStatus, " +
                     "       CONVERT(VARCHAR(10), b.bookingDate, 120) AS bookingDate, " +
                     "       c.fullName, c.phone, " +
                     "       ISNULL(i.invoiceId, 0) AS invoiceId, " +
                     "       ISNULL(i.netAmount, 0) AS netAmount, " +
                     "       ISNULL(i.status, 'UNPAID') AS invoiceStatus " +
                     "FROM Bookings b " +
                     "INNER JOIN Customers c ON b.customerId = c.customerId " +
                     "LEFT  JOIN Invoices  i ON i.bookingId  = b.bookingId " +
                     "WHERE b.bookingId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    map.put("bookingId",      rs.getInt("bookingId"));
                    map.put("bookingStatus",  rs.getString("bookingStatus"));
                    map.put("bookingDate",    rs.getString("bookingDate"));
                    map.put("customerName",   rs.getString("fullName"));
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

    /**
     * Lấy danh sách chi tiết của một booking (join Courts + TimeSlots)
     * Gom nhóm theo sân để render theo UI (mỗi sân 1 khối)
     */
    public List<BookingDetailView> getBookingDetails(int bookingId) {
        List<BookingDetailView> list = new ArrayList<>();
        String sql = "SELECT bd.bookingDetailId, " +
                     "       CONVERT(VARCHAR(10), bd.usageDate, 120) AS usageDate, " +
                     "       bd.status AS detailStatus, " +
                     "       c.name AS courtName, c.type AS courtType, c.pricePerHour, " +
                     "       CONVERT(VARCHAR(5), ts.startTime, 108) AS slotStart, " +
                     "       CONVERT(VARCHAR(5), ts.endTime,   108) AS slotEnd " +
                     "FROM BookingDetails bd " +
                     "INNER JOIN Courts    c  ON bd.courtId    = c.courtId " +
                     "INNER JOIN TimeSlots ts ON bd.timeSlotId = ts.timeSlotId " +
                     "WHERE bd.bookingId = ? " +
                     "ORDER BY bd.usageDate, ts.startTime";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingDetailView v = new BookingDetailView();
                    v.setBookingDetailId(rs.getInt("bookingDetailId"));
                    v.setUsageDate(rs.getString("usageDate"));
                    v.setDetailStatus(rs.getString("detailStatus"));
                    v.setCourtName(rs.getString("courtName"));
                    v.setCourtType(rs.getString("courtType"));
                    v.setPricePerHour(rs.getInt("pricePerHour"));
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

    // ================================================================
    //  CẬP NHẬT TRẠNG THÁI TỪNG BookingDetail (check-in/out/hủy)
    //  Nhận Map<bookingDetailId, newStatus> từ Servlet
    // ================================================================

    /**
     * Cập nhật status của nhiều BookingDetail cùng lúc (batch update).
     * Sau đó tính lại netAmount trong Invoices dựa trên các slot chưa hủy.
     *
     * @param updates        Map: bookingDetailId -> newStatus ("PLAYING" | "DONE" | "CANCELLED")
     * @param bookingId      Booking cha – dùng để tính lại tổng tiền invoice
     * @return true nếu thành công
     */
    public boolean updateDetailStatuses(Map<Integer, String> updates, int bookingId) {
        String sqlUpdate = "UPDATE BookingDetails SET status = ? WHERE bookingDetailId = ?";
        String sqlRecalc = "UPDATE Invoices SET netAmount = " +
                           "(SELECT ISNULL(SUM(c.pricePerHour), 0) " +
                           " FROM BookingDetails bd " +
                           " INNER JOIN Courts c ON bd.courtId = c.courtId " +
                           " WHERE bd.bookingId = ? AND bd.status != 'CANCELLED') " +
                           "WHERE bookingId = ?";

        try {
            conn.setAutoCommit(false);

            // Batch update từng detail
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                for (Map.Entry<Integer, String> e : updates.entrySet()) {
                    ps.setString(1, e.getValue());
                    ps.setInt(2, e.getKey());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Tính lại netAmount trong Invoices
            try (PreparedStatement ps = conn.prepareStatement(sqlRecalc)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, bookingId);
                ps.executeUpdate();
            }

            // Cập nhật status tổng của Booking nếu toàn bộ bị hủy
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

    /**
     * Nếu toàn bộ detail của booking đều CANCELLED → cập nhật Bookings.status = 'CANCELLED'
     */
    private void updateBookingStatusIfNeeded(int bookingId) {
        String sqlCheck  = "SELECT COUNT(*) FROM BookingDetails WHERE bookingId = ? AND status != 'CANCELLED'";
        String sqlCancel = "UPDATE Bookings SET status = 'CANCELLED' WHERE bookingId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) {
                    try (PreparedStatement ps2 = conn.prepareStatement(sqlCancel)) {
                        ps2.setInt(1, bookingId);
                        ps2.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
