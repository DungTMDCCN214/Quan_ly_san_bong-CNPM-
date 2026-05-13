<%@page import="model.Service"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="model.InvoiceDetail"%>
<%@page import="model.BookingDetail"%>
<%@page import="java.util.List"%>
<%@page import="model.Invoice"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Invoice inv = (Invoice) request.getAttribute("inv");
    List<BookingDetail> courtDetails = (List<BookingDetail>) request.getAttribute("courtDetails");
    List<InvoiceDetail> serviceDetails = (List<InvoiceDetail>) request.getAttribute("serviceDetails");
    List<Service> availableServices = (List<Service>) request.getAttribute("availableServices");
    DecimalFormat df = new DecimalFormat("#,###");
    
    // Lấy thông báo lỗi/thành công từ Servlet gửi sang
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết hóa đơn INV-<%= inv.getInvoice_id() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .sidebar { width: 260px; position: fixed; top: 0; left: 0; height: 100vh; background-color: #212529; z-index: 100; }
        .main-content { margin-left: 260px; padding: 20px; }
        .invoice-box { background: #fff; padding: 30px; border-radius: 15px; box-shadow: 0 0 20px rgba(0,0,0,0.05); }
        .section-title { border-left: 4px solid #0d6efd; padding-left: 10px; margin: 20px 0; font-weight: bold; text-transform: uppercase; }
        .service-img { width: 45px; height: 45px; object-fit: cover; border-radius: 8px; }
        
        /* Custom scrollbar cho bảng modal */
        .table-responsive::-webkit-scrollbar { width: 6px; }
        .table-responsive::-webkit-scrollbar-thumb { background-color: #ccc; border-radius: 4px; }
    </style>
</head>
<body>
<div class="sidebar"><jsp:include page="/WEB-INF/jsp/sidebar.jsp" /></div>
<div class="main-content">
    <div class="container-fluid">
        
        <% if ("invalid_qty".equals(error) || "out_of_stock".equals(error)) { %>
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="fas fa-exclamation-triangle"></i> Lỗi: Số lượng tồn kho không hợp lệ hoặc không đủ đáp ứng!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } else if ("update_success".equals(msg) || "add_svc_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> Cập nhật dịch vụ thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="invoice-box">
            <div class="d-flex justify-content-between align-items-center border-bottom pb-3">
                <div>
                    <h2 class="text-primary fw-bold mb-1">HÓA ĐƠN #<%= inv.getInvoice_id() %></h2>
                    <span class="badge <%= "PAID".equals(inv.getStatus()) ? "bg-success" : "bg-warning text-dark" %> fs-6">
                        <i class="fas <%= "PAID".equals(inv.getStatus()) ? "fa-check-circle" : "fa-clock" %>"></i> 
                        <%= "PAID".equals(inv.getStatus()) ? "Đã thanh toán" : "Chưa thanh toán" %>
                    </span>
                </div>
                <div class="text-end">
                    <h5 class="fw-bold mb-1"><i class="fas fa-user-circle text-secondary"></i> <%= inv.getCustomer_name() %></h5>
                    <p class="text-muted mb-2"><i class="fas fa-phone-alt"></i> <%= inv.getCustomer_phone() %></p>
                    <a href="invoice?action=list" class="btn btn-sm btn-outline-secondary"><i class="fas fa-arrow-left"></i> Quay lại</a>
                </div>
            </div>

            <div class="section-title mt-4">1. Tiền thuê sân bóng</div>
            <div class="table-responsive mb-4">
                <table class="table table-sm table-bordered">
                    <thead class="table-light text-center">
                        <tr><th>Tên sân</th><th>Ngày sử dụng</th><th>Khung giờ</th><th class="text-end">Đơn giá/giờ</th></tr>
                    </thead>
                    <tbody class="text-center align-middle">
                        <% double tCourt = 0; for(BookingDetail bd : courtDetails) { tCourt+=bd.getPricePerHour(); %>
                        <tr>
                            <td class="fw-bold text-secondary"><%= bd.getCourtName() %></td>
                            <td><%= bd.getUsageDate() %></td>
                            <td><span class="badge bg-light text-dark border"><%= bd.getSlotStart() %> - <%= bd.getSlotEnd() %></span></td>
                            <td class="text-end"><%= df.format(bd.getPricePerHour()) %> đ</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="section-title m-0">2. Dịch vụ phát sinh</div>
                <% if("UNPAID".equals(inv.getStatus())) { %>
                    <button class="btn btn-sm btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#addSvc">
                        <i class="fas fa-cart-plus"></i> Thêm dịch vụ
                    </button>
                <% } %>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle">
                    <thead class="table-light text-center">
                        <tr><th>Dịch vụ</th><th width="150">Số lượng (SL)</th><th>Đơn giá (Chốt)</th><th>Thành tiền</th><th>#</th></tr>
                    </thead>
                    <tbody>
                        <% if(serviceDetails.isEmpty()) { %> 
                            <tr><td colspan="5" class="text-center text-muted py-3 fst-italic">Khách hàng chưa gọi dịch vụ nào.</td></tr> 
                        <% } else {
                            for(InvoiceDetail sd : serviceDetails) { %>
                        <tr>
                            <td>
                                <div class="d-flex align-items-center ms-2">
                                    <img src="assets/images/services/<%= sd.getService_image() %>" class="service-img me-3" onerror="this.src='assets/images/services/default-service.png'">
                                    <span class="fw-bold text-dark"><%= sd.getService_name() %></span>
                                </div>
                            </td>
                            <td class="text-center">
                                <% if("UNPAID".equals(inv.getStatus())) { %>
                                <form action="invoice" method="post" class="d-flex justify-content-center">
                                    <input type="hidden" name="action" value="updateService">
                                    <input type="hidden" name="detailId" value="<%= sd.getId() %>">
                                    <input type="hidden" name="invoiceId" value="<%= inv.getInvoice_id() %>">
                                    <div class="input-group input-group-sm" style="width: 110px;">
                                        <input type="number" name="quantity" class="form-control text-center fw-bold" 
                                               value="<%= sd.getQuantity() %>" min="0" onchange="this.form.submit()">
                                    </div>
                                </form>
                                <% } else { %>
                                    <span class="fw-bold"><%= sd.getQuantity() %></span>
                                <% } %>
                            </td>
                            <td class="text-end text-muted"><%= df.format(sd.getUnit_price()) %> đ</td>
                            <td class="text-end fw-bold text-primary"><%= df.format(sd.getQuantity() * sd.getUnit_price()) %> đ</td>
                            <td class="text-center">
                                <% if("UNPAID".equals(inv.getStatus())) { %>
                                <form action="invoice" method="post" style="display:inline" onsubmit="return confirm('Xác nhận xóa mặt hàng này khỏi hóa đơn và hoàn lại số lượng vào kho?')">
                                    <input type="hidden" name="action" value="deleteService">
                                    <input type="hidden" name="detailId" value="<%= sd.getId() %>">
                                    <input type="hidden" name="invoiceId" value="<%= inv.getInvoice_id() %>">
                                    <button type="submit" class="btn btn-outline-danger btn-sm border-0"><i class="fas fa-trash-alt"></i></button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>

            <div class="row mt-4 justify-content-end">
                <div class="col-md-5 border-top pt-3">
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Tổng tiền gốc (Sân + Dịch vụ):</span>
                        <strong class="text-dark"><%= df.format(inv.getTotal_amount()) %> đ</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-1 text-success">
                        <span>Giảm giá thẻ VIP (10%):</span>
                        <strong>- <%= df.format(inv.getDiscount_amount()) %> đ</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-3 text-info">
                        <span>Tiền đã cọc trước:</span>
                        <strong>- <%= df.format(inv.getDeposit_amount()) %> đ</strong>
                    </div>
                    <div class="d-flex justify-content-between p-2 rounded bg-light border">
                        <span class="h5 m-0 text-dark">CẦN THANH TOÁN:</span>
                        <span class="h5 m-0 text-danger fw-bold"><%= df.format(inv.getNet_amount()) %> đ</span>
                    </div>

                    <% if("UNPAID".equals(inv.getStatus())) { %>
                    <div class="mt-4 card p-3 bg-light border shadow-sm">
                        <h6 class="fw-bold mb-3"><i class="fas fa-wallet text-primary"></i> Chọn phương thức thanh toán:</h6>

                        <form action="invoice" method="post">
                            <input type="hidden" name="action" value="pay">
                            <input type="hidden" name="invoiceId" value="<%= inv.getInvoice_id() %>">

                            <div class="d-flex gap-4 mb-3 justify-content-center">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="paymentMethod" id="payCash" value="TIỀN MẶT" checked>
                                    <label class="form-check-label fw-bold text-success" for="payCash">💵 Tiền mặt</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="paymentMethod" id="payBank" value="CHUYỂN KHOẢN">
                                    <label class="form-check-label fw-bold text-secondary" for="payBank">🏦 Chuyển khoản</label>
                                </div>
                            </div>

                            <button class="btn btn-success w-100 py-2 fw-bold shadow-sm mb-2">
                                <i class="fas fa-check-double"></i> XÁC NHẬN VÀ IN HÓA ĐƠN
                            </button>
                        </form>

                        <form action="invoice" method="post">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="invoiceId" value="<%= inv.getInvoice_id() %>">
                            <button class="btn btn-outline-danger w-100 btn-sm bg-white" onclick="return confirm('Hủy hóa đơn này đồng nghĩa với việc xóa bỏ toàn bộ dữ liệu? (BR5.6)')">
                                <i class="fas fa-ban"></i> HỦY ĐƠN
                            </button>
                        </form>
                    </div>
                    <% } else if ("PAID".equals(inv.getStatus())) { %>
                        <div class="alert alert-success mt-3 py-2 text-center shadow-sm border-success">
                            <i class="fas fa-check-circle"></i> Đã thanh toán bằng: <strong><%= inv.getPayment_method() != null ? inv.getPayment_method() : "Không xác định" %></strong>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="addSvc" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form class="modal-content" action="invoice" method="post">
      <div class="modal-header bg-primary text-white">
          <h5 class="modal-title"><i class="fas fa-plus-circle"></i> Thêm Dịch Vụ Cho Khách</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body bg-light">
        <input type="hidden" name="action" value="addService">
        <input type="hidden" name="invoiceId" value="<%= inv.getInvoice_id() %>">
        
        <div class="mb-3">
            <div class="input-group shadow-sm">
                <span class="input-group-text bg-white"><i class="fas fa-search text-primary"></i></span>
                <input type="text" id="svcSearch" class="form-control" placeholder="Nhập tên dịch vụ để lọc nhanh...">
            </div>
        </div>

        <div class="table-responsive bg-white border rounded" style="max-height: 350px;">
            <table class="table table-hover align-middle mb-0">
                <thead class="sticky-top bg-light shadow-sm">
                    <tr class="text-center">
                        <th width="50">Chọn</th>
                        <th class="text-start">Tên Dịch Vụ</th>
                        <th>Tồn Kho</th>
                        <th>Đơn Giá</th>
                    </tr>
                </thead>
                <tbody id="svcTableBody">
                    <% for(Service s : availableServices) { %>
                    <tr class="svc-row cursor-pointer" onclick="document.getElementById('radio_<%= s.getService_id() %>').checked = true;">
                        <td class="text-center">
                            <input class="form-check-input" type="radio" name="serviceId" id="radio_<%= s.getService_id() %>" value="<%= s.getService_id() %>" required>
                        </td>
                        <td class="text-start fw-bold text-secondary svc-name"><%= s.getName() %></td>
                        <td class="text-center">
                            <span class="badge <%= s.getStock_quantity() > 10 ? "bg-info text-dark" : "bg-warning text-dark" %>">
                                <%= s.getStock_quantity() %>
                            </span>
                        </td>
                        <td class="text-center fw-bold text-danger"><%= df.format(s.getPrice()) %> đ</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="mt-3">
            <label class="form-label fw-bold">Nhập số lượng khách gọi:</label>
            <input type="number" name="quantity" class="form-control w-25 fw-bold text-center" value="1" min="1" required>
        </div>

      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Chốt thêm</button>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Logic lọc dữ liệu tìm kiếm (UC-5.2 - Alternative Flow 4a)
document.getElementById('svcSearch').addEventListener('keyup', function() {
    let filter = this.value.toLowerCase();
    let rows = document.querySelectorAll('#svcTableBody .svc-row');
    rows.forEach(row => {
        let text = row.querySelector('.svc-name').textContent.toLowerCase();
        row.style.display = text.includes(filter) ? '' : 'none';
    });
});
</script>
</body>
</html>