package controller;

import dao.SearchBookingDAO;
import model.BookingDetailView;
import model.BookingSearchResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/searchBooking")
public class SearchBookingServlet extends HttpServlet {

    private final SearchBookingDAO dao = new SearchBookingDAO();

    // ================================================================
    //  GET
    // ================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "search";

        switch (action) {

            // ── Trang tìm kiếm đơn ────────────────────────────────────────
            case "search" -> {
                String phone       = request.getParameter("phone");
                String bookingDate = request.getParameter("bookingDate");

                List<BookingSearchResult> results = null;
                // Chỉ tìm khi có ít nhất 1 điều kiện
                if ((phone != null && !phone.isBlank()) || (bookingDate != null && !bookingDate.isBlank())) {
                    results = dao.searchBookings(phone, bookingDate);
                }

                request.setAttribute("results", results);
                request.setAttribute("phone", phone != null ? phone : "");
                request.setAttribute("bookingDate", bookingDate != null ? bookingDate : "");
                request.getRequestDispatcher("WEB-INF/jsp/search-booking.jsp")
                       .forward(request, response);
            }

            // ── Trang chi tiết một đơn ────────────────────────────────────
            case "detail" -> {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.isBlank()) {
                    response.sendRedirect("searchBooking?action=search");
                    return;
                }
                int bookingId = Integer.parseInt(idStr);

                Map<String, Object> header  = dao.getBookingHeader(bookingId);
                List<BookingDetailView> details = dao.getBookingDetails(bookingId);

                if (header.isEmpty()) {
                    response.sendRedirect("searchBooking?action=search");
                    return;
                }

                // Gom nhóm details theo courtName để render từng khối sân
                Map<String, List<BookingDetailView>> grouped = new java.util.LinkedHashMap<>();
                for (BookingDetailView d : details) {
                    grouped.computeIfAbsent(d.getCourtName(), k -> new java.util.ArrayList<>()).add(d);
                }

                // Tính tổng tiền các slot chưa hủy (để hiển thị realtime)
                int total = 0;
                for (BookingDetailView d : details) {
                    if (!"CANCELLED".equals(d.getDetailStatus())) total += d.getPricePerHour();
                }

                request.setAttribute("header", header);
                request.setAttribute("details", details);
                request.setAttribute("grouped", grouped);
                request.setAttribute("totalActive", total);
                request.getRequestDispatcher("WEB-INF/jsp/booking-detail.jsp")
                       .forward(request, response);
            }

            default -> response.sendRedirect("searchBooking?action=search");
        }
    }

    // ================================================================
    //  POST – Áp dụng thay đổi check-in / check-out / hủy
    // ================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // ── Áp dụng thay đổi trạng thái từng detail ──────────────────
            // Form gửi lên: bookingId, và nhiều field "status_{detailId}" = "PLAYING|DONE|CANCELLED"
            case "applyChanges" -> {
                String bookingIdStr = request.getParameter("bookingId");
                if (bookingIdStr == null || bookingIdStr.isBlank()) {
                    response.sendRedirect("searchBooking?action=search");
                    return;
                }
                int bookingId = Integer.parseInt(bookingIdStr);

                // Thu thập tất cả field có prefix "status_"
                Map<Integer, String> updates = new HashMap<>();
                Map<String, String[]> params = request.getParameterMap();
                for (Map.Entry<String, String[]> entry : params.entrySet()) {
                    String key = entry.getKey();
                    if (key.startsWith("status_")) {
                        try {
                            int detailId  = Integer.parseInt(key.substring(7));
                            String newSt  = entry.getValue()[0];
                            // Chỉ chấp nhận các giá trị hợp lệ
                            if (List.of("BOOKED", "PLAYING", "DONE", "CANCELLED").contains(newSt)) {
                                updates.put(detailId, newSt);
                            }
                        } catch (NumberFormatException ignored) {}
                    }
                }

                if (!updates.isEmpty()) {
                    dao.updateDetailStatuses(updates, bookingId);
                }

                response.sendRedirect("searchBooking?action=detail&id=" + bookingId);
            }

            default -> response.sendRedirect("searchBooking?action=search");
        }
    }
}
