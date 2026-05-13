<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setAttribute("currentPage", "booking-new");
    int bookingId = request.getAttribute("bookingId") != null ? (Integer) request.getAttribute("bookingId") : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt sân – Thành công</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content {
            margin-left: 260px; flex: 1; padding: 32px;
            display: flex; align-items: center; justify-content: center;
        }
        .card {
            background: #fff; border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.1);
            padding: 56px 48px; text-align: center; max-width: 500px; width: 100%;
            animation: fadeUp 0.5s ease;
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .icon-wrap {
            width: 88px; height: 88px; border-radius: 50%; margin: 0 auto 24px;
            background: linear-gradient(135deg, #43a047, #66bb6a);
            display: flex; align-items: center; justify-content: center;
            font-size: 2.4rem; box-shadow: 0 8px 24px rgba(67,160,71,0.3);
        }
        h2 { font-size: 1.5rem; color: #1a2332; margin-bottom: 8px; }
        .sub { color: #999; font-size: 0.9rem; margin-bottom: 32px; line-height: 1.6; }
        .booking-box {
            background: #f5f7fa; border-radius: 10px; padding: 16px 24px; margin-bottom: 32px;
        }
        .booking-box .lbl { color: #aaa; font-size: 0.8rem; margin-bottom: 4px; }
        .booking-box .id  { font-size: 1.9rem; font-weight: 700; color: #1976d2; }
        .btn-row { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
        .btn {
            padding: 12px 26px; border: none; border-radius: 10px;
            font-size: 0.92rem; font-weight: 700; cursor: pointer;
            transition: all 0.3s ease; text-decoration: none; display: inline-block;
        }
        .btn-primary   { background: #1976d2; color: #fff; }
        .btn-primary:hover   { background: #1565c0; transform: translateY(-1px); }
        .btn-secondary { background: #f0f0f0; color: #555; }
        .btn-secondary:hover { background: #e0e0e0; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">
    <div class="card">
        <div class="icon-wrap">✅</div>
        <h2>Đặt sân thành công!</h2>
        <p class="sub">Đơn đặt sân và hóa đơn đã được lưu vào hệ thống.<br>Hóa đơn trạng thái <strong>UNPAID</strong> — thu tiền khi khách đến sân.</p>
        <div class="booking-box">
            <div class="lbl">Mã đơn đặt sân</div>
            <div class="id">#<%= String.format("%05d", bookingId) %></div>
        </div>
        <div class="btn-row">
            <a href="booking?action=start" class="btn btn-primary">📅 Đặt sân mới</a>
            <a href="booking" class="btn btn-secondary">🏠 Trang đặt sân</a>
        </div>
    </div>
</div>
</body>
</html>
