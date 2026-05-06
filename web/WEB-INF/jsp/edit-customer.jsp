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
    Customer customer = (Customer) request.getAttribute("customer");
    List<String> errors = (List<String>) request.getAttribute("errors");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Sửa khách hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f6fa;
        }
        .card {
            border-radius: 8px;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card shadow p-4">
                <h3 class="text-center mb-4">Sửa khách hàng</h3>

                <% if (errors != null && !errors.isEmpty()) { %>
                    <div class="alert alert-danger">
                        <ul class="mb-0">
                            <% for (String error : errors) { %>
                                <li><%= esc(error) %></li>
                            <% } %>
                        </ul>
                    </div>
                <% } %>

                <% if (customer != null) { %>
                <form action="customer" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= customer.getCustomer_id() %>">

                    <div class="mb-3">
                        <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" name="full_name" class="form-control"
                               value="<%= esc(customer.getFull_name()) %>" required maxlength="100">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                        <input type="text" name="phone" class="form-control"
                               value="<%= esc(customer.getPhone()) %>" required maxlength="15">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Địa chỉ</label>
                        <textarea name="address" class="form-control" rows="3"><%= esc(customer.getAddress()) %></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Loại khách</label>
                        <select name="customer_type" class="form-select">
                            <option value="NORMAL" <%= selected(customer.getCustomer_type(), "NORMAL") %>>Thường</option>
                            <option value="VIP" <%= selected(customer.getCustomer_type(), "VIP") %>>VIP</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Trạng thái</label>
                        <div>
                            <% if ("ACTIVE".equals(customer.getStatus())) { %>
                                <span class="badge bg-success">Hoạt động</span>
                            <% } else { %>
                                <span class="badge bg-danger">Không hoạt động</span>
                            <% } %>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between">
                        <a href="customer" class="btn btn-secondary">Quay lại</a>
                        <button type="submit" class="btn btn-primary">Cập nhật</button>
                    </div>
                </form>

                <% if (customer.getCreated_at() != null) { %>
                    <div class="mt-3 text-center text-muted small">
                        <hr>
                        Ngày tạo: <%= dateFormat.format(customer.getCreated_at()) %>
                    </div>
                <% } %>
                <% } else { %>
                    <div class="alert alert-danger">Không tìm thấy khách hàng.</div>
                    <a href="customer" class="btn btn-secondary">Quay lại</a>
                <% } %>
            </div>
        </div>
    </div>
</div>
</body>
</html>

