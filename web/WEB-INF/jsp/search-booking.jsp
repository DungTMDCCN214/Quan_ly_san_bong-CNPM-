<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.BookingSearchResult"%>
<%
    request.setAttribute("currentPage", "booking-search");
    List<BookingSearchResult> results = (List<BookingSearchResult>) request.getAttribute("results");
    String phone       = (String) request.getAttribute("phone");
    String bookingDate = (String) request.getAttribute("bookingDate");
    if (phone == null)       phone = "";
    if (bookingDate == null) bookingDate = "";

    // Helper: format ngày yyyy-MM-dd -> Thứ X, dd/MM/yyyy
    java.time.format.DateTimeFormatter fmtIn  = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
    java.time.format.DateTimeFormatter fmtOut = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String[] thuViet = {"","Chủ Nhật","Thứ 2","Thứ 3","Thứ 4","Thứ 5","Thứ 6","Thứ 7"};
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tra cứu đơn đặt sân</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content { margin-left: 260px; flex: 1; padding: 40px 48px; }

        h1 { font-size: 1.9rem; font-weight: 800; color: #1a2332; margin-bottom: 6px; }
        .sub-title { color: #888; font-size: 0.92rem; margin-bottom: 32px; }

        /* Search box */
        .search-card {
            background: #fff; border-radius: 14px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07);
            padding: 24px 28px; margin-bottom: 32px;
        }
        .search-row { display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap; }
        .field-wrap { flex: 1; min-width: 200px; }
        .field-wrap label {
            display: flex; align-items: center; gap: 6px;
            font-size: 0.82rem; font-weight: 600; color: #666; margin-bottom: 8px;
        }
        .field-wrap input {
            width: 100%; padding: 11px 14px; border: 1.5px solid #e0e0e0;
            border-radius: 10px; font-size: 0.92rem; outline: none;
            transition: all 0.3s ease; background: #fafafa; color: #333;
        }
        .field-wrap input:focus { border-color: #1976d2; background: #fff; box-shadow: 0 0 0 3px rgba(25,118,210,0.1); }
        .field-wrap input::placeholder { color: #bbb; }

        .btn-search {
            padding: 11px 28px; background: #1976d2; color: #fff;
            border: none; border-radius: 10px; font-size: 0.92rem;
            font-weight: 700; cursor: pointer; transition: all 0.3s ease;
            display: flex; align-items: center; gap: 8px; white-space: nowrap;
        }
        .btn-search:hover { background: #1565c0; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(25,118,210,0.3); }
        .btn-clear {
            width: 40px; height: 40px; border-radius: 50%; border: 1.5px solid #ddd;
            background: #f5f5f5; color: #999; font-size: 1rem; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.3s ease; flex-shrink: 0;
        }
        .btn-clear:hover { background: #ffebee; border-color: #ef9a9a; color: #e53935; }

        /* Result count */
        .result-count { font-size: 0.9rem; color: #666; margin-bottom: 16px; }
        .result-count strong { color: #1a2332; font-weight: 700; }

        /* Booking card */
        .booking-card {
            background: #fff; border-radius: 14px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            display: flex; margin-bottom: 14px; overflow: hidden;
            cursor: pointer; transition: all 0.3s ease; border: 2px solid transparent;
            text-decoration: none;
        }
        .booking-card:hover { border-color: #1976d2; box-shadow: 0 4px 20px rgba(25,118,210,0.12); transform: translateY(-1px); }

        /* Left panel – mã đơn + badge */
        .card-left {
            width: 160px; flex-shrink: 0; background: #f8fafc;
            border-right: 1px solid #f0f0f0; padding: 22px 20px;
            display: flex; flex-direction: column; gap: 10px;
        }
        .card-left .lbl { font-size: 0.7rem; font-weight: 700; color: #aaa; text-transform: uppercase; letter-spacing: 0.5px; }
        .card-left .code { font-size: 1rem; font-weight: 800; color: #1a2332; }

        /* Status badge */
        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 12px; border-radius: 20px; font-size: 0.78rem; font-weight: 700;
            width: fit-content;
        }
        .badge-booked    { background: #e3f2fd; color: #1565c0; }
        .badge-playing   { background: #fff8e1; color: #f57c00; }
        .badge-done      { background: #e8f5e9; color: #2e7d32; }
        .badge-cancelled { background: #fce4ec; color: #c62828; }
        .badge-checkin   { background: #e8f5e9; color: #2e7d32; }

        /* Right panel – body */
        .card-body { flex: 1; padding: 20px 24px; }
        .card-top  { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px; }
        .cust-name { font-size: 1.05rem; font-weight: 700; color: #1a2332; margin-bottom: 5px; display: flex; align-items: center; gap: 6px; }
        .cust-meta { display: flex; align-items: center; gap: 16px; font-size: 0.83rem; color: #888; }
        .cust-meta span { display: flex; align-items: center; gap: 5px; }

        .total-wrap .lbl2 { font-size: 0.7rem; color: #aaa; font-weight: 600; text-transform: uppercase; text-align: right; margin-bottom: 3px; }
        .total-wrap .amount { font-size: 1.1rem; font-weight: 800; color: #1976d2; white-space: nowrap; }

        /* Slot tags */
        .slot-count { font-size: 0.82rem; color: #777; margin-bottom: 10px; }
        .slot-tags  { display: flex; flex-wrap: wrap; gap: 8px; }
        .slot-tag {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 12px; border-radius: 20px;
            background: #f0f4ff; color: #3949ab;
            font-size: 0.78rem; font-weight: 600; border: 1px solid #c5cae9;
        }

        /* Empty state */
        .empty-state { text-align: center; padding: 64px 0; color: #ccc; }
        .empty-state .icon { font-size: 3.5rem; display: block; margin-bottom: 16px; }
        .empty-state p { font-size: 0.95rem; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <h1>Tra cứu đơn đặt sân</h1>
    <p class="sub-title">Tìm theo số điện thoại khách hàng, ngày đặt, hoặc kết hợp cả hai để chính xác hơn.</p>

    <!-- Search box -->
    <div class="search-card">
        <form method="GET" action="searchBooking">
            <input type="hidden" name="action" value="search">
            <div class="search-row">
                <div class="field-wrap">
                    <label>📞 Số điện thoại</label>
                    <input type="text" name="phone" placeholder="VD: 0901234567"
                           value="<%= phone %>" maxlength="15">
                </div>
                <div class="field-wrap">
                    <label>📅 Ngày đặt</label>
                    <input type="date" name="bookingDate" id="dateInput"
                           value="<%= bookingDate %>">
                </div>
                <button type="submit" class="btn-search">🔍 Tìm kiếm</button>
                <button type="button" class="btn-clear" title="Xóa bộ lọc" onclick="clearFilter()">✕</button>
            </div>
        </form>
    </div>

    <!-- Results -->
    <% if (results != null) { %>
        <% if (results.isEmpty()) { %>
            <div class="empty-state">
                <span class="icon">😕</span>
                <p>Không tìm thấy đơn đặt sân nào phù hợp.</p>
            </div>
        <% } else { %>
            <p class="result-count">Tìm thấy <strong><%= results.size() %></strong> đơn</p>

            <% for (BookingSearchResult r : results) {
                // Format ngày đặt
                String dateDisplay = r.getBookingDate();
                try {
                    java.time.LocalDate ld = java.time.LocalDate.parse(r.getBookingDate(), fmtIn);
                    String thu = thuViet[ld.getDayOfWeek().getValue() % 7 + 1];
                    // Thứ 2=1..Chủ nhật=7, getValue 1=Mon..7=Sun
                    int dow = ld.getDayOfWeek().getValue(); // 1=Mon,7=Sun
                    String[] labels = {"Thứ 2","Thứ 3","Thứ 4","Thứ 5","Thứ 6","Thứ 7","Chủ Nhật"};
                    dateDisplay = labels[dow - 1] + ", " + ld.format(fmtOut);
                } catch (Exception ignored) {}

                // Badge trạng thái
                String bkStatus   = r.getBookingStatus() != null ? r.getBookingStatus() : "BOOKED";
                String badgeClass, badgeLabel;
                switch (bkStatus) {
                    case "CANCELLED":
                        badgeClass = "badge-cancelled";
                        badgeLabel = "Đã hủy";
                        break;
                    case "PLAYING":
                        badgeClass = "badge-playing";
                        badgeLabel = "Đang chơi";
                        break;
                    case "DONE":
                        badgeClass = "badge-done";
                        badgeLabel = "Đã trả sân";
                        break;
                    default:
                        badgeClass = "badge-booked";
                        badgeLabel = "Đã xác nhận";
                        break;
                }
                if ("PLAYING".equals(bkStatus)) { badgeClass = "badge-checkin"; badgeLabel = "Đã check-in"; }
            %>
            <a href="searchBooking?action=detail&id=<%= r.getBookingId() %>" class="booking-card">
                <div class="card-left">
                    <div>
                        <div class="lbl">Mã đơn</div>
                        <div class="code">BK-<%= String.format("%04d", r.getBookingId()) %></div>
                    </div>
                    <span class="badge <%= badgeClass %>"><%= badgeLabel %></span>
                </div>
                <div class="card-body">
                    <div class="card-top">
                        <div>
                            <div class="cust-name">👤 <%= r.getCustomerName() %></div>
                            <div class="cust-meta">
                                <span>📞 <%= r.getCustomerPhone() %></span>
                                <span>📅 <%= dateDisplay %></span>
                            </div>
                        </div>
                        <div class="total-wrap">
                            <div class="lbl2">Tổng</div>
                            <div class="amount"><%= String.format("%,d", r.getNetAmount()) %>đ</div>
                        </div>
                    </div>

                    <% List<BookingSearchResult.BookingDetailSlot> slots = r.getSlots(); %>
                    <div class="slot-count">
                        <%= slots != null ? slots.size() : 0 %> khung giờ đã đặt
                    </div>
                    <div class="slot-tags">
                        <% if (slots != null) { for (BookingSearchResult.BookingDetailSlot s : slots) { %>
                            <span class="slot-tag">
                                📍 <%= s.getCourtName() %> &nbsp;·&nbsp;
                                🕐 <%= s.getSlotStart() %>–<%= s.getSlotEnd() %>
                            </span>
                        <% } } %>
                    </div>
                </div>
            </a>
            <% } %>
        <% } %>
    <% } else { %>
        <!-- Chưa tìm kiếm lần nào -->
        <div class="empty-state">
            <span class="icon">🔍</span>
            <p>Nhập số điện thoại hoặc chọn ngày để bắt đầu tìm kiếm.</p>
        </div>
    <% } %>
</div>

<script>
    function clearFilter() {
        window.location.href = 'searchBooking?action=search';
    }
</script>
</body>
</html>
