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
    
    <!-- Font Awesome Icons -->
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
        }

        /* Nội dung chính */
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

        .search-filters {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .filter-input {
            border-radius: 8px;
        }

        .btn-clear {
            border-radius: 8px;
        }

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

<!-- Sidebar cố định bên trái -->
<div class="sidebar">
    <jsp:include page="/WEB-INF/jsp/sidebar.jsp" />
</div>

<!-- Nội dung chính -->
<div class="main-content">
    <div class="container-fluid px-4">
        <div class="card shadow p-4">

            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap">
                <h3><i class="fas fa-futbol"></i> 🏟️ Quản lý sân</h3>
                <div class="d-flex gap-2 mt-2 mt-sm-0">
                    <a href="customer" class="btn btn-outline-secondary">
                        <i class="fas fa-users"></i> Quản lý khách hàng
                    </a>
                    <a href="court?action=add" class="btn btn-success">
                        <i class="fas fa-plus"></i> Thêm sân
                    </a>
                </div>
            </div>

            <!-- Thanh tìm kiếm và bộ lọc -->
            <div class="search-filters">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-bold"><i class="fas fa-search"></i> Tìm kiếm</label>
                        <input type="text" id="searchInput" class="form-control filter-input" 
                               placeholder="Nhập tên sân..." autocomplete="off">
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold"><i class="fas fa-tag"></i> Loại sân</label>
                        <select id="typeFilter" class="form-select filter-input">
                            <option value="">Tất cả</option>
                            <option value="Sân 5 người">Sân 5 người</option>
                            <option value="Sân 7 người">Sân 7 người</option>
                            <option value="Sân 11 người">Sân 11 người</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold">
                            <i class="fas fa-chart-line"></i> Trạng thái
                        </label>
                        <select id="statusFilter" class="form-select filter-input">
                            <option value="">Tất cả</option>
                            <option value="AVAILABLE">🟢 Trống</option>
                            <option value="IN_USE">🔴 Đang sử dụng</option>
                            <option value="MAINTENANCE">🔧 Bảo trì</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold"><i class="fas fa-dollar-sign"></i> Giá tối thiểu</label>
                        <input type="number" id="minPrice" class="form-control filter-input" 
                               placeholder="0" autocomplete="off">
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold"><i class="fas fa-dollar-sign"></i> Giá tối đa</label>
                        <input type="number" id="maxPrice" class="form-control filter-input" 
                               placeholder="Không giới hạn" autocomplete="off">
                    </div>
                    
                    <div class="col-md-1 d-flex align-items-end">
                        <button id="clearFilters" class="btn btn-secondary w-100 btn-clear">
                            <i class="fas fa-eraser"></i> Xóa
                        </button>
                    </div>
                </div>
            </div>

            <!-- Table -->
            <div class="table-responsive">
                <table class="table table-bordered table-hover text-center align-middle" id="courtTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên sân</th>
                            <th>Loại sân</th>
                            <th>Giá / giờ</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    
                    <tbody id="courtTableBody">
                        <%
                            if (list != null && !list.isEmpty()) {
                                for (Court c : list) {
                        %>
                        <tr data-name="<%= c.getName().toLowerCase() %>" 
                            data-type="<%= (c.getType() != null ? c.getType() : "Chưa phân loại") %>"
                            data-status="<%= c.getStatus() %>"
                            data-price="<%= c.getPrice_per_hour() %>">
                            <td><%= c.getCourt_id() %></td>
                            <td><%= c.getName() %></td>
                            <td><%= (c.getType() != null && !c.getType().isEmpty()) ? c.getType() : "Chưa phân loại" %></td>
                            <td><%= String.format("%,.0f", c.getPrice_per_hour()) %> VNĐ</td>
                            <td>
                                <% if ("AVAILABLE".equals(c.getStatus())) { %>
                                    <span class="badge bg-success">
                                        <i class="fas fa-check-circle"></i> Trống
                                    </span>
                                <% } else if ("IN_USE".equals(c.getStatus())) { %>
                                    <span class="badge bg-danger">
                                        <i class="fas fa-user"></i> Đang sử dụng
                                    </span>
                                <% } else if ("MAINTENANCE".equals(c.getStatus())) { %>
                                    <span class="badge bg-warning text-dark">
                                        <i class="fas fa-tools"></i> Bảo trì
                                    </span>
                                <% } else { %>
                                    <span class="badge bg-secondary"><%= c.getStatus() %></span>
                                <% } %>
                            </td>
                            <td>
                                <a href="court?action=edit&id=<%= c.getCourt_id() %>" 
                                   class="btn btn-primary btn-sm">
                                   <i class="fas fa-edit"></i> Sửa
                                </a>
                                <a href="court?action=delete&id=<%= c.getCourt_id() %>" 
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa sân <%= c.getName() %> không?')">
                                   <i class="fas fa-trash"></i> Xóa
                                </a>
                             </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr class="no-data-row">
                            <td colspan="6" class="text-center text-muted py-4">
                                <i class="fas fa-database"></i> 📭 Chưa có sân nào. Hãy <a href="court?action=add">thêm sân mới</a>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- Footer: Hiển thị tổng số sân -->
            <div class="mt-3 text-muted d-flex justify-content-between align-items-center">
                <div>
                    <i class="fas fa-list"></i> Tổng số sân: <strong id="totalCount"><%= (list != null) ? list.size() : 0 %></strong>
                </div>
                <div id="filterResult" class="text-info"></div>
            </div>

        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- JavaScript lọc dữ liệu -->
<script>
    function filterTable() {
        const searchText = document.getElementById('searchInput').value.toLowerCase().trim();
        const typeFilter = document.getElementById('typeFilter').value;
        const statusFilter = document.getElementById('statusFilter').value;
        const minPrice = parseFloat(document.getElementById('minPrice').value) || 0;
        const maxPrice = parseFloat(document.getElementById('maxPrice').value) || Infinity;
        
        const rows = document.querySelectorAll('#courtTableBody tr:not(.no-data-row)');
        let visibleCount = 0;
        
        rows.forEach(row => {
            const name = row.getAttribute('data-name') || '';
            const type = row.getAttribute('data-type') || '';
            const status = row.getAttribute('data-status') || '';
            const price = parseFloat(row.getAttribute('data-price')) || 0;
            
            let match = true;
            
            // Lọc theo tên
            if (searchText && !name.includes(searchText)) {
                match = false;
            }
            
            // Lọc theo loại sân
            if (match && typeFilter && type !== typeFilter) {
                match = false;
            }
            
            // Lọc theo trạng thái
            if (match && statusFilter && status !== statusFilter) {
                match = false;
            }
            
            // Lọc theo khoảng giá
            if (match && (price < minPrice || price > maxPrice)) {
                match = false;
            }
            
            if (match) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        // Cập nhật số lượng hiển thị
        document.getElementById('totalCount').innerText = visibleCount;
        
        // Hiển thị thông báo nếu không có kết quả
        const filterResult = document.getElementById('filterResult');
        if (visibleCount === 0) {
            filterResult.innerHTML = '<i class="fas fa-info-circle"></i> Không tìm thấy sân nào phù hợp';
            filterResult.style.color = '#dc3545';
        } else {
            filterResult.innerHTML = `<i class="fas fa-chart-simple"></i> Đang hiển thị ${visibleCount} sân`;
            filterResult.style.color = '#0d6efd';
        }
    }
    
    // Hàm xóa tất cả bộ lọc
    function clearFilters() {
        document.getElementById('searchInput').value = '';
        document.getElementById('typeFilter').value = '';
        document.getElementById('statusFilter').value = '';
        document.getElementById('minPrice').value = '';
        document.getElementById('maxPrice').value = '';
        filterTable();
    }
    
    // Gắn sự kiện cho các ô input/select
    document.getElementById('searchInput').addEventListener('input', filterTable);
    document.getElementById('typeFilter').addEventListener('change', filterTable);
    document.getElementById('statusFilter').addEventListener('change', filterTable);
    document.getElementById('minPrice').addEventListener('input', filterTable);
    document.getElementById('maxPrice').addEventListener('input', filterTable);
    document.getElementById('clearFilters').addEventListener('click', clearFilters);
    
    // Thực hiện lọc ban đầu (để cập nhật số lượng nếu có filter mặc định)
    filterTable();
</script>

</body>
</html>