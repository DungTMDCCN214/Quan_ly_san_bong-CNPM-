package controller;

import dao.BookingDAO;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;

@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    // ================================================================
    //  GET
    // ================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "start";

        switch (action) {

            case "start" -> {
                request.getRequestDispatcher("WEB-INF/jsp/booking-search-customer.jsp")
                       .forward(request, response);
            }

            case "searchCustomer" -> {
                String phone = request.getParameter("phone");
                if (phone == null) phone = "";
                List<Customer> customers = bookingDAO.searchCustomersByPhone(phone.trim());
                request.setAttribute("customers", customers);
                request.setAttribute("phone", phone);
                request.getRequestDispatcher("WEB-INF/jsp/booking-search-customer.jsp")
                       .forward(request, response);
            }

            case "selectCourt" -> {
                HttpSession session = request.getSession();
                Customer customer = (Customer) session.getAttribute("selectedCustomer");
                if (customer == null) {
                    response.sendRedirect("booking?action=start");
                    return;
                }

                String dateParam = request.getParameter("date");
                String selectedDate = (dateParam != null && !dateParam.isBlank())
                        ? dateParam : LocalDate.now().toString();

                List<Court> courts = bookingDAO.getAllActiveCourts();
                List<TimeSlot> timeSlots = bookingDAO.getAllTimeSlots();

                List<Integer> courtIds = new ArrayList<>();
                for (Court c : courts) {
                    courtIds.add(c.getCourt_id()); // Khớp chuẩn getCourt_id()
                }

                Map<Integer, Set<Integer>> bookedMap = new HashMap<>();
                for (Court ct : courts) {
                    Set<Integer> ids = bookingDAO.getBookedSlotIds(ct.getCourt_id(), selectedDate); // Khớp chuẩn getCourt_id()
                    bookedMap.put(ct.getCourt_id(), ids); // Khớp chuẩn getCourt_id()
                }

                request.setAttribute("courts", courts);
                request.setAttribute("timeSlots", timeSlots);
                request.setAttribute("bookedMap", bookedMap);
                request.setAttribute("selectedDate", selectedDate);
                request.setAttribute("customer", customer);
                request.getRequestDispatcher("WEB-INF/jsp/booking-select-court.jsp")
                       .forward(request, response);
            }

            case "confirm" -> {
                HttpSession session = request.getSession();
                Customer customer = (Customer) session.getAttribute("selectedCustomer");
                List<BookingDetail> details = (List<BookingDetail>) session.getAttribute("pendingDetails");

                if (customer == null || details == null || details.isEmpty()) {
                    response.sendRedirect("booking?action=start");
                    return;
                }

                // Đổi biến tính tổng tiền sang dạng double
                double totalAmount = 0;
                for (BookingDetail d : details) totalAmount += d.getPricePerHour();

                request.setAttribute("customer", customer);
                request.setAttribute("details", details);
                request.setAttribute("totalAmount", totalAmount);
                request.getRequestDispatcher("WEB-INF/jsp/booking-confirm.jsp")
                       .forward(request, response);
            }

            case "success" -> {
                int bookingId = 0;
                try { bookingId = Integer.parseInt(request.getParameter("id")); }
                catch (Exception ignored) {}
                request.setAttribute("bookingId", bookingId);
                request.getRequestDispatcher("WEB-INF/jsp/booking-success.jsp")
                       .forward(request, response);
            }

            default -> response.sendRedirect("booking?action=start");
        }
    }

    // ================================================================
    //  POST
    // ================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "chooseCustomer" -> {
                String customerIdStr = request.getParameter("customerId");
                if (customerIdStr == null || customerIdStr.isBlank()) {
                    response.sendRedirect("booking?action=start");
                    return;
                }
                int customerId = Integer.parseInt(customerIdStr);
                Customer customer = bookingDAO.getCustomerById(customerId);
                if (customer == null) {
                    response.sendRedirect("booking?action=start");
                    return;
                }
                HttpSession session = request.getSession();
                session.setAttribute("selectedCustomer", customer);
                session.removeAttribute("pendingDetails");
                response.sendRedirect("booking?action=selectCourt");
            }

            case "chooseSlots" -> {
                HttpSession session = request.getSession();
                Customer customer = (Customer) session.getAttribute("selectedCustomer");
                if (customer == null) { response.sendRedirect("booking?action=start"); return; }

                String[] slots = request.getParameterValues("slot");
                if (slots == null || slots.length == 0) {
                    session.setAttribute("slotError", "Vui lòng chọn ít nhất một khung giờ!");
                    response.sendRedirect("booking?action=selectCourt");
                    return;
                }

                List<BookingDetail> details = new ArrayList<>();
                for (String s : slots) {
                    String[] parts = s.split("\\|");
                    if (parts.length < 7) continue;
                    BookingDetail d = new BookingDetail();
                    d.setCourtId(Integer.parseInt(parts[0]));
                    d.setTimeSlotId(Integer.parseInt(parts[1]));
                    d.setUsageDate(Date.valueOf(parts[2]));
                    d.setPricePerHour(Double.parseDouble(parts[3])); // Ép kiểu Double chuẩn xác
                    d.setCourtName(parts[4]);
                    d.setSlotStart(parts[5]);
                    d.setSlotEnd(parts[6]);
                    details.add(d);
                }

                if (details.isEmpty()) {
                    session.setAttribute("slotError", "Dữ liệu không hợp lệ. Vui lòng chọn lại.");
                    response.sendRedirect("booking?action=selectCourt");
                    return;
                }

                session.setAttribute("pendingDetails", details);
                response.sendRedirect("booking?action=confirm");
            }

            case "saveBooking" -> {
                HttpSession session = request.getSession();
                Customer customer = (Customer) session.getAttribute("selectedCustomer");
                List<BookingDetail> details = (List<BookingDetail>) session.getAttribute("pendingDetails");

                if (customer == null || details == null || details.isEmpty()) {
                    response.sendRedirect("booking?action=start");
                    return;
                }

                Integer managerId = (Integer) session.getAttribute("managerId");
                if (managerId == null) managerId = 1;

                double totalAmount = 0;
                for (BookingDetail d : details) totalAmount += d.getPricePerHour();

                double depositAmount = totalAmount * 0.1;

                int newId = bookingDAO.saveBooking(
                        customer.getCustomer_id(),
                        managerId,
                        Date.valueOf(LocalDate.now()),
                        details,
                        totalAmount,
                        depositAmount 
                );
                                session.removeAttribute("pendingDetails");
                session.removeAttribute("selectedCustomer");

                if (newId > 0) {
                    response.sendRedirect("booking?action=success&id=" + newId);
                } else {
                    session.setAttribute("selectedCustomer", customer);
                    session.setAttribute("pendingDetails", details);
                    request.setAttribute("error", "Lưu đơn thất bại. Vui lòng thử lại.");
                    request.setAttribute("customer", customer);
                    request.setAttribute("details", details);
                    request.setAttribute("totalAmount", totalAmount);
                    request.getRequestDispatcher("WEB-INF/jsp/booking-confirm.jsp")
                           .forward(request, response);
                }
            }

            default -> response.sendRedirect("booking?action=start");
        }
    }
}