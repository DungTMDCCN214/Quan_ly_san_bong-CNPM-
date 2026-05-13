<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.List"%>
<%@page import="model.Service"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String selected(String actual, String expected) {
        return expected.equals(actual) ? "selected" : "";
    }
%>

<%
    List<Service> list = (List<Service>) request.getAttribute("list");
    String keyword = (String) request.getAttribute("keyword");
    String status = (String) request.getAttribute("status");
    String message = request.getParameter("message");
    String error = (String) request.getAttribute("error");
    
    // Format tiền tệ VNĐ
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Quản lý Mặt hàng & Dịch vụ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f5f6fa; margin: 0; padding: 0; }
        .sidebar { width: 250px; position: fixed; top: 0; left: 0; height: 100vh; background-color: #212529; z-index: 100; overflow-y: auto; }
        .main-content { margin-left: 250px; padding: 20px; }
        .card { border-radius: 12px; border: none;}
        .table th { background-color: #0d6efd; color: white; vertical-align: middle; }
        .service-img { width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 1px solid #dee2e6; }
        .actions { min-width: 190px; }
        
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
        <div class="card shadow p-4">

            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <h3 class="mb-0"><i class="fas fa-box-open text-primary"></i> Danh mục Dịch vụ</h3>
                <a href="service?action=add" class="btn btn-success shadow-sm">
                    <i class="fas fa-plus-circle"></i> Thêm dịch vụ mới
                </a>
            </div>

            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fas fa-check-circle"></i> 
                    <% if ("add_success".equals(message)) { %> Thêm dịch vụ thành công! <% } %>
                    <% if ("update_success".equals(message)) { %> Cập nhật thông tin dịch vụ thành công! <% } %>
                    <% if ("delete_success".equals(message)) { %> Đã ngừng kinh doanh dịch vụ này! <% } %>
                    <% if ("restore_success".equals(message)) { %> Đã khôi phục trạng thái kinh doanh! <% } %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fas fa-exclamation-triangle"></i> 
                    <% if ("cannot_delete_unpaid_invoice".equals(error)) { %> Không thể ngừng kinh doanh vì dịch vụ này đang nằm trong hóa đơn chưa thanh toán của khách! <% } else { %> <%= esc(error) %> <% } %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <form action="service" method="get" class="row g-3 mb-4 bg-light p-3 rounded border">
                <input type="hidden" name="action" value="list">
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary"><i class="fas fa-search"></i> Tên dịch vụ</label>
                    <input type="text" name="keyword" class="form-control" value="<%= esc(keyword) %>" placeholder="Nhập tên mặt hàng, dịch vụ...">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary"><i class="fas fa-filter"></i> Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE" <%= selected(status, "ACTIVE") %>>Đang kinh doanh</option>
                        <option value="INACTIVE" <%= selected(status, "INACTIVE") %>>Đã ngừng bán</option>
                        <option value="ALL" <%= selected(status, "ALL") %>>Tất cả</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100 shadow-sm"><i class="fas fa-search"></i> Tìm kiếm</button>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <thead>
                        <tr class="text-center">
                            <th>ID</th>
                            <th>Hình ảnh</th>
                            <th class="text-start">Tên dịch vụ</th>
                            <th>Giá bán</th>
                            <th>Tồn kho</th>
                            <th>Trạng thái</th>
                            <th class="actions">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list != null && !list.isEmpty()) {
                            for (Service s : list) { %>
                        <tr class="text-center">
                            <td class="fw-bold text-secondary">#<%= s.getService_id() %></td>
                            <td>
                                <img src="<%= request.getContextPath() %>/assets/images/services/<%= esc(s.getImage_path()) %>" 
                                     class="service-img shadow-sm" alt="img"
                                     onerror="this.src='<%= request.getContextPath() %>/assets/images/services/default-service.png'">
                            </td>
                            <td class="text-start fw-bold"><%= esc(s.getName()) %></td>
                            <td class="text-danger fw-bold"><%= df.format(s.getPrice()) %> đ</td>
                            <td>
                                <% if (s.getStock_quantity() > 10) { %>
                                    <span class="badge bg-info text-dark"><%= s.getStock_quantity() %></span>
                                <% } else if (s.getStock_quantity() > 0) { %>
                                    <span class="badge bg-warning text-dark">Sắp hết (<%= s.getStock_quantity() %>)</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Hết hàng</span>
                                <% } %>
                            </td>
                            <td>
                                <% if ("ACTIVE".equals(s.getStatus())) { %>
                                    <span class="badge bg-success"><i class="fas fa-check-circle"></i> Đang bán</span>
                                <% } else { %>
                                    <span class="badge bg-secondary"><i class="fas fa-ban"></i> Ngừng bán</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="d-flex gap-2 justify-content-center">
                                    <a href="service?action=edit&id=<%= s.getService_id() %>" class="btn btn-outline-primary btn-sm">
                                        <i class="fas fa-edit"></i> Sửa
                                    </a>
                                    <% if ("ACTIVE".equals(s.getStatus())) { %>
                                        <button class="btn btn-outline-danger btn-sm" onclick="showDeleteModal(<%= s.getService_id() %>, '<%= esc(s.getName()) %>')">
                                            <i class="fas fa-trash"></i> Xóa
                                        </button>
                                    <% } else { %>
                                        <form action="service" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="restore">
                                            <input type="hidden" name="id" value="<%= s.getService_id() %>">
                                            <button type="submit" class="btn btn-outline-success btn-sm"><i class="fas fa-undo"></i> Bán lại</button>
                                        </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">
                                <i class="fas fa-box-open fa-3x mb-3 opacity-50"></i><br>
                                Không tìm thấy dịch vụ nào phù hợp.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="mt-3 text-muted">
                <i class="fas fa-chart-bar"></i> Tổng số: <strong><%= list != null ? list.size() : 0 %></strong> dịch vụ
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header bg-danger text-white">
        <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác nhận ngừng kinh doanh</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        Bạn có chắc chắn muốn ngừng kinh doanh dịch vụ <strong id="deleteServiceName" class="text-danger"></strong> không? <br>
        <small class="text-muted">Hệ thống sẽ giữ lại lịch sử giao dịch cũ để phục vụ kế toán.</small>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <form action="service" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" id="deleteServiceId" value="">
            <button type="submit" class="btn btn-danger">Đồng ý, ngừng kinh doanh</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showDeleteModal(id, name) {
        document.getElementById('deleteServiceId').value = id;
        document.getElementById('deleteServiceName').innerText = name;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    }
</script>

</body>
</html>