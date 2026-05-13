<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Customer"%>
<%
    request.setAttribute("currentPage", "booking-new");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    String phone = (String) request.getAttribute("phone");
    if (phone == null) phone = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt sân – Tra cứu khách hàng</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; display: flex; min-height: 100vh; }
        .main-content { margin-left: 260px; flex: 1; padding: 32px; }

        /* Steps */
        .steps-bar {
            display: flex; align-items: center; gap: 6px;
            background: #fff; padding: 16px 24px; border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06); margin-bottom: 28px;
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
        .step-label { font-size: 0.85rem; color: #555; }
        .step.active .step-label { color: #1976d2; font-weight: 600; }
        .step.done   .step-label { color: #43a047; }
        .step-divider { flex: 1; height: 2px; background: #e0e0e0; border-radius: 2px; max-width: 60px; }

        /* Card */
        .card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07); padding: 32px;
        }
        .card-title { font-size: 1.15rem; font-weight: 700; color: #1a2332; margin-bottom: 6px; }
        .card-sub   { color: #999; font-size: 0.87rem; margin-bottom: 24px; }

        /* Search */
        .search-form { display: flex; gap: 12px; margin-bottom: 32px; }
        .search-form input {
            flex: 1; padding: 12px 16px; border: 1.5px solid #ddd; border-radius: 10px;
            font-size: 0.95rem; transition: all 0.3s ease; outline: none;
        }
        .search-form input:focus { border-color: #1976d2; box-shadow: 0 0 0 3px rgba(25,118,210,0.1); }
        .btn {
            padding: 12px 24px; border: none; border-radius: 10px;
            font-size: 0.92rem; font-weight: 600; cursor: pointer; transition: all 0.3s ease;
        }
        .btn-primary { background: #1976d2; color: #fff; }
        .btn-primary:hover { background: #1565c0; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(25,118,210,0.3); }

        /* Table */
        table { width: 100%; border-collapse: collapse; }
        thead th {
            background: #f5f7fa; padding: 11px 16px; text-align: left;
            font-size: 0.78rem; color: #777; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.4px; border-bottom: 2px solid #eee;
        }
        tbody td { padding: 13px 16px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #333; }
        tbody tr:hover td { background: #f8fbff; }

        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.76rem; font-weight: 700;
        }
        .badge-vip    { background: #fff3e0; color: #e65100; }
        .badge-normal { background: #e8f5e9; color: #2e7d32; }

        .btn-choose {
            padding: 7px 18px; border-radius: 8px; font-size: 0.83rem;
            font-weight: 600; border: none; cursor: pointer;
            background: #1976d2; color: #fff; transition: all 0.3s ease;
        }
        .btn-choose:hover { background: #1565c0; transform: translateY(-1px); }

        .no-result { text-align: center; padding: 56px 0; color: #bbb; }
        .no-result .icon { font-size: 3rem; display: block; margin-bottom: 14px; }

        .result-count { color: #555; font-size: 0.88rem; margin-bottom: 14px; }
        .result-count strong { color: #1976d2; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <div class="steps-bar">
        <div class="step active"><div class="step-num">1</div><div class="step-label">Tra cứu khách hàng</div></div>
        <div class="step-divider"></div>
        <div class="step idle"><div class="step-num">2</div><div class="step-label">Chọn sân & Khung giờ</div></div>
        <div class="step-divider"></div>
        <div class="step idle"><div class="step-num">3</div><div class="step-label">Xác nhận & Lưu</div></div>
    </div>

    <div class="card">
        <div class="card-title">🔍 Tra cứu khách hàng</div>
        <div class="card-sub">Nhập số điện thoại để tìm kiếm khách hàng</div>

        <form class="search-form" method="GET" action="booking">
            <input type="hidden" name="action" value="searchCustomer">
            <input type="text" name="phone" placeholder="Nhập số điện thoại..."
                   value="<%= phone %>" maxlength="15" autofocus>
            <button type="submit" class="btn btn-primary">🔍 Tìm kiếm</button>
        </form>

        <% if (customers != null) { %>
            <% if (customers.isEmpty()) { %>
                <div class="no-result">
                    <span class="icon">😕</span>
                    Không tìm thấy khách hàng với SĐT "<strong><%= phone %></strong>"
                </div>
            <% } else { %>
                <p class="result-count">Tìm thấy <strong><%= customers.size() %></strong> khách hàng — Chọn đúng khách để tiếp tục</p>
                <form method="POST" action="booking" id="chooseForm">
                    <input type="hidden" name="action" value="chooseCustomer">
                    <input type="hidden" name="customerId" id="hiddenCustomerId" value="">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th><th>Họ tên</th><th>Số điện thoại</th>
                                <th>Loại KH</th><th>Địa chỉ</th><th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% int i = 1; for (Customer c : customers) { %>
                            <tr>
                                <td><%= i++ %></td>
                                <%-- Sửa: getFullName -> getFull_name --%>
                                <td><strong><%= c.getFull_name() %></strong></td>
                                <%-- Sửa: getPhone (khớp sẵn) --%>
                                <td>📞 <%= c.getPhone() %></td>
                                <td>
                                    <%-- Sửa: getCustomerType -> getCustomer_type --%>
                                    <span class="badge <%= "VIP".equals(c.getCustomer_type()) ? "badge-vip" : "badge-normal" %>">
                                        <%= c.getCustomer_type() %>
                                    </span>
                                </td>
                                <%-- Sửa: getAddress (khớp sẵn) --%>
                                <td><%= c.getAddress() != null ? c.getAddress() : "—" %></td>
                                <td>
                                    <%-- Sửa: getCustomerId -> getCustomer_id --%>
                                    <button type="button" class="btn-choose"
                                            onclick="choose(<%= c.getCustomer_id() %>)">
                                        ✔ Chọn
                                    </button>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </form>
            <% } %>
        <% } %>
    </div>
</div>

<script>
    function choose(id) {
        document.getElementById('hiddenCustomerId').value = id;
        document.getElementById('chooseForm').submit();
    }
</script>
</body>
</html>
