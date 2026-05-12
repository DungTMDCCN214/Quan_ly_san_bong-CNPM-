<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, model.BookingDetailView"%>
<%
    request.setAttribute("currentPage", "booking-search");

    Map<String, Object> header          = (Map<String, Object>) request.getAttribute("header");
    Map<String, List<BookingDetailView>> grouped = (Map<String, List<BookingDetailView>>) request.getAttribute("grouped");
    List<BookingDetailView> details     = (List<BookingDetailView>) request.getAttribute("details");
    int totalActive = request.getAttribute("totalActive") != null ? (Integer) request.getAttribute("totalActive") : 0;

    int    bookingId    = header != null ? (Integer) header.get("bookingId")   : 0;
    String bookingDate  = header != null ? (String)  header.get("bookingDate") : "";
    String customerName = header != null ? (String)  header.get("customerName"): "";
    String customerPhone= header != null ? (String)  header.get("customerPhone"): "";

    // Format ngày đặt -> "Thứ X, dd/MM/yyyy"
    String dateDisplay = bookingDate;
    try {
        java.time.LocalDate ld = java.time.LocalDate.parse(bookingDate);
        java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String[] labels = {"Thứ 2","Thứ 3","Thứ 4","Thứ 5","Thứ 6","Thứ 7","Chủ Nhật"};
        dateDisplay = labels[ld.getDayOfWeek().getValue() - 1] + ", " + ld.format(fmt);
    } catch (Exception ignored) {}

    int totalSlots = details != null ? details.size() : 0;
    // Đếm số sân unique
    long courtCount = grouped != null ? grouped.size() : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn đặt sân #<%= bookingId %></title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content { margin-left: 260px; flex: 1; padding-bottom: 90px; }

        /* ── Hero banner ─────────────────────────────────────────────── */
        .hero {
            background: linear-gradient(135deg, #4a6fa5 0%, #6b8dd6 60%, #7b9fe0 100%);
            padding: 32px 48px 40px; color: #fff;
        }
        .hero-top { display: flex; align-items: center; gap: 14px; margin-bottom: 16px; }
        .btn-back {
            background: rgba(255,255,255,0.18); color: #fff; border: none;
            padding: 8px 18px; border-radius: 20px; font-size: 0.85rem;
            font-weight: 600; cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px;
            transition: all 0.3s ease;
        }
        .btn-back:hover { background: rgba(255,255,255,0.28); }

        .booking-badge {
            background: rgba(255,255,255,0.18); color: #fff;
            padding: 5px 14px; border-radius: 20px; font-size: 0.82rem; font-weight: 600;
        }
        .hero h1 { font-size: 2.2rem; font-weight: 800; margin-bottom: 8px; }
        .hero p  { font-size: 0.9rem; opacity: 0.8; margin-bottom: 28px; }

        /* 3 info cards trong hero */
        .info-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
        .info-card {
            background: rgba(255,255,255,0.15); border-radius: 12px; padding: 14px 18px;
            display: flex; align-items: center; gap: 14px; backdrop-filter: blur(4px);
        }
        .info-card .ic-icon {
            width: 38px; height: 38px; background: rgba(255,255,255,0.2);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; flex-shrink: 0;
        }
        .info-card .ic-lbl { font-size: 0.7rem; font-weight: 700; opacity: 0.75; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 3px; }
        .info-card .ic-val { font-size: 1rem; font-weight: 700; }

        /* ── Body ─────────────────────────────────────────────────────── */
        .body-wrap { padding: 32px 48px; }

        .section-title { font-size: 1.1rem; font-weight: 800; color: #1a2332; margin-bottom: 4px; }
        .section-sub   { font-size: 0.85rem; color: #999; margin-bottom: 22px; }

        /* Court group */
        .court-group {
            background: #fff; border-radius: 14px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            margin-bottom: 18px; overflow: hidden;
        }
        .court-group-header {
            display: flex; align-items: center; gap: 10px;
            padding: 14px 22px; border-bottom: 1px solid #f0f0f0;
            background: #fafbfc;
        }
        .court-group-header .court-label {
            font-size: 0.95rem; font-weight: 700; color: #1a2332;
        }

        /* Slot row */
        .slot-row {
            display: flex; align-items: center; gap: 16px;
            padding: 16px 22px; border-bottom: 1px solid #f7f7f7;
            transition: background 0.2s;
        }
        .slot-row:last-child { border-bottom: none; }
        .slot-row:hover { background: #f8fbff; }

        .slot-clock {
            width: 42px; height: 42px; background: #eef2ff; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; flex-shrink: 0;
        }
        .slot-info { flex: 1; }
        .slot-time { font-size: 0.97rem; font-weight: 700; color: #1a2332; display: flex; align-items: center; gap: 10px; }
        .slot-price { font-size: 0.82rem; color: #999; margin-top: 3px; }

        /* Status badge inline */
        .status-badge {
            padding: 4px 11px; border-radius: 20px; font-size: 0.76rem; font-weight: 700;
        }
        .sb-booked    { background: #fff8e1; color: #f57c00; }
        .sb-playing   { background: #e8f5e9; color: #2e7d32; }
        .sb-done      { background: #e3f2fd; color: #1565c0; }
        .sb-cancelled { background: #fce4ec; color: #c62828; text-decoration: line-through; }

        /* Action buttons */
        .slot-actions { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }
        .btn-action {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 8px 16px; border-radius: 8px; font-size: 0.82rem;
            font-weight: 700; border: 1.5px solid; cursor: pointer;
            transition: all 0.25s ease; white-space: nowrap;
        }
        /* Check-in */
        .btn-checkin         { border-color: #43a047; color: #43a047; background: #fff; }
        .btn-checkin:hover   { background: #43a047; color: #fff; }
        .btn-checkin.active  { background: #43a047; color: #fff; }
        .btn-checkin.disabled{ border-color: #ddd; color: #bbb; cursor: not-allowed; background: #fafafa; }
        /* Check-out */
        .btn-checkout         { border-color: #1976d2; color: #1976d2; background: #fff; }
        .btn-checkout:hover   { background: #1976d2; color: #fff; }
        .btn-checkout.active  { background: #1976d2; color: #fff; }
        .btn-checkout.disabled{ border-color: #ddd; color: #bbb; cursor: not-allowed; background: #fafafa; }
        /* Hủy */
        .btn-cancel         { border-color: #e53935; color: #e53935; background: #fff; }
        .btn-cancel:hover   { background: #ffebee; }
        .btn-cancel.disabled{ border-color: #ddd; color: #bbb; cursor: not-allowed; background: #fafafa; }

        /* Pending State */
        .btn-action.pending {
            background-color: #ffb300 !important;
            color: white !important;
            border-color: #ffa000 !important;
            opacity: 1 !important;
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }

        /* ── Bottom bar ───────────────────────────────────────────────── */
        .bottom-bar {
            position: fixed; bottom: 0; left: 260px; right: 0;
            background: #fff; border-top: 1px solid #eee;
            padding: 14px 48px; display: flex; align-items: center;
            box-shadow: 0 -2px 12px rgba(0,0,0,0.07); z-index: 99;
        }
        .total-label { font-size: 0.82rem; color: #999; margin-bottom: 2px; }
        .total-amount { font-size: 1.4rem; font-weight: 800; color: #1a2332; }
        .btn-apply {
            margin-left: auto; padding: 13px 32px;
            background: linear-gradient(135deg, #6b8dd6, #4a6fa5);
            color: #fff; border: none; border-radius: 12px; font-size: 0.95rem;
            font-weight: 700; cursor: pointer; transition: all 0.3s ease;
        }
        .btn-apply:hover { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(74,111,165,0.35); }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <!-- Hero -->
    <div class="hero">
        <div class="hero-top">
            <a href="searchBooking?action=search" class="btn-back">← Quay lại</a>
            <span class="booking-badge">Mã đơn #BK-<%= String.format("%04d", bookingId) %></span>
        </div>
        <h1>Chi tiết đơn đặt sân</h1>
        <p>Quản lý check-in, check-out và hủy lịch theo từng khung giờ.</p>

        <div class="info-cards">
            <div class="info-card">
                <div class="ic-icon">📅</div>
                <div>
                    <div class="ic-lbl">Ngày đặt</div>
                    <div class="ic-val"><%= dateDisplay %></div>
                </div>
            </div>
            <div class="info-card">
                <div class="ic-icon">👤</div>
                <div>
                    <div class="ic-lbl">Khách hàng</div>
                    <div class="ic-val"><%= customerName %></div>
                </div>
            </div>
            <div class="info-card">
                <div class="ic-icon">📞</div>
                <div>
                    <div class="ic-lbl">Số điện thoại</div>
                    <div class="ic-val"><%= customerPhone %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Body -->
    <div class="body-wrap">
        <div class="section-title">Khung giờ đã đặt</div>
        <div class="section-sub">
            <%= totalSlots %> khung giờ trên <%= courtCount %> sân
        </div>

        <form method="POST" action="searchBooking" id="applyForm">
            <input type="hidden" name="action" value="applyChanges">
            <input type="hidden" name="bookingId" value="<%= bookingId %>">

            <%-- Hidden inputs cho từng detailId - status (JS cập nhật khi click) --%>
            <% if (details != null) { for (BookingDetailView d : details) { %>
                <input type="hidden" name="status_<%= d.getBookingDetailId() %>"
                       id="status_<%= d.getBookingDetailId() %>"
                       value="<%= d.getDetailStatus() %>">
            <% } } %>

            <% if (grouped != null) {
                for (Map.Entry<String, List<BookingDetailView>> entry : grouped.entrySet()) {
                    String courtName = entry.getKey();
                    List<BookingDetailView> courtSlots = entry.getValue();
            %>
            <div class="court-group">
                <div class="court-group-header">
                    <span>📍</span>
                    <span class="court-label"><%= courtName %></span>
                </div>

                <% for (BookingDetailView slot : courtSlots) {
                    String st = slot.getDetailStatus();

                    // Trạng thái hiển thị
                    String sbClass, sbLabel;
                    switch (st) {
                        case "PLAYING":
                            sbClass = "sb-playing";
                            sbLabel = "Đang chơi";
                            break;
                        case "DONE":
                            sbClass = "sb-done";
                            sbLabel = "Đã trả sân";
                            break;
                        case "CANCELLED":
                            sbClass = "sb-cancelled";
                            sbLabel = "Đã hủy";
                            break;
                        default:
                            sbClass = "sb-booked";
                            sbLabel = "Đã đặt";
                            break;
                    }

                    // Logic disable:
                    // Check-in  → enabled chỉ khi BOOKED; disabled khi PLAYING/DONE/CANCELLED
                    // Check-out → enabled chỉ khi PLAYING; disabled các trạng thái khác
                    // Hủy       → enabled chỉ khi BOOKED; disabled khi PLAYING/DONE/CANCELLED
                    boolean canCheckin  = "BOOKED".equals(st);
                    boolean canCheckout = "PLAYING".equals(st);
                    boolean canCancel   = "BOOKED".equals(st);

                    int did = slot.getBookingDetailId();
                %>
                <div class="slot-row" id="row_<%= did %>">
                    <div class="slot-clock">🕐</div>
                    <div class="slot-info">
                        <div class="slot-time">
                            <%= slot.getSlotStart() %> – <%= slot.getSlotEnd() %>
                            <span class="status-badge <%= sbClass %>" id="badge_<%= did %>"><%= sbLabel %></span>
                        </div>
                        <div class="slot-price">
                            <%= String.format("%,d", slot.getPricePerHour()) %>đ
                            <%= slot.getUsageDate() != null && !slot.getUsageDate().isBlank()
                                ? " &nbsp;·&nbsp; " + slot.getUsageDate() : "" %>
                        </div>
                    </div>

                    <div class="slot-actions">
                        <%-- Check-in --%>
                        <button type="button"
                                class="btn-action btn-checkin <%= !canCheckin ? "disabled" : "" %> <%= "PLAYING".equals(st)||"DONE".equals(st) ? "active" : "" %>"
                                id="btn_checkin_<%= did %>"
                                <%= !canCheckin ? "disabled" : "" %>
                                onclick="handleAction(<%= did %>, 'PLAYING')">
                            ✅ Check-in
                        </button>

                        <%-- Check-out --%>
                        <button type="button"
                                class="btn-action btn-checkout <%= !canCheckout ? "disabled" : "" %> <%= "DONE".equals(st) ? "active" : "" %>"
                                id="btn_checkout_<%= did %>"
                                <%= !canCheckout ? "disabled" : "" %>
                                onclick="handleAction(<%= did %>, 'DONE')">
                            🚪 Check-out
                        </button>

                        <%-- Hủy --%>
                        <button type="button"
                                class="btn-action btn-cancel <%= !canCancel ? "disabled" : "" %>"
                                id="btn_cancel_<%= did %>"
                                <%= !canCancel ? "disabled" : "" %>
                                onclick="handleCancel(<%= did %>)">
                            ✕ Hủy
                        </button>
                    </div>
                </div>
                <% } %>
            </div>
            <% } } %>
        </form>
    </div>
</div>

<!-- Bottom bar -->
<div class="bottom-bar">
    <div>
        <div class="total-label">Tổng cộng (chưa hủy)</div>
        <div class="total-amount" id="totalDisplay">
            <%= String.format("%,d", totalActive) %>đ
        </div>
    </div>
    <button class="btn-apply" onclick="applyChanges()">Áp dụng thay đổi</button>
</div>

<script>
    // Giá từng slot (để tính lại tổng tiền realtime phía client)
    const slotPrices = {
        <% if (details != null) { for (BookingDetailView d : details) { %>
        <%= d.getBookingDetailId() %>: <%= d.getPricePerHour() %>,
        <% } } %>
    };

    // Trạng thái client-side (có thể thay đổi trước khi submit)
    const clientStatus = {
        <% if (details != null) { for (BookingDetailView d : details) { %>
        <%= d.getBookingDetailId() %>: '<%= d.getDetailStatus() %>',
        <% } } %>
    };

    // Trạng thái ban đầu (trong DB)
    const originalStatus = {
        <% if (details != null) { for (BookingDetailView d : details) { %>
        <%= d.getBookingDetailId() %>: '<%= d.getDetailStatus() %>',
        <% } } %>
    };

    function handleAction(did, newStatus) {
        clientStatus[did] = newStatus;
        document.getElementById('status_' + did).value = newStatus;
        refreshRow(did, newStatus);
        recalcTotal();
    }

    function handleCancel(did) {
        if (!confirm('Xác nhận hủy khung giờ này?')) return;
        handleAction(did, 'CANCELLED');
    }

    function refreshRow(did, st) {
        // Cập nhật badge
        const badge = document.getElementById('badge_' + did);
        const ci    = document.getElementById('btn_checkin_' + did);
        const co    = document.getElementById('btn_checkout_' + did);
        const ca    = document.getElementById('btn_cancel_' + did);

        const isPending = (st !== originalStatus[did]);

        // Badge text + class
        const badgeMap = {
            BOOKED:    ['sb-booked',    'Đã đặt'],
            PLAYING:   ['sb-playing',   'Đang chơi'],
            DONE:      ['sb-done',      'Đã trả sân'],
            CANCELLED: ['sb-cancelled', 'Đã hủy'],
        };
        
        if (isPending) {
            badge.className = 'status-badge';
            badge.style.backgroundColor = '#ffb300';
            badge.style.color = '#fff';
            let actionName = '';
            if (st === 'PLAYING') actionName = 'Check-in';
            if (st === 'DONE') actionName = 'Check-out';
            if (st === 'CANCELLED') actionName = 'Hủy';
            badge.textContent = 'Chờ ' + actionName + '...';
        } else {
            badge.className = 'status-badge ' + (badgeMap[st]?.[0] || 'sb-booked');
            badge.style = '';
            badge.textContent = badgeMap[st]?.[1] || st;
        }

        // Reset tất cả về disabled trước
        [ci, co, ca].forEach(btn => {
            btn.classList.add('disabled');
            btn.disabled = true;
            btn.classList.remove('active');
            btn.classList.remove('pending');
        });

        // Dựa vào trạng thái gốc (chưa lưu) để quyết định nút nào được phép click
        const effectiveSt = originalStatus[did];

        if (effectiveSt === 'BOOKED') {
            ci.classList.remove('disabled'); ci.disabled = false;
            ca.classList.remove('disabled'); ca.disabled = false;
        } else if (effectiveSt === 'PLAYING') {
            ci.classList.add('active');
            co.classList.remove('disabled'); co.disabled = false;
        } else if (effectiveSt === 'DONE') {
            ci.classList.add('active');
            co.classList.add('active');
        }

        // Cập nhật text và style cho trạng thái chờ
        if (isPending) {
            if (st === 'PLAYING') { ci.classList.add('pending'); ci.innerHTML = '<i class="fas fa-hourglass-half"></i> Chờ Check-in'; }
            if (st === 'DONE')    { co.classList.add('pending'); co.innerHTML = '<i class="fas fa-hourglass-half"></i> Chờ Check-out'; }
            if (st === 'CANCELLED') { ca.classList.add('pending'); ca.innerHTML = '<i class="fas fa-hourglass-half"></i> Chờ Hủy'; }
        } else {
            ci.innerHTML = '<i class="fas fa-sign-in-alt"></i> Check-in';
            co.innerHTML = '<i class="fas fa-sign-out-alt"></i> Check-out';
            ca.innerHTML = '<i class="fas fa-times-circle"></i> Hủy sân';
        }
    }

    function recalcTotal() {
        let total = 0;
        for (const [id, st] of Object.entries(clientStatus)) {
            if (st !== 'CANCELLED') {
                total += slotPrices[id] || 0;
            }
        }
        document.getElementById('totalDisplay').textContent =
            total.toLocaleString('vi-VN') + 'đ';
    }

    function applyChanges() {
        document.getElementById('applyForm').submit();
    }
</script>
</body>
</html>
