<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Lấy dữ liệu từ Servlet đẩy sang (Bây giờ là List chứa các Map)
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("list");
    String error = request.getParameter("error");
    
    // Lấy từ khóa để giữ lại trên thanh tìm kiếm
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Tạo hóa đơn mới</title>
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
                <h3 class="mb-0"><i class="fas fa-file-invoice-dollar text-primary"></i> Chọn buổi thuê để tạo hóa đơn</h3>
                <a href="invoice?action=list" class="btn btn-outline-secondary shadow-sm">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <form action="invoice" method="get" class="row g-2 mb-4">
                <input type="hidden" name="action" value="listUninvoiced">
                <div class="col-md-5">
                    <input type="text" name="keyword" class="form-control" value="<%= keyword %>" placeholder="Tìm theo tên khách hoặc SĐT...">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm kiếm</button>
                </div>
            </form>

            <% if ("create_failed".equals(error)) { %>
                <div class="alert alert-danger">Có lỗi xảy ra khi khởi tạo hóa đơn. Vui lòng thử lại.</div>
            <% } %>

            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <thead class="table-primary">
                        <tr class="text-center">
                            <th>Khách hàng</th>
                            <th>Sân bóng</th>
                            <th>Ngày sử dụng</th>
                            <th>Khung giờ</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list != null && !list.isEmpty()) { 
                            for (Map<String, Object> b : list) {
                        %>
                            <tr class="text-center align-middle">
                                <td class="text-start">
                                    <strong><%= b.get("customerName") %></strong><br>
                                    <small class="text-muted"><i class="fas fa-phone-alt"></i> <%= b.get("customerPhone") %></small>
                                </td>
                                <td><span class="badge bg-secondary"><%= b.get("courtName") %></span></td>
                                <td><%= b.get("usageDate") %></td>
                                <td class="fw-bold text-primary"><%= b.get("slotTime") %></td>
                                <td>
                                    <% if ("FINISHED".equals(b.get("detailStatus"))) { %>
                                        <span class="badge bg-success">Đã trả sân</span>
                                    <% } else { %>
                                        <span class="badge bg-warning text-dark">Đang chơi</span>
                                    <% } %>
                                </td>
                                <td>
                                    <form action="invoice" method="post" onsubmit="return confirm('Xác nhận tạo hóa đơn cho trận đấu này?')">
                                        <input type="hidden" name="action" value="create">
                                        <input type="hidden" name="bookingDetailId" value="<%= b.get("bookingDetailId") %>">
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="fas fa-plus"></i> Tạo hóa đơn
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <%  } 
                        } else { %>
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">
                                    <i class="fas fa-search fa-2x mb-2 opacity-50"></i><br>
                                    Không tìm thấy buổi thuê nào cần tạo hóa đơn hoặc khớp với từ khóa.
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