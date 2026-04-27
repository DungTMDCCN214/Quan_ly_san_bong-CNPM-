<%@page import="java.util.List"%>
<%@page import="model.Court"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    List<Court> list = (List<Court>) request.getAttribute("list");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Quản lý sân</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f6fa;
        }
        .card {
            border-radius: 12px;
        }
        .table th {
            background-color: #0d6efd;
            color: white;
        }
        .badge-available {
            background-color: #198754;
        }
        .badge-maintenance {
            background-color: #ffc107;
            color: #000;
        }
    </style>
</head>

<body>

<div class="container mt-5">

    <div class="card shadow p-4">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>🏟️ Quản lý sân</h3>
            <a href="court?action=add" class="btn btn-success">
                ➕ Thêm sân
            </a>
        </div>

        <!-- Table -->
        <table class="table table-bordered table-hover text-center align-middle">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên sân</th>
                    <th>Loại sân</th>           <!-- Thêm cột Loại sân -->
                    <th>Giá / giờ</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>

            <tbody>
                <%
                    if (list != null && !list.isEmpty()) {
                        for (Court c : list) {
                %>
                <tr>
                    <td><%= c.getCourt_id() %></td>
                    <td><%= c.getName() %></td>
                    <td>
                        <%= (c.getType() != null && !c.getType().isEmpty()) ? c.getType() : "Chưa phân loại" %>
                    </td>
                    <td><%= String.format("%,.0f", c.getPrice_per_hour()) %> VNĐ</td>
                    <td>
                        <% if ("AVAILABLE".equals(c.getStatus())) { %>
                            <span class="badge bg-success">✅ Hoạt động</span>
                        <% } else if ("MAINTENANCE".equals(c.getStatus())) { %>
                            <span class="badge bg-warning text-dark">🔧 Bảo trì</span>
                        <% } else { %>
                            <span class="badge bg-secondary"><%= c.getStatus() %></span>
                        <% } %>
                    </td>
                    <td>
                        <a href="court?action=edit&id=<%= c.getCourt_id() %>" 
                           class="btn btn-primary btn-sm">✏️ Sửa</a>

                        <a href="court?action=delete&id=<%= c.getCourt_id() %>" 
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Bạn có chắc chắn muốn xóa sân <%= c.getName() %> không?')">
                           🗑️ Xóa
                        </a>
                    </td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="6" class="text-center text-muted py-4">
                        📭 Chưa có sân nào. Hãy <a href="court?action=add">thêm sân mới</a>
                    </td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <!-- Footer: Hiển thị tổng số sân -->
        <div class="mt-3 text-muted">
            Tổng số sân: <strong><%= (list != null) ? list.size() : 0 %></strong>
        </div>

    </div>

</div>

</body>
</html>