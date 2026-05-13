<%@page import="java.util.List"%>
<%@page import="model.Service"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>

<%
    // Lấy dữ liệu dịch vụ cần sửa từ Servlet đẩy sang
    Service service = (Service) request.getAttribute("service");
    if (service == null) {
        response.sendRedirect("service"); // Tránh lỗi nếu người dùng truy cập trực tiếp
        return;
    }
    List<String> errors = (List<String>) request.getAttribute("errors");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Cập nhật dịch vụ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f5f6fa; margin: 0; padding: 0; }
        .sidebar { width: 250px; position: fixed; top: 0; left: 0; height: 100vh; background-color: #212529; z-index: 100; overflow-y: auto; }
        .main-content { margin-left: 250px; padding: 20px; }
        .card { border-radius: 12px; border: none; }
        .current-img { width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 2px solid #dee2e6; }
        
        @media (max-width: 768px) {
            .sidebar { width: 100%; height: auto; position: relative; }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>

<div class="sidebar">
    <jsp:include page="/WEB-INF/jsp/sidebar.jsp" />
</div>

<div class="main-content">
    <div class="container-fluid px-2 px-md-4 mt-3">
        <div class="row justify-content-center">
            <div class="col-lg-8 col-xl-7">
                <div class="card shadow p-4 p-md-5">
                    
                    <div class="text-center mb-4">
                        <i class="fas fa-edit fa-3x text-primary mb-2"></i>
                        <h3 class="fw-bold">Cập Nhật Dịch Vụ</h3>
                        <p class="text-muted">Chỉnh sửa thông tin mặt hàng: <strong class="text-dark"><%= esc(service.getName()) %></strong></p>
                    </div>

                    <% if (errors != null && !errors.isEmpty()) { %>
                        <div class="alert alert-danger shadow-sm">
                            <h6 class="fw-bold"><i class="fas fa-exclamation-circle"></i> Vui lòng kiểm tra lại:</h6>
                            <ul class="mb-0">
                                <% for (String err : errors) { %>
                                    <li><%= esc(err) %></li>
                                <% } %>
                            </ul>
                        </div>
                    <% } %>

                    <form action="service" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="<%= service.getService_id() %>">

                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label fw-bold">Tên mặt hàng / Dịch vụ <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" value="<%= esc(service.getName()) %>" required maxlength="100">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" name="price" class="form-control" value="<%= (int)service.getPrice() %>" min="0" step="1000" required>
                                    <span class="input-group-text bg-light fw-bold">đ</span>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số lượng tồn kho <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fas fa-boxes"></i></span>
                                    <input type="number" name="stock_quantity" class="form-control" value="<%= service.getStock_quantity() %>" min="0" required>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label fw-bold">Hình ảnh hiện tại</label>
                                <div class="mb-2">
                                    <img src="<%= request.getContextPath() %>/assets/images/services/<%= esc(service.getImage_path()) %>" 
                                         class="current-img shadow-sm" alt="Hình ảnh"
                                         onerror="this.src='<%= request.getContextPath() %>/assets/images/services/default-service.png'">
                                </div>

                                <input type="hidden" name="old_image" value="<%= esc(service.getImage_path()) %>">

                                <label class="form-label fw-bold">Đổi hình ảnh mới <span class="text-muted fw-normal">(Bỏ trống nếu không muốn đổi)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fas fa-upload"></i></span>
                                    <input type="file" name="image_file" class="form-control" accept="image/*">
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label fw-bold">Mô tả thêm</label>
                                <textarea name="description" class="form-control" rows="3"><%= esc(service.getDescription()) %></textarea>
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="service" class="btn btn-outline-secondary px-4"><i class="fas fa-arrow-left"></i> Hủy & Quay lại</a>
                            <button type="submit" class="btn btn-primary px-4 fw-bold shadow-sm"><i class="fas fa-save"></i> Lưu thay đổi</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>