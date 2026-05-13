package controller;

import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import model.Invoice;

@WebServlet("/invoice")
public class InvoiceServlet extends HttpServlet {
    private final InvoiceDAO dao = new InvoiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "list"; 

        switch (action) {
            case "list" -> {
                String keyword = request.getParameter("keyword");
                String status = request.getParameter("status");
                if (status == null) status = "ALL";

                List<Invoice> list = dao.searchInvoices(keyword, status);
                request.setAttribute("list", list);
                request.setAttribute("keyword", keyword != null ? keyword : "");
                request.setAttribute("status", status);
                request.setAttribute("currentPage", "invoice");
                request.getRequestDispatcher("WEB-INF/jsp/invoice-list.jsp").forward(request, response);
            }
            
            case "listUninvoiced" -> {
                // Nhận keyword từ ô tìm kiếm
                String keyword = request.getParameter("keyword");
                
                // Truyền keyword xuống DAO
                List<Map<String, Object>> list = dao.getUninvoicedBookingDetails(keyword);
                
                request.setAttribute("list", list);
                // Giữ lại từ khóa để hiển thị lại trên ô input
                request.setAttribute("keyword", keyword != null ? keyword : ""); 
                request.setAttribute("currentPage", "invoice");
                request.getRequestDispatcher("WEB-INF/jsp/invoice-create-list.jsp").forward(request, response);
            }
            
            case "detail" -> {
                int id = Integer.parseInt(request.getParameter("id"));
                Invoice inv = dao.getInvoiceById(id);
                if (inv == null) { response.sendRedirect("invoice?action=list"); return; }

                request.setAttribute("inv", inv);
                // ĐÃ ĐỔI HÀM CẬP NHẬT GỌI COURT DETAIL
                request.setAttribute("courtDetails", dao.getCourtDetailsForInvoice(inv.getBooking_detail_id()));
                request.setAttribute("serviceDetails", dao.getInvoiceDetails(id));
                request.setAttribute("availableServices", dao.getActiveServices()); 
                request.setAttribute("currentPage", "invoice");
                request.getRequestDispatcher("WEB-INF/jsp/invoice-detail.jsp").forward(request, response);
            }
            
            default -> response.sendRedirect("invoice?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        try {
            switch (action) {
                case "create" -> {
                    // ĐỔI TÊN BIẾN THÀNH bookingDetailId
                    int bookingDetailId = Integer.parseInt(request.getParameter("bookingDetailId"));
                    int newInvoiceId = dao.createInvoice(bookingDetailId);
                    if (newInvoiceId > 0) {
                        response.sendRedirect("invoice?action=detail&id=" + newInvoiceId);
                    } else {
                        response.sendRedirect("invoice?action=listUninvoiced&error=create_failed");
                    }
                }
                case "addService" -> {
                    int invId = Integer.parseInt(request.getParameter("invoiceId"));
                    int svcId = Integer.parseInt(request.getParameter("serviceId"));
                    int qty = Integer.parseInt(request.getParameter("quantity"));
                    if (dao.addServiceToInvoice(invId, svcId, qty)) {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&msg=add_svc_success");
                    } else {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&error=out_of_stock");
                    }
                }
                case "updateService" -> {
                    int detailId = Integer.parseInt(request.getParameter("detailId"));
                    int invId = Integer.parseInt(request.getParameter("invoiceId"));
                    int newQty = Integer.parseInt(request.getParameter("quantity"));
                    
                    if (dao.updateServiceQuantity(detailId, newQty)) {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&msg=update_success");
                    } else {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&error=invalid_qty");
                    }
                }
                case "deleteService" -> {
                    int detId = Integer.parseInt(request.getParameter("detailId"));
                    int invId = Integer.parseInt(request.getParameter("invoiceId"));
                    dao.removeServiceFromInvoice(detId);
                    response.sendRedirect("invoice?action=detail&id=" + invId);
                }
                case "pay" -> {
                    int invId = Integer.parseInt(request.getParameter("invoiceId"));
                    String pMethod = request.getParameter("paymentMethod"); 

                    // Truyền thêm phương thức thanh toán vào DAO
                    if (dao.updateInvoiceStatus(invId, "PAID", pMethod)) {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&msg=pay_success");
                    } else {
                        response.sendRedirect("invoice?action=detail&id=" + invId + "&error=pay_failed");
                    }
                }
                case "cancel" -> {
                    int invId = Integer.parseInt(request.getParameter("invoiceId"));
                    // Bổ sung thêm tham số thứ 3 (paymentMethod) là null vì đơn bị hủy
                    dao.updateInvoiceStatus(invId, "CANCELLED", null);
                    // Hủy xong văng ra danh sách
                    response.sendRedirect("invoice?action=list&message=cancel_success");
                }
                default -> response.sendRedirect("invoice?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("invoice?action=list");
        }
    }
}