<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.BookingDetail, model.Customer"%>
<%
    request.setAttribute("currentPage", "booking-new");
    Customer customer   = (Customer) request.getAttribute("customer");
    List<BookingDetail> details = (List<BookingDetail>) request.getAttribute("details");
    int totalAmount = 0;
    if (request.getAttribute("totalAmount") != null) {
        // Ép kiểu về Number trước để tránh lỗi Double vs Integer
        totalAmount = ((Number) request.getAttribute("totalAmount")).intValue();
    }
    String error    = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt sân – Xác nhận</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content { margin-left: 260px; flex: 1; padding: 32px; }

        .steps-bar {
            display: flex; align-items: center; gap: 6px;
            background: #fff; padding: 16px 24px; border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06); margin-bottom: 24px;
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

        /* Summary banner */
        .banner {
            background: linear-gradient(135deg, #1565c0, #1976d2);
            border-radius: 12px; padding: 24px 32px; color: #fff;
            display: flex; align-items: center; gap: 32px; margin-bottom: 24px;
            flex-wrap: wrap;
        }
        .banner-item .label { font-size: 0.8rem; opacity: 0.75; margin-bottom: 4px; }
        .banner-item .val   { font-size: 1.6rem; font-weight: 700; }
        .banner-item .sub   { font-size: 0.82rem; opacity: 0.8; margin-top: 2px; }
        .banner-sep { width: 1px; background: rgba(255,255,255,0.25); height: 56px; }

        /* 2 col */
        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07); padding: 22px 26px;
        }
        .card-title { font-size: 0.97rem; font-weight: 700; color: #1a2332; margin-bottom: 14px;
            display: flex; align-items: center; gap: 8px; }
        .info-row { display: flex; margin-bottom: 9px; }
        .info-lbl { width: 120px; font-size: 0.85rem; color: #999; flex-shrink: 0; }
        .info-val { font-size: 0.88rem; font-weight: 600; color: #1a2332; }

        /* Detail table */
        .detail-table { width: 100%; border-collapse: collapse; }
        .detail-table th {
            background: #f5f7fa; padding: 10px 14px; text-align: left;
            font-size: 0.77rem; color: #777; font-weight: 700;
            text-transform: uppercase; border-bottom: 2px solid #eee;
        }
        .detail-table td { padding: 11px 14px; border-bottom: 1px solid #f2f2f2; font-size: 0.88rem; }
        .detail-table tr:last-child td { border-bottom: none; }
        .detail-table tfoot td { font-weight: 700; font-size: 0.95rem; background: #f8fbff; }

        .badge-court { display: inline-block; padding: 3px 10px; border-radius: 20px;
            background: #e3f2fd; color: #1565c0; font-size: 0.76rem; font-weight: 700; }
        .badge-slot  { display: inline-block; padding: 3px 10px; border-radius: 20px;
            background: #f3e5f5; color: #7b1fa2; font-size: 0.76rem; font-weight: 700; }
        .badge-date  { display: inline-block; padding: 3px 10px; border-radius: 20px;
            background: #e8f5e9; color: #2e7d32; font-size: 0.76rem; font-weight: 700; }

        .alert-err {
            background: #ffebee; border-left: 4px solid #e53935; color: #c62828;
            padding: 12px 18px; border-radius: 8px; margin-bottom: 18px; font-size: 0.9rem;
        }

        .action-row { display: flex; gap: 14px; justify-content: flex-end; }
        .btn {
            padding: 12px 30px; border: none; border-radius: 10px;
            font-size: 0.93rem; font-weight: 700; cursor: pointer;
            transition: all 0.3s ease; text-decoration: none; display: inline-block;
        }
        .btn-secondary { background: #f0f0f0; color: #555; }
        .btn-secondary:hover { background: #e0e0e0; }
        .btn-success { background: #43a047; color: #fff; }
        .btn-success:hover { background: #388e3c; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(67,160,71,0.3); }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <div class="steps-bar">
        <div class="step done"><div class="step-num">✓</div><div class="step-label">Tra cứu khách hàng</div></div>
        <div class="step-divider"></div>
        <div class="step done"><div class="step-num">✓</div><div class="step-label">Chọn sân & Khung giờ</div></div>
        <div class="step-divider"></div>
        <div class="step active"><div class="step-num">3</div><div class="step-label">Xác nhận & Lưu</div></div>
    </div>

    <% if (error != null) { %><div class="alert-err">⚠️ <%= error %></div><% } %>

    <!-- Banner tổng tiền -->
    <div class="banner">
        <div class="banner-item">
            <div class="label">Tổng tiền sân</div>
            <div class="val"><%= String.format("%,d", totalAmount) %> đ</div>
            <div class="sub"><%= details != null ? details.size() : 0 %> khung giờ</div>
        </div>
        <div class="banner-sep"></div>
        <div class="banner-item">
            <div class="label">Tiền cọc (10%)</div>
            <div class="val" style="font-size:1.3rem;"><%= String.format("%,d", (int)(totalAmount * 0.1)) %> đ</div>
            <div class="sub">Thu ngay khi xác nhận</div>
        </div>
        <div class="banner-sep"></div>
        <div class="banner-item">
            <div class="label">Trạng thái đơn</div>
            <div class="val" style="font-size:1.1rem;">✅ BOOKED</div>
            <div class="sub">Sẽ lưu sau khi xác nhận</div>
        </div>
    </div>

    <!-- Thông tin KH + tóm tắt -->
    <div class="row-2">
        <div class="card">
            <div class="card-title">👤 Khách hàng</div>
            <% if (customer != null) { %>
            <div class="info-row"><div class="info-lbl">Họ tên:</div><div class="info-val"><%= customer.getFull_name() %></div></div>
            <div class="info-row"><div class="info-lbl">Số điện thoại:</div><div class="info-val">📞 <%= customer.getPhone() %></div></div>
            <div class="info-row"><div class="info-lbl">Loại KH:</div><div class="info-val"><%= customer.getCustomer_type() %></div></div>
            <div class="info-row"><div class="info-lbl">Địa chỉ:</div><div class="info-val"><%= customer.getAddress() != null ? customer.getAddress() : "—" %></div></div>
            <% } %>
        </div>
        <div class="card">
            <div class="card-title">📋 Tóm tắt đơn</div>
            <div class="info-row"><div class="info-lbl">Tổng khung giờ:</div><div class="info-val"><%= details != null ? details.size() : 0 %> khung giờ</div></div>
            <div class="info-row"><div class="info-lbl">Tổng tiền:</div><div class="info-val" style="color:#1976d2;"><%= String.format("%,d", totalAmount) %> đ</div></div>
            <div class="info-row"><div class="info-lbl">Tiền cọc:</div><div class="info-val" style="color:#e53935;"><%= String.format("%,d", (int)(totalAmount * 0.1)) %> đ</div></div>
            <div class="info-row"><div class="info-lbl">Hóa đơn:</div><div class="info-val" style="color:#888;">UNPAID (tạo tự động)</div></div>
        </div>
    </div>

    <!-- Chi tiết từng slot -->
    <div class="card" style="margin-bottom:24px;">
        <div class="card-title">🏟️ Chi tiết sân & Khung giờ đã chọn</div>
        <table class="detail-table">
            <thead>
                <tr>
                    <th>#</th><th>Ngày sử dụng</th><th>Sân</th><th>Khung giờ</th>
                    <th style="text-align:right;">Đơn giá</th>
                </tr>
            </thead>
            <tbody>
            <% if (details != null) { int i = 1; for (BookingDetail d : details) { %>
                <tr>
                    <td><%= i++ %></td>
                    <td><span class="badge-date"><%= d.getUsageDate() %></span></td>
                    <td><span class="badge-court"><%= d.getCourtName() %></span></td>
                    <td><span class="badge-slot"><%= d.getSlotStart() %> – <%= d.getSlotEnd() %></span></td>
                    <td style="text-align:right;font-weight:600;color:#1976d2;">
                        <%= String.format("%,.0f", d.getPricePerHour()) %> đ
                    </td>
                </tr>
            <% } } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="4" style="text-align:right;padding:12px 14px;">Tổng cộng:</td>
                    <td style="text-align:right;padding:12px 14px;color:#1976d2;"><%= String.format("%,d", totalAmount) %> đ</td>
                </tr>
            </tfoot>
        </table>
    </div>

    <!-- Nút hành động -->
    <div class="action-row">
        <a href="booking?action=selectCourt" class="btn btn-secondary">← Chọn lại</a>
        <form method="POST" action="booking" style="display:inline;" onsubmit="return confirm('Xác nhận lưu đơn đặt sân?')">
            <input type="hidden" name="action" value="saveBooking">
            <button type="submit" class="btn btn-success">✅ Xác nhận & Lưu</button>
        </form>
    </div>
</div>
</body>
</html>
