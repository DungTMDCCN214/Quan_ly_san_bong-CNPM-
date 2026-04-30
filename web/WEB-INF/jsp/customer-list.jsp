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
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Quản lý khách hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f6fa;
        }
        .card {
            border-radius: 8px;
        }
        .table th {
            background-color: #0d6efd;
            color: white;
        }
        .actions {
            min-width: 190px;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>Quan ly khach hang</h3>
            <div class="d-flex gap-2">
                <a href="court" class="btn btn-outline-secondary">Quản lý sân</a>
                <a href="customer?action=add" class="btn btn-success">Thêm khách hàng</a>
            </div>
        </div>

        <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success"><%= esc(message) %></div>
        <% } %>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger"><%= esc(error) %></div>
        <% } %>

        <form action="customer" method="get" class="row g-3 mb-4">
            <div class="col-md-5">
                <label class="form-label">Tìm theo họ tên hoặc số điện thoại</label>
                <input type="text" name="keyword" class="form-control"
                       value="<%= esc(keyword) %>" placeholder="Nhập họ tên hoặc số điện thoại">
            </div>
            <div class="col-md-2">
                <label class="form-label">Loại khách</label>
                <select name="customer_type" class="form-select">
                    <option value="ALL" <%= selected(customer_type, "ALL") %>>Tất cả</option>
                    <option value="NORMAL" <%= selected(customer_type, "NORMAL") %>>Thường</option>
                    <option value="VIP" <%= selected(customer_type, "VIP") %>>VIP</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label">Trạng thái</label>
                <select name="status" class="form-select">
                    <option value="ACTIVE" <%= selected(status, "ACTIVE") %>>Hoạt động</option>
                    <option value="INACTIVE" <%= selected(status, "INACTIVE") %>>Không hoạt động</option>
                    <option value="ALL" <%= selected(status, "ALL") %>>Tất cả</option>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">Tìm kiếm</button>
            </div>
        </form>

        <table class="table table-bordered table-hover align-middle">
            <thead>
                <tr class="text-center">
                    <th>ID</th>
                    <th>Họ tên</th>
                    <th>Số điện thoại</th>
                    <th>Dịa chỉ</th>
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
                            <span class="badge bg-warning text-dark">VIP</span>
                        <% } else { %>
                            <span class="badge bg-secondary">Thường</span>
                        <% } %>
                    </td>
                    <td class="text-center">
                        <% if ("ACTIVE".equals(customer.getStatus())) { %>
                            <span class="badge bg-success">Hoạt động</span>
                        <% } else { %>
                            <span class="badge bg-danger">Không hoạt động</span>
                        <% } %>
                    </td>
                    <td class="text-center">
                        <%= customer.getCreated_at() != null ? dateFormat.format(customer.getCreated_at()) : "" %>
                    </td>
                    <td>
                        <div class="d-flex gap-2 justify-content-center">
                            <a href="customer?action=edit&id=<%= customer.getCustomer_id() %>"
                               class="btn btn-primary btn-sm">Sửa</a>

                            <% if ("ACTIVE".equals(customer.getStatus())) { %>
                                <form action="customer" method="post"
                                      onsubmit="return confirm('Bạn có chắc muốn vô hiệu hóa khách hàng này?')">
                                    <input type="hidden" name="action" value="disable">
                                    <input type="hidden" name="id" value="<%= customer.getCustomer_id() %>">
                                    <button type="submit" class="btn btn-danger btn-sm">Vô hiệu hóa</button>
                                </form>
                            <% } else { %>
                                <form action="customer" method="post"
                                      onsubmit="return confirm('Bạn có chắc muốn khôi phục khách hàng này?')">
                                    <input type="hidden" name="action" value="restore">
                                    <input type="hidden" name="id" value="<%= customer.getCustomer_id() %>">
                                    <button type="submit" class="btn btn-success btn-sm">Khôi phục</button>
                                </form>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="8" class="text-center text-muted py-4">
                        Không tìm thấy khách hàng phù hợp.
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <div class="mt-3 text-muted">
            Tổng số khách hàng: <strong><%= list != null ? list.size() : 0 %></strong>
        </div>
    </div>
</div>
</body>
</html>

