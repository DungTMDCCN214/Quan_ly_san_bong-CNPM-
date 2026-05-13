<%-- 
    Document   : edit-court
    Created on : Mar 23, 2026, 10:58:44 AM
    Author     : Admin
--%>

<%@page import="model.Court"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    Court c = (Court) request.getAttribute("court");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Sửa sân</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f6fa;
        }
        .card {
            border-radius: 12px;
        }
    </style>
</head>

<body>

<div class="container mt-5">

    <div class="row justify-content-center">
        <div class="col-md-6">

            <div class="card shadow p-4">

                <!-- Title -->
                <h3 class="text-center mb-4">✏️ Sửa sân</h3>

                <!-- Form -->
                <form action="court" method="post">

                    <!-- Hidden -->
                    <input type="hidden" name="id" value="<%= c.getCourt_id() %>">
                    <input type="hidden" name="action" value="update">

                    <!-- Name -->
                    <div class="mb-3">
                        <label class="form-label">Tên sân <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control"
                               value="<%= c.getName() %>" required>
                    </div>

                    <!-- Type (Loại sân) - THÊM MỚI -->
                    <div class="mb-3">
                        <label class="form-label">Loại sân <span class="text-danger">*</span></label>
                        <select name="type" class="form-select" required>
                            <option value="">Chọn loại sân</option>
                            <option value="Sân 5 người" <%= "Sân 5 người".equals(c.getType()) ? "selected" : "" %>>
                                Sân 5 người
                            </option>
                            <option value="Sân 7 người" <%= "Sân 7 người".equals(c.getType()) ? "selected" : "" %>>
                                Sân 7 người
                            </option>
                            
                        </select>
                    </div>

                    <!-- Price -->
                    <div class="mb-3">
                        <label class="form-label">Giá / giờ (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" name="price" class="form-control"
                               value="<%= c.getPrice_per_hour() %>" required min="0" step="1000">
                    </div>

                    <!-- Status -->
                    <div class="mb-3">
                        <label class="form-label">Trạng thái</label>
                        <select name="status" class="form-select">
                            <option value="AVAILABLE" <%= "AVAILABLE".equals(c.getStatus()) ? "selected" : "" %>>
                                🟢 Trống
                            </option>
                            <option value="IN_USE" <%= "IN_USE".equals(c.getStatus()) ? "selected" : "" %>>
                                🔴 Đang sử dụng
                            </option>
                            <option value="MAINTENANCE" <%= "MAINTENANCE".equals(c.getStatus()) ? "selected" : "" %>>
                                🔧 Bảo trì
                            </option>
                        </select>

                        <div class="form-text">
                            Trạng thái hiện tại:
                            <strong>
                                <%= 
                                    "AVAILABLE".equals(c.getStatus()) ? "Trống" :
                                    "IN_USE".equals(c.getStatus()) ? "Đang sử dụng" :
                                    "Bảo trì"
                                %>
                            </strong>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea name="description" class="form-control" rows="3" 
                                  placeholder="Mô tả sân (diện tích, ánh sáng, chất lượng mặt sân...)"><%= c.getDescription() != null ? c.getDescription() : "" %></textarea>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex justify-content-between">
                        <a href="court" class="btn btn-secondary">⬅ Quay lại</a>
                        <button type="submit" class="btn btn-primary">💾 Cập nhật</button>
                    </div>

                </form>

                <!-- Hiển thị thông tin created_at (chỉ đọc) -->
                <% if (c.getCreated_at() != null) { %>
                <div class="mt-3 text-center text-muted small">
                    <hr>
                    Ngày tạo: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(c.getCreated_at()) %>
                </div>
                <% } %>

            </div>

        </div>
    </div>

</div>

</body>
</html>