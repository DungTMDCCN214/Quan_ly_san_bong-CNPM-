<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="model.Customer"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String esc(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String selected(String actual, String expected) {
        return expected.equals(actual) ? "selected" : "";
    }
%>

<%
    List<Customer> list = (List<Customer>) request.getAttribute("list");
    String keyword = (String) request.getAttribute("keyword");
    String customer_type = (String) request.getAttribute("customer_type");
    String status = (String) request.getAttribute("status");

    String message = request.getParameter("message");
    String error = request.getParameter("error");

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Quản lý khách hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #f5f6fa;
            margin: 0;
            padding: 0;
        }

        /* Sidebar cố định bên trái */
        .sidebar {
            width: 250px;
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            background-color: #212529;
            z-index: 100;
            overflow-y: auto;
        }

        /* Nội dung chính lùi sang phải */
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }

        .card {
            border-radius: 12px;
        }

        .table th {
            background-color: #0d6efd;
            color: white;
        }

        .actions {
            min-width: 190px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>Quản lý khách hàng</h3>
            <div class="d-flex gap-2">
                <a href="court" class="btn btn-outline-secondary">Quản lý sân</a>
                <a href="customer?action=add" class="btn btn-success">Thêm khách hàng</a>
            </div>
        </div>

<!-- Sidebar cố định bên trái -->
<div class="sidebar">
    <jsp:include page="/WEB-INF/jsp/sidebar.jsp" />
</div>

<!-- Nội dung chính -->
<div class="main-content">
    <div class="container-fluid px-4">
        <div class="card shadow p-4">

            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap">
                <h3><i class="fas fa-users"></i> Quản lý khách hàng</h3>
                <div class="d-flex gap-2 mt-2 mt-sm-0">
                    <a href="court" class="btn btn-outline-secondary">
                        <i class="fas fa-futbol"></i> Quản lý sân
                    </a>
                    <a href="customer?action=add" class="btn btn-success">
                        <i class="fas fa-user-plus"></i> Thêm khách hàng
                    </a>
                </div>
            </div>

            <% if ("add_success".equals(message)) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle"></i>
                    Thêm khách hàng thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>

            <% } else if ("update_success".equals(message)) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle"></i>
                    Cập nhật khách hàng thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>

            <% } else if ("disable_success".equals(message)) { %>
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fas fa-ban"></i>
                    Vô hiệu hóa khách hàng thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>

            <% } else if ("restore_success".equals(message)) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-undo-alt"></i>
                    Khôi phục khách hàng thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>

            <% } %>
           <% if ("has_unpaid_invoice".equals(error)) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle"></i>
                    Không thể vô hiệu hóa khách hàng đang có hóa đơn chưa thanh toán.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <!-- Form tìm kiếm và lọc -->
            <form action="customer" method="get" class="row g-3 mb-4">
                <div class="col-md-5">
                    <label class="form-label fw-bold">
                        <i class="fas fa-search"></i> Tìm theo họ tên hoặc số điện thoại
                    </label>
                    <input type="text" name="keyword" class="form-control"
                           value="<%= esc(keyword) %>" placeholder="Nhập họ tên hoặc số điện thoại">
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-bold">
                        <i class="fas fa-tag"></i> Loại khách
                    </label>
                    <select name="customer_type" class="form-select">
                        <option value="ALL" <%= selected(customer_type, "ALL") %>>Tất cả</option>
                        <option value="NORMAL" <%= selected(customer_type, "NORMAL") %>>Thường</option>
                        <option value="VIP" <%= selected(customer_type, "VIP") %>>VIP</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-bold">
                        <i class="fas fa-circle-info"></i> Trạng thái
                    </label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE" <%= selected(status, "ACTIVE") %>>Hoạt động</option>
                        <option value="INACTIVE" <%= selected(status, "INACTIVE") %>>Không hoạt động</option>
                        <option value="ALL" <%= selected(status, "ALL") %>>Tất cả</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-filter"></i> Tìm kiếm
                    </button>
                </div>
            </form>

            <!-- Bảng hiển thị khách hàng -->
            <div class="table-responsive">
                <table class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr class="text-center">
                            <th>ID</th>
                            <th>Họ tên</th>
                            <th>Số điện thoại</th>
                            <th>Địa chỉ</th>
                            <th>Loại khách</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th class="actions">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list != null && !list.isEmpty()) {
                            for (Customer customer : list) {
                        %>
                        <tr>
                            <td class="text-center"><%= customer.getCustomer_id() %></td>
                            <td><%= esc(customer.getFull_name()) %></td>
                            <td><%= esc(customer.getPhone()) %></td>
                            <td><%= esc(customer.getAddress()) %></td>
                            <td class="text-center">
                                <% if ("VIP".equals(customer.getCustomer_type())) { %>
                                    <span class="badge bg-warning text-dark">
                                        <i class="fas fa-crown"></i> VIP
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-secondary">
                                        <i class="fas fa-user"></i> Thường
                                    </span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <% if ("ACTIVE".equals(customer.getStatus())) { %>
                                    <span class="badge bg-success">
                                        <i class="fas fa-check-circle"></i> Hoạt động
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-danger">
                                        <i class="fas fa-ban"></i> Không hoạt động
                                    </span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <%= customer.getCreated_at() != null ? dateFormat.format(customer.getCreated_at()) : "" %>
                            </td>
                            <td>
                                <div class="d-flex gap-2 justify-content-center">
                                    <a href="customer?action=edit&id=<%= customer.getCustomer_id() %>"
                                       class="btn btn-primary btn-sm">
                                        <i class="fas fa-edit"></i> Sửa
                                    </a>

                                    <% if ("ACTIVE".equals(customer.getStatus())) { %>
                                        <form action="customer" method="post"
                                              onsubmit="return confirm('Bạn có chắc muốn vô hiệu hóa khách hàng này?')">
                                            <input type="hidden" name="action" value="disable">
                                            <input type="hidden" name="id" value="<%= customer.getCustomer_id() %>">
                                            <button type="submit" class="btn btn-danger btn-sm">
                                                <i class="fas fa-ban"></i> Vô hiệu hóa
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <form action="customer" method="post"
                                              onsubmit="return confirm('Bạn có chắc muốn khôi phục khách hàng này?')">
                                            <input type="hidden" name="action" value="restore">
                                            <input type="hidden" name="id" value="<%= customer.getCustomer_id() %>">
                                            <button type="submit" class="btn btn-success btn-sm">
                                                <i class="fas fa-undo-alt"></i> Khôi phục
                                            </button>
                                        </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">
                                <i class="fas fa-database fa-2x mb-2 d-block"></i>
                                Không tìm thấy khách hàng phù hợp.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Footer hiển thị tổng số -->
            <div class="mt-3 text-muted d-flex justify-content-between align-items-center">
                <div>
                    <i class="fas fa-list"></i> Tổng số khách hàng: 
                    <strong><%= list != null ? list.size() : 0 %></strong>
                </div>
                <% if (keyword != null && !keyword.isEmpty() || 
                      (customer_type != null && !"ALL".equals(customer_type)) ||
                      (status != null && !"ALL".equals(status))) { %>
                    <div class="text-info">
                        <i class="fas fa-filter"></i> Đang áp dụng bộ lọc
                    </div>
                <% } %>
            </div>

        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>