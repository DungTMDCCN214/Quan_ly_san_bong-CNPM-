package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.BookingDetail;
import model.Invoice;
import model.InvoiceDetail;
import model.Service;

public class InvoiceDAO {
    private Connection conn;

    public InvoiceDAO() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
            conn = DriverManager.getConnection(url, "sa", "123456");
        } catch (Exception e) { e.printStackTrace(); }
    }

    public List<Invoice> searchInvoices(String keyword, String status) {
        List<Invoice> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT i.invoice_id, i.booking_detail_id, i.total_amount, i.net_amount, i.status, " +
            "       CONVERT(VARCHAR(16), i.created_at, 120) AS created_date_str, " +
            "       c.full_name, c.phone " +
            "FROM invoices i " +
            "INNER JOIN booking_details bd ON i.booking_detail_id = bd.booking_detail_id " +
            "INNER JOIN bookings b ON bd.booking_id = b.booking_id " +
            "INNER JOIN customers c ON b.customer_id = c.customer_id " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.phone LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equals(status)) {
            sql.append(" AND i.status = ? ");
            params.add(status.trim());
        }
        sql.append(" ORDER BY i.invoice_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Invoice inv = new Invoice();
                    inv.setInvoice_id(rs.getInt("invoice_id"));
                    inv.setBooking_detail_id(rs.getInt("booking_detail_id"));
                    inv.setTotal_amount(rs.getDouble("total_amount"));
                    inv.setNet_amount(rs.getDouble("net_amount"));
                    inv.setStatus(rs.getString("status"));
                    inv.setCustomer_name(rs.getString("full_name"));
                    inv.setCustomer_phone(rs.getString("phone"));
                    inv.setCreated_date_str(rs.getString("created_date_str"));
                    list.add(inv);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ĐÃ SỬA: Lấy danh sách TỪNG KHUNG GIỜ chưa có hóa đơn (Dùng Map để hứng dữ liệu đa dạng)
    // CẬP NHẬT: Thêm tham số keyword để tìm kiếm
    public List<Map<String, Object>> getUninvoicedBookingDetails(String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT bd.booking_detail_id, bd.usage_date, bd.status as detail_status, " +
            "c.full_name, c.phone, co.name as court_name, " +
            "CONVERT(VARCHAR(5), ts.start_time, 108) as start_time, " +
            "CONVERT(VARCHAR(5), ts.end_time, 108) as end_time " +
            "FROM booking_details bd " +
            "JOIN bookings b ON bd.booking_id = b.booking_id " +
            "JOIN customers c ON b.customer_id = c.customer_id " +
            "JOIN courts co ON bd.court_id = co.court_id " +
            "JOIN time_slots ts ON bd.time_slot_id = ts.time_slot_id " +
            "WHERE NOT EXISTS (SELECT 1 FROM invoices i WHERE i.booking_detail_id = bd.booking_detail_id AND i.status != 'CANCELLED') " +
            "AND bd.status IN ('IN PROGRESS', 'FINISHED') "
        );

        // Bổ sung logic tìm kiếm nếu có từ khóa
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.phone LIKE ?) ");
        }
        sql.append(" ORDER BY bd.usage_date DESC, ts.start_time ASC");
                     
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            // Truyền giá trị từ khóa vào câu SQL
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(1, kw);
                ps.setString(2, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("bookingDetailId", rs.getInt("booking_detail_id"));
                    item.put("usageDate", rs.getString("usage_date"));
                    item.put("detailStatus", rs.getString("detail_status"));
                    item.put("customerName", rs.getString("full_name"));
                    item.put("customerPhone", rs.getString("phone"));
                    item.put("courtName", rs.getString("court_name"));
                    item.put("slotTime", rs.getString("start_time") + " - " + rs.getString("end_time"));
                    list.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ĐÃ SỬA: Tham số là bookingDetailId
    public int createInvoice(int bookingDetailId) {
        String sqlInsert = "INSERT INTO invoices (booking_detail_id, total_amount, discount_amount, net_amount, status) VALUES (?, 0, 0, 0, 'UNPAID')";
        try {
            conn.setAutoCommit(false);
            int newInvoiceId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, bookingDetailId);
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) newInvoiceId = rs.getInt(1);
            }
            if (newInvoiceId > 0) {
                updateInvoiceTotal(newInvoiceId);
            } else {
                conn.rollback();
                return -1;
            }
            conn.commit();
            return newInvoiceId;
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return -1;
        } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    public Invoice getInvoiceById(int invoiceId) {
        String sql = "SELECT i.*, c.full_name, c.phone, b.deposit_amount, " + 
                     "CONVERT(VARCHAR(16), i.created_at, 120) AS created_date_str " +
                     "FROM invoices i " +
                     "JOIN booking_details bd ON i.booking_detail_id = bd.booking_detail_id " +
                     "JOIN bookings b ON bd.booking_id = b.booking_id " +
                     "JOIN customers c ON b.customer_id = c.customer_id WHERE i.invoice_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Invoice inv = new Invoice();
                inv.setInvoice_id(rs.getInt("invoice_id"));
                inv.setBooking_detail_id(rs.getInt("booking_detail_id"));
                inv.setTotal_amount(rs.getDouble("total_amount"));
                inv.setDiscount_amount(rs.getDouble("discount_amount"));
                inv.setNet_amount(rs.getDouble("net_amount"));
                inv.setStatus(rs.getString("status"));
                inv.setPayment_method(rs.getString("payment_method"));
                inv.setCustomer_name(rs.getString("full_name"));
                inv.setCustomer_phone(rs.getString("phone"));
                inv.setCreated_date_str(rs.getString("created_date_str"));
                inv.setDeposit_amount(rs.getDouble("deposit_amount")); 
                return inv;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<InvoiceDetail> getInvoiceDetails(int invoiceId) {
        List<InvoiceDetail> list = new ArrayList<>();
        String sql = "SELECT id.*, s.name as service_name, s.image_path FROM invoice_details id " +
                     "JOIN services s ON id.service_id = s.service_id WHERE id.invoice_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InvoiceDetail d = new InvoiceDetail();
                d.setId(rs.getInt("id"));
                d.setService_id(rs.getInt("service_id"));
                d.setQuantity(rs.getInt("quantity"));
                d.setUnit_price(rs.getDouble("unit_price"));
                d.setService_name(rs.getString("service_name"));
                d.setService_image(rs.getString("image_path"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ĐÃ SỬA: Lấy thông tin sân của 1 buổi cụ thể
    public List<BookingDetail> getCourtDetailsForInvoice(int bookingDetailId) {
        List<BookingDetail> list = new ArrayList<>();
        String sql = "SELECT bd.*, c.name as court_name, " +
                     "CONVERT(VARCHAR(5), ts.start_time, 108) as start_time, " +
                     "CONVERT(VARCHAR(5), ts.end_time, 108) as end_time " +
                     "FROM booking_details bd " +
                     "JOIN courts c ON bd.court_id = c.court_id JOIN time_slots ts ON bd.time_slot_id = ts.time_slot_id " +
                     "WHERE bd.booking_detail_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingDetailId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BookingDetail d = new BookingDetail();
                d.setCourtName(rs.getString("court_name"));
                d.setSlotStart(rs.getString("start_time"));
                d.setSlotEnd(rs.getString("end_time"));
                d.setPricePerHour(rs.getDouble("price_per_hour"));
                d.setUsageDate(rs.getDate("usage_date"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ... (Các hàm addServiceToInvoice, updateServiceQuantity, removeServiceFromInvoice GIỮ NGUYÊN) ...
    public boolean addServiceToInvoice(int invoiceId, int serviceId, int quantity) {
        try {
            conn.setAutoCommit(false);
            String sqlStock = "SELECT stock_quantity, price FROM services WHERE service_id = ?";
            double unitPrice = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                ps.setInt(1, serviceId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    if (rs.getInt("stock_quantity") < quantity) { conn.rollback(); return false; }
                    unitPrice = rs.getDouble("price");
                }
            }

            String sqlCheckExist = "SELECT id FROM invoice_details WHERE invoice_id = ? AND service_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheckExist)) {
                ps.setInt(1, invoiceId);
                ps.setInt(2, serviceId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String sqlUpdateDetail = "UPDATE invoice_details SET quantity = quantity + ? WHERE id = ?";
                    try (PreparedStatement psUp = conn.prepareStatement(sqlUpdateDetail)) {
                        psUp.setInt(1, quantity);
                        psUp.setInt(2, rs.getInt("id"));
                        psUp.executeUpdate();
                    }
                } else {
                    String sqlInsertDetail = "INSERT INTO invoice_details (invoice_id, service_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement psIn = conn.prepareStatement(sqlInsertDetail)) {
                        psIn.setInt(1, invoiceId);
                        psIn.setInt(2, serviceId);
                        psIn.setInt(3, quantity);
                        psIn.setDouble(4, unitPrice);
                        psIn.executeUpdate();
                    }
                }
            }

            String sqlUpdateStock = "UPDATE services SET stock_quantity = stock_quantity - ? WHERE service_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStock)) {
                ps.setInt(1, quantity);
                ps.setInt(2, serviceId);
                ps.executeUpdate();
            }

            updateInvoiceTotal(invoiceId);
            conn.commit();
            return true;
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    public boolean updateServiceQuantity(int detailId, int newQuantity) {
        try {
            conn.setAutoCommit(false);
            int serviceId = 0, oldQuantity = 0, invoiceId = 0;
            double unitPrice = 0;
            String sqlGet = "SELECT service_id, quantity, invoice_id, unit_price FROM invoice_details WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setInt(1, detailId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    serviceId = rs.getInt("service_id");
                    oldQuantity = rs.getInt("quantity");
                    invoiceId = rs.getInt("invoice_id");
                    unitPrice = rs.getDouble("unit_price");
                }
            }
            if (newQuantity == 0) {
                conn.setAutoCommit(true); 
                return removeServiceFromInvoice(detailId);
            }
            int diff = newQuantity - oldQuantity;
            if (diff > 0) { 
                String sqlCheck = "SELECT stock_quantity FROM services WHERE service_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                    ps.setInt(1, serviceId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next() && rs.getInt("stock_quantity") < diff) {
                        conn.rollback(); return false; 
                    }
                }
            }
            String sqlUpdateDetail = "UPDATE invoice_details SET quantity = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateDetail)) {
                ps.setInt(1, newQuantity);
                ps.setInt(2, detailId);
                ps.executeUpdate();
            }
            String sqlUpdateStock = "UPDATE services SET stock_quantity = stock_quantity - ? WHERE service_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStock)) {
                ps.setInt(1, diff);
                ps.setInt(2, serviceId);
                ps.executeUpdate();
            }
            updateInvoiceTotal(invoiceId);
            conn.commit();
            return true;
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    public boolean removeServiceFromInvoice(int detailId) {
        try {
            conn.setAutoCommit(false);
            int serviceId = 0, quantity = 0, invoiceId = 0;
            String sqlGetDetail = "SELECT service_id, quantity, invoice_id FROM invoice_details WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlGetDetail)) {
                ps.setInt(1, detailId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    serviceId = rs.getInt("service_id");
                    quantity = rs.getInt("quantity");
                    invoiceId = rs.getInt("invoice_id");
                }
            }
            String sqlReturnStock = "UPDATE services SET stock_quantity = stock_quantity + ? WHERE service_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlReturnStock)) {
                ps.setInt(1, quantity);
                ps.setInt(2, serviceId);
                ps.executeUpdate();
            }
            String sqlDelete = "DELETE FROM invoice_details WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDelete)) {
                ps.setInt(1, detailId);
                ps.executeUpdate();
            }
            updateInvoiceTotal(invoiceId);
            conn.commit();
            return true;
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    public boolean updateInvoiceStatus(int invoiceId, String newStatus, String paymentMethod) {
        // Câu lệnh SQL cập nhật cả trạng thái và phương thức thanh toán
        String sqlUpdateInv = "UPDATE invoices SET status = ?, payment_method = ? WHERE invoice_id = ?";
        try {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateInv)) {
                ps.setString(1, newStatus);
                ps.setString(2, paymentMethod); // Lưu 'CASH' hoặc 'TRANSFER'
                ps.setInt(3, invoiceId);
                ps.executeUpdate();
            }

            if ("PAID".equals(newStatus)) {
                String sqlBooking = "UPDATE booking_details SET status = 'COMPLETED' WHERE booking_detail_id = (SELECT booking_detail_id FROM invoices WHERE invoice_id = ?)";
                try (PreparedStatement psB = conn.prepareStatement(sqlBooking)) {
                    psB.setInt(1, invoiceId);
                    psB.executeUpdate();
                }
            } else if ("CANCELLED".equals(newStatus)) {
                String sqlGetDetails = "SELECT service_id, quantity FROM invoice_details WHERE invoice_id = ?";
                String sqlReturnStock = "UPDATE services SET stock_quantity = stock_quantity + ? WHERE service_id = ?";
                try (PreparedStatement psGet = conn.prepareStatement(sqlGetDetails)) {
                    psGet.setInt(1, invoiceId);
                    try (ResultSet rs = psGet.executeQuery();
                         PreparedStatement psReturn = conn.prepareStatement(sqlReturnStock)) {
                        while (rs.next()) {
                            psReturn.setInt(1, rs.getInt("quantity"));
                            psReturn.setInt(2, rs.getInt("service_id"));
                            psReturn.addBatch();
                        }
                        psReturn.executeBatch();
                    }
                }
            }
            conn.commit();
            return true;
        } catch (Exception e) {
            try { conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (Exception e) {}
        }
    }
    // ĐÃ SỬA LẠI: Chỉ cộng tiền của đúng booking_detail_id đó
    private void updateInvoiceTotal(int invoiceId) throws SQLException {
        String sqlSum = "SELECT " +
            "(SELECT ISNULL(price_per_hour,0) FROM booking_details WHERE booking_detail_id = (SELECT booking_detail_id FROM invoices WHERE invoice_id = ?)) + " +
            "(SELECT ISNULL(SUM(quantity * unit_price),0) FROM invoice_details WHERE invoice_id = ?) as grand_total";
        
        double total = 0;
        try (PreparedStatement ps = conn.prepareStatement(sqlSum)) {
            ps.setInt(1, invoiceId);
            ps.setInt(2, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("grand_total");
        }

        String sqlCust = "SELECT c.customer_type, b.deposit_amount FROM customers c " +
                         "JOIN bookings b ON c.customer_id = b.customer_id " +
                         "JOIN booking_details bd ON b.booking_id = bd.booking_id " +
                         "JOIN invoices i ON bd.booking_detail_id = i.booking_detail_id WHERE i.invoice_id = ?";
        double discount = 0;
        double deposit = 0;
        try (PreparedStatement ps = conn.prepareStatement(sqlCust)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if ("VIP".equals(rs.getString("customer_type"))) discount = total * 0.1;
                deposit = rs.getDouble("deposit_amount");
            }
        }

        double netAmount = total - discount - deposit;
        if (netAmount < 0) netAmount = 0; 

        String sqlUpdate = "UPDATE invoices SET total_amount = ?, discount_amount = ?, net_amount = ? WHERE invoice_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setDouble(1, total);
            ps.setDouble(2, discount);
            ps.setDouble(3, netAmount);
            ps.setInt(4, invoiceId);
            ps.executeUpdate();
        }
    }
    
    public List<Service> getActiveServices() {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT * FROM services WHERE status = 'ACTIVE' AND stock_quantity > 0";
        try (PreparedStatement ps = conn.prepareCall(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Service(rs.getInt("service_id"), rs.getString("name"), rs.getDouble("price"), rs.getInt("stock_quantity"), "ACTIVE", "", rs.getString("image_path")));
            }
        } catch (Exception e) {}
        return list;
    }
}