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
    Service service = (Service) request.getAttribute("service");
    if (service == null) {
        service = new Service(0, "", 0.0, 0, "ACTIVE", "", "default-service.png");
    }
    List<String> errors = (List<String>) request.getAttribute("errors");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Thêm mới dịch vụ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f5f6fa; margin: 0; padding: 0; }
        .sidebar { width: 250px; position: fixed; top: 0; left: 0; height: 100vh; background-color: #212529; z-index: 100; overflow-y: auto; }
        .main-content { margin-left: 250px; padding: 20px; }
        .card { border-radius: 12px; border: none; }
        
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
                        <i class="fas fa-box-open fa-3x text-primary mb-2"></i>
                        <h3 class="fw-bold">Thêm Dịch Vụ Mới</h3>
                        <p class="text-muted">Khai báo mặt hàng, nước uống hoặc dịch vụ cho thuê mới</p>
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
                        <input type="hidden" name="action" value="add">

                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label fw-bold">Tên mặt hàng / Dịch vụ <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" value="<%= esc(service.getName()) %>" 
                                       placeholder="VD: Nước khoáng Lavie 500ml, Thuê áo tập..." required maxlength="100">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" name="price" class="form-control" value="<%= service.getPrice() == 0 ? "" : (int)service.getPrice() %>" 
                                           min="0" step="1000" placeholder="VD: 15000" required>
                                    <span class="input-group-text bg-light fw-bold">đ</span>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số lượng tồn kho ban đầu <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fas fa-boxes"></i></span>
                                    <input type="number" name="stock_quantity" class="form-control" value="<%= service.getStock_quantity() %>" 
                                           min="0" required>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label fw-bold">Chọn hình ảnh tải lên <span class="text-muted fw-normal">(Không bắt buộc)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fas fa-upload"></i></span>
                                    <input type="file" name="image_file" class="form-control" accept="image/*">
                                </div>
                                <small class="text-muted">Định dạng hỗ trợ: JPG, PNG, JPEG. Nếu không chọn sẽ dùng ảnh mặc định.</small>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label fw-bold">Mô tả thêm</label>
                                <textarea name="description" class="form-control" rows="3" 
                                          placeholder="Ghi chú thêm về dịch vụ..."><%= esc(service.getDescription()) %></textarea>
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="service" class="btn btn-outline-secondary px-4"><i class="fas fa-arrow-left"></i> Quay lại</a>
                            <button type="submit" class="btn btn-success px-4 fw-bold shadow-sm"><i class="fas fa-save"></i> Hoàn tất thêm mới</button>
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