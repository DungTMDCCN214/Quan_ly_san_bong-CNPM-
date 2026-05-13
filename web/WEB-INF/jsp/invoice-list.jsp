<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.List"%>
<%@page import="model.Invoice"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    List<Invoice> list = (List<Invoice>) request.getAttribute("list");
    String keyword = (String) request.getAttribute("keyword");
    String status = (String) request.getAttribute("status");
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Quản lý Hóa Đơn</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f5f6fa; }
        .sidebar { width: 260px; position: fixed; top: 0; left: 0; height: 100vh; background-color: #212529; z-index: 100; }
        .main-content { margin-left: 260px; padding: 20px; }
        .card { border-radius: 12px; border: none; }
    </style>
</head>
<body>

<div class="sidebar">
    <jsp:include page="/WEB-INF/jsp/sidebar.jsp" />
</div>

<div class="main-content">
    <div class="container-fluid mt-3">
        <div class="card shadow p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <h3 class="mb-0"><i class="fas fa-file-invoice-dollar text-primary"></i> Quản lý Hóa Đơn</h3>
                <a href="invoice?action=listUninvoiced" class="btn btn-success shadow-sm">
                    <i class="fas fa-plus-circle"></i> Lập hóa đơn mới
                </a>
            </div>

            <form action="invoice" method="get" class="row g-3 mb-4 bg-light p-3 rounded border">
                <input type="hidden" name="action" value="list">
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary"><i class="fas fa-search"></i> Khách hàng</label>
                    <input type="text" name="keyword" class="form-control" value="<%= keyword != null ? keyword : "" %>" placeholder="Nhập tên hoặc số điện thoại...">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary"><i class="fas fa-filter"></i> Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>Tất cả hóa đơn</option>
                        <option value="UNPAID" <%= "UNPAID".equals(status) ? "selected" : "" %>>Chưa thanh toán (Chờ thu)</option>
                        <option value="PAID" <%= "PAID".equals(status) ? "selected" : "" %>>Đã thanh toán (Hoàn tất)</option>
                        <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Đã hủy</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100 shadow-sm"><i class="fas fa-search"></i> Lọc dữ liệu</button>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <thead class="table-dark">
                        <tr class="text-center">
                            <th>Mã HĐ</th>
                            <th>Khách hàng</th>
                            <th>Số điện thoại</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th>Ngày lập</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list != null && !list.isEmpty()) { 
                            for (Invoice iv : list) {
                        %>
                            <tr class="text-center">
                                <td class="fw-bold text-secondary">INV-<%= iv.getInvoice_id() %></td>
                                <td class="text-start"><strong><%= iv.getCustomer_name() %></strong></td>
                                <td><%= iv.getCustomer_phone() %></td>
                                <td class="text-danger fw-bold"><%= df.format(iv.getNet_amount()) %> đ</td>
                                <td>
                                    <% if ("PAID".equals(iv.getStatus())) { %>
                                        <span class="badge bg-success"><i class="fas fa-check-circle"></i> Đã thanh toán</span>
                                    <% } else if ("UNPAID".equals(iv.getStatus())) { %>
                                        <span class="badge bg-warning text-dark"><i class="fas fa-clock"></i> Chưa thanh toán</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary"><i class="fas fa-ban"></i> Đã hủy</span>
                                    <% } %>
                                </td>
                                <td><%= iv.getCreated_date_str() %></td>
                                <td>
                                    <a href="invoice?action=detail&id=<%= iv.getInvoice_id() %>" class="btn btn-outline-primary btn-sm">
                                        <i class="fas fa-eye"></i> Chi tiết
                                    </a>
                                </td>
                            </tr>
                        <%  } 
                        } else { %>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fas fa-folder-open fa-3x mb-3 opacity-50"></i><br>
                                    Không tìm thấy hóa đơn nào trong hệ thống.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>