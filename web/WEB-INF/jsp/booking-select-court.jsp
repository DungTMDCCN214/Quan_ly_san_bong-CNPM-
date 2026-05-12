<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, java.util.Set, java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter, model.Court, model.TimeSlot, model.Customer"%>
<%
    request.setAttribute("currentPage", "booking-new");
    Customer customer    = (Customer)  request.getAttribute("customer");
    List<Court> courts   = (List<Court>) request.getAttribute("courts");
    List<TimeSlot> slots = (List<TimeSlot>) request.getAttribute("timeSlots");
    Map<Integer, Set<Integer>> bookedMap = (Map<Integer, Set<Integer>>) request.getAttribute("bookedMap");
    String selectedDate  = (String) request.getAttribute("selectedDate");

    LocalDate today = LocalDate.now();
    if (selectedDate == null) selectedDate = today.toString();

    // Đọc lỗi session
    String slotError = (String) request.getSession().getAttribute("slotError");
    if (slotError != null) request.getSession().removeAttribute("slotError");

    // 7 ngày từ hôm nay
    LocalDate[] next7 = new LocalDate[7];
    for (int i = 0; i < 7; i++) next7[i] = today.plusDays(i);

    // Giờ hiện tại
    LocalTime nowTime = LocalTime.now();
    boolean isToday   = selectedDate.equals(today.toString());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt sân – Chọn ngày & Khung giờ</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content { margin-left: 260px; flex: 1; padding: 28px 32px 100px; }

        /* Steps */
        .steps-bar {
            display: flex; align-items: center; gap: 6px;
            background: #fff; padding: 15px 24px; border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06); margin-bottom: 22px;
        }
        .step { display: flex; align-items: center; gap: 8px; }
        .step-num {
            width: 30px; height: 30px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.82rem; font-weight: 700;
        }
        .step.active .step-num { background: #1976d2; color: #fff; }
        .step.done   .step-num { background: #43a047; color: #fff; }
        .step.idle   .step-num { background: #e0e0e0; color: #999; }
        .step-label  { font-size: 0.85rem; color: #555; }
        .step.active .step-label { color: #1976d2; font-weight: 600; }
        .step.done   .step-label { color: #43a047; }
        .step-divider { flex: 1; height: 2px; background: #e0e0e0; max-width: 60px; }

        /* Customer strip */
        .customer-strip {
            background: #fff; border-radius: 12px; padding: 14px 22px;
            display: flex; align-items: center; gap: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 22px;
        }
        .cust-avatar {
            width: 40px; height: 40px; border-radius: 50%;
            background: #1976d2; color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; font-weight: 700; flex-shrink: 0;
        }
        .cust-name  { font-weight: 700; color: #1a2332; font-size: 0.95rem; }
        .cust-phone { color: #1976d2; font-size: 0.82rem; }

        /* Date picker 7 ngày */
        .date-picker-wrap {
            background: #fff; border-radius: 14px; padding: 18px 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06); margin-bottom: 22px;
        }
        .dp-label {
            font-size: 0.78rem; font-weight: 700; color: #aaa;
            text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 14px;
        }
        .date-tabs { display: flex; gap: 10px; flex-wrap: wrap; }
        .date-tab {
            display: flex; flex-direction: column; align-items: center;
            padding: 10px 16px; border-radius: 12px; border: 2px solid #e8e8e8;
            cursor: pointer; min-width: 78px; transition: all 0.25s ease;
            text-decoration: none; background: #fafafa;
        }
        .date-tab:hover:not(.active) { border-color: #90caf9; background: #e3f2fd; }
        .date-tab.active { border-color: #1976d2; background: #1976d2; }
        .dt-day  { font-size: 0.7rem; font-weight: 700; color: #999; text-transform: uppercase; margin-bottom: 4px; }
        .dt-date { font-size: 1rem; font-weight: 800; color: #1a2332; }
        .date-tab.active .dt-day,
        .date-tab.active .dt-date { color: #fff; }
        .dt-dot {
            width: 5px; height: 5px; border-radius: 50%;
            background: #1976d2; margin-top: 5px;
        }
        .date-tab.active .dt-dot { background: rgba(255,255,255,0.7); }

        /* Alert */
        .alert-err {
            background: #ffebee; border-left: 4px solid #e53935; color: #c62828;
            padding: 12px 18px; border-radius: 8px; margin-bottom: 16px; font-size: 0.9rem;
        }

        /* Legend */
        .legend { display: flex; gap: 18px; flex-wrap: wrap; margin-bottom: 18px; }
        .legend-item { display: flex; align-items: center; gap: 6px; font-size: 0.8rem; color: #666; }
        .ld { width: 13px; height: 13px; border-radius: 4px; flex-shrink: 0; }
        .ld-free     { background: #fafafa; border: 2px solid #ddd; }
        .ld-selected { background: #1976d2; }
        .ld-booked   { background: #ffebee; border: 2px solid #ffcdd2; }
        .ld-past     { background: #f5f5f5; border: 2px solid #eee; }

        /* Court card */
        .court-card {
            background: #fff; border-radius: 14px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            margin-bottom: 18px; overflow: hidden;
        }
        .court-header {
            display: flex; align-items: center; gap: 12px;
            padding: 14px 20px; border-bottom: 1px solid #f2f2f2; background: #fafbfc;
        }
        .court-icon { font-size: 1.4rem; }
        .court-name-text { font-size: 0.97rem; font-weight: 700; color: #1a2332; }
        .court-desc-text  { font-size: 0.78rem; color: #aaa; margin-top: 1px; }
        .court-price-text { margin-left: auto; font-size: 0.97rem; font-weight: 800; color: #1976d2; white-space: nowrap; }
        .badge-type { padding: 2px 9px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; margin-left: 6px; }
        .badge-vip    { background: #fff3e0; color: #e65100; }
        .badge-normal { background: #e8f5e9; color: #2e7d32; }

        .slots-body { padding: 16px 20px; }
        .slots-grid { display: flex; flex-wrap: wrap; gap: 10px; }

        /* Chip */
        .chip {
            padding: 9px 15px; border-radius: 9px; font-size: 0.84rem;
            font-weight: 600; cursor: pointer; border: 2px solid #e0e0e0;
            background: #fafafa; color: #555; transition: all 0.22s ease;
            user-select: none; min-width: 100px; text-align: center; line-height: 1.3;
        }
        .chip:hover:not(.chip-booked):not(.chip-past) {
            border-color: #1976d2; color: #1976d2; background: #e3f2fd;
        }
        .chip.chip-selected {
            background: #1976d2; color: #fff; border-color: #1976d2;
            box-shadow: 0 2px 8px rgba(25,118,210,0.28);
        }
        .chip.chip-booked {
            background: #fff0f0; color: #f48fb1; border-color: #ffcdd2; cursor: not-allowed;
        }
        .chip.chip-past {
            background: #f5f5f5; color: #ccc; border-color: #eee;
            cursor: not-allowed; text-decoration: line-through;
        }
        .chip-sub { font-size: 0.69rem; margin-top: 2px; display: block; opacity: 0.75; }

        /* Bottom bar */
        .bottom-bar {
            position: fixed; bottom: 0; left: 260px; right: 0;
            background: #fff; border-top: 1px solid #eee;
            padding: 13px 32px; display: flex; align-items: center; gap: 16px;
            box-shadow: 0 -2px 12px rgba(0,0,0,0.08); z-index: 99;
        }
        .summary-txt { flex: 1; font-size: 0.9rem; color: #666; }
        .summary-txt strong { color: #1976d2; font-weight: 700; }
        .btn {
            padding: 11px 28px; border: none; border-radius: 10px;
            font-size: 0.92rem; font-weight: 700; cursor: pointer;
            transition: all 0.3s ease; text-decoration: none; display: inline-block;
        }
        .btn-secondary { background: #f0f0f0; color: #555; }
        .btn-secondary:hover { background: #e0e0e0; }
        .btn-primary { background: #1976d2; color: #fff; }
        .btn-primary:hover { background: #1565c0; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(25,118,210,0.3); }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <!-- Steps -->
    <div class="steps-bar">
        <div class="step done"><div class="step-num">✓</div><div class="step-label">Tra cứu khách hàng</div></div>
        <div class="step-divider"></div>
        <div class="step active"><div class="step-num">2</div><div class="step-label">Chọn ngày & Khung giờ</div></div>
        <div class="step-divider"></div>
        <div class="step idle"><div class="step-num">3</div><div class="step-label">Xác nhận & Lưu</div></div>
    </div>

    <!-- Customer strip -->
    <div class="customer-strip">
        <div class="cust-avatar"><%= customer.getFull_name().charAt(0) %></div>
        <div>
            <div class="cust-name"><%= customer.getFull_name() %></div>
            <div class="cust-phone">📞 <%= customer.getPhone() %></div>
        </div>
    </div>

    <!-- Date picker 7 ngày -->
    <div class="date-picker-wrap">
        <div class="dp-label">📅 Chọn ngày sử dụng sân</div>
        <div class="date-tabs">
        <% for (int di = 0; di < 7; di++) {
            LocalDate d = next7[di];
            boolean isActive = d.toString().equals(selectedDate);
            int dow = d.getDayOfWeek().getValue(); // 1=Mon..7=Sun
            String[] dayLbs = {"T2","T3","T4","T5","T6","T7","CN"};
            String dayLb = d.equals(today) ? "Hôm nay" : dayLbs[dow - 1];
            String dateLb = d.format(DateTimeFormatter.ofPattern("dd/MM"));
        %>
        <a href="booking?action=selectCourt&date=<%= d.toString() %>"
           class="date-tab <%= isActive ? "active" : "" %>">
            <span class="dt-day"><%= dayLb %></span>
            <span class="dt-date"><%= dateLb %></span>
            <% if (d.equals(today)) { %><span class="dt-dot"></span><% } %>
        </a>
        <% } %>
        </div>
    </div>

    <% if (slotError != null) { %>
        <div class="alert-err">⚠️ <%= slotError %></div>
    <% } %>

    <!-- Legend -->
    <div class="legend">
        <div class="legend-item"><span class="ld ld-free"></span>Còn trống</div>
        <div class="legend-item"><span class="ld ld-selected"></span>Đang chọn</div>
        <div class="legend-item"><span class="ld ld-booked"></span>Đã có người đặt</div>
        <div class="legend-item"><span class="ld ld-past"></span>Giờ đã qua</div>
    </div>

    <!-- Form ẩn -->
    <form method="POST" action="booking" id="slotsForm">
        <input type="hidden" name="action" value="chooseSlots">
    </form>

    <!-- Danh sách sân -->
    <% if (courts == null || courts.isEmpty()) { %>
        <div style="text-align:center;padding:60px;color:#bbb;">Không có sân nào đang hoạt động.</div>
    <% } else {
        for (Court ct : courts) {
            Set<Integer> bookedSet = (bookedMap != null && bookedMap.get(ct.getCourt_id()) != null)
                                     ? bookedMap.get(ct.getCourt_id()) : new java.util.HashSet<>();
    %>
    <div class="court-card">
        <div class="court-header">
            <span class="court-icon">🏟️</span>
            <div>
                <div class="court-name-text">
                    <%= ct.getName() %>
                    <span class="badge-type <%= "VIP".equals(ct.getType()) ? "badge-vip" : "badge-normal" %>">
                        <%= ct.getType() %>
                    </span>
                </div>
                <div class="court-desc-text"><%= ct.getDescription() != null ? ct.getDescription() : "" %></div>
            </div>
            <div class="court-price-text"><%= String.format("%,.0f", ct.getPrice_per_hour()) %> đ/giờ</div>
        </div>

        <div class="slots-body">
            <div class="slots-grid">
            <% if (slots == null || slots.isEmpty()) { %>
                <span style="color:#bbb;font-size:0.87rem;">Chưa có khung giờ.</span>
            <% } else {
                for (TimeSlot ts : slots) {
                    boolean isBookedSlot = bookedSet.contains(ts.getTimeSlotId());

                    // Disable nếu giờ đã qua (chỉ áp dụng khi = hôm nay)
                    boolean isPast = false;
                    if (isToday) {
                        try {
                            // Disable nếu endTime <= giờ hiện tại
                            LocalTime slotEnd = LocalTime.parse(ts.getEndTime());
                            isPast = !slotEnd.isAfter(nowTime);
                        } catch (Exception ignored) {}
                    }

                    boolean isDisabled = isBookedSlot || isPast;

                    // value gửi lên: courtId|timeSlotId|usageDate|pricePerHour|courtName|slotStart|slotEnd
                    String chipVal = ct.getCourt_id() + "|" + ts.getTimeSlotId() + "|" + selectedDate
                                   + "|" + ct.getPrice_per_hour() + "|" + ct.getName()
                                   + "|" + ts.getStartTime() + "|" + ts.getEndTime();

                    String chipClass = "chip";
                    String subLabel  = "";
                    if (isPast)            { chipClass += " chip-past";   subLabel = "Đã qua"; }
                    else if (isBookedSlot) { chipClass += " chip-booked"; subLabel = "Đã đặt"; }
            %>
                <div class="<%= chipClass %>"
                     data-value="<%= chipVal %>"
                     data-disabled="<%= isDisabled %>"
                     onclick="<%= !isDisabled ? "toggleChip(this)" : "" %>"
                     title="<%= isPast ? "Khung giờ đã qua" : isBookedSlot ? "Đã có người đặt" : "Click để chọn" %>">
                    <%= ts.getStartTime() %> – <%= ts.getEndTime() %>
                    <% if (!subLabel.isEmpty()) { %>
                        <span class="chip-sub"><%= subLabel %></span>
                    <% } %>
                </div>
            <% } } %>
            </div>
        </div>
    </div>
    <% } } %>
</div>

<!-- Bottom bar -->
<div class="bottom-bar">
    <div class="summary-txt" id="summaryTxt">Chưa chọn khung giờ nào.</div>
    <a href="booking?action=start" class="btn btn-secondary">← Quay lại</a>
    <button type="button" class="btn btn-primary" onclick="submitSlots()">Tiếp tục →</button>
</div>

<script>
    const selected = new Map();

    function toggleChip(el) {
        if (el.dataset.disabled === 'true') return;
        const val = el.dataset.value;
        if (el.classList.contains('chip-selected')) {
            el.classList.remove('chip-selected');
            selected.delete(val);
        } else {
            el.classList.add('chip-selected');
            selected.set(val, true);
        }
        updateSummary();
    }

    function updateSummary() {
        const el = document.getElementById('summaryTxt');
        if (selected.size === 0) { el.innerHTML = 'Chưa chọn khung giờ nào.'; return; }
        
        let total = 0;
        let detailsHtml = '<ul style="margin: 8px 0; padding-left: 20px; font-size: 14px; text-align: left; list-style-type: none;">';
        
        selected.forEach((_, val) => { 
            const parts = val.split('|');
            // val format: court_id|time_slot_id|usage_date|price_per_hour|court_name|start_time|end_time
            const price = parseInt(parts[3]);
            total += price; 
            detailsHtml += '<li style="margin-bottom: 4px;">✔️ Sân <strong>' + parts[4] + '</strong>: ' + parts[5] + ' – ' + parts[6] + 
                           '<span style="color:#e53935; float:right;">' + price.toLocaleString('vi-VN') + ' đ</span></li>';
        });
        detailsHtml += '</ul>';
        
        el.innerHTML = 'Đã chọn <strong>' + selected.size + '</strong> khung giờ:' 
                     + detailsHtml
                     + '<div style="margin-top: 10px; border-top: 1px dashed #ccc; padding-top: 8px; text-align: right;">'
                     + 'Tổng tiền sân: <strong style="font-size: 18px; color: #1976d2;">' + total.toLocaleString('vi-VN') + ' đ</strong>'
                     + '</div>';
    }

    function submitSlots() {
        if (selected.size === 0) { alert('Vui lòng chọn ít nhất một khung giờ!'); return; }
        const form = document.getElementById('slotsForm');
        form.querySelectorAll('input[name="slot"]').forEach(e => e.remove());
        selected.forEach((_, val) => {
            const inp = document.createElement('input');
            inp.type = 'hidden'; inp.name = 'slot'; inp.value = val;
            form.appendChild(inp);
        });
        form.submit();
    }
</script>
</body>
</html>
