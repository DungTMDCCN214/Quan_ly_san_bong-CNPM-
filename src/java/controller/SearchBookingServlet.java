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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "search";

        switch (action) {
            case "search" -> {
                String phone       = request.getParameter("phone");
                String bookingDate = request.getParameter("bookingDate");

                List<BookingSearchResult> results = null;
                if ((phone != null && !phone.isBlank()) || (bookingDate != null && !bookingDate.isBlank())) {
                    results = dao.searchBookings(phone, bookingDate);
                }

                request.setAttribute("results", results);
                request.setAttribute("phone", phone != null ? phone : "");
                request.setAttribute("bookingDate", bookingDate != null ? bookingDate : "");
                request.setAttribute("currentPage", "booking-search"); // Phục vụ sidebar
                request.getRequestDispatcher("WEB-INF/jsp/search-booking.jsp").forward(request, response);
            }

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

                Map<String, List<BookingDetailView>> grouped = new java.util.LinkedHashMap<>();
                for (BookingDetailView d : details) {
                    grouped.computeIfAbsent(d.getCourtName(), k -> new java.util.ArrayList<>()).add(d);
                }

                int total = 0;
                for (BookingDetailView d : details) {
                    if (!"CANCELLED".equals(d.getDetailStatus())) total += d.getPricePerHour();
                }

                request.setAttribute("header", header);
                request.setAttribute("details", details);
                request.setAttribute("grouped", grouped);
                request.setAttribute("totalActive", total);
                request.setAttribute("currentPage", "booking-search");
                request.getRequestDispatcher("WEB-INF/jsp/booking-detail.jsp").forward(request, response);
            }

            default -> response.sendRedirect("searchBooking?action=search");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "applyChanges" -> {
                String bookingIdStr = request.getParameter("bookingId");
                if (bookingIdStr == null || bookingIdStr.isBlank()) {
                    response.sendRedirect("searchBooking?action=search");
                    return;
                }
                int bookingId = Integer.parseInt(bookingIdStr);

                Map<Integer, String> updates = new HashMap<>();
                Map<String, String[]> params = request.getParameterMap();
                for (Map.Entry<String, String[]> entry : params.entrySet()) {
                    String key = entry.getKey();
                    if (key.startsWith("status_")) {
                        try {
                            int detailId  = Integer.parseInt(key.substring(7));
                            String newSt  = entry.getValue()[0];
                            // Cập nhật lại list trạng thái chuẩn xác
                            if (List.of("BOOKED", "IN PROGRESS", "FINISHED", "CANCELLED").contains(newSt)) {
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