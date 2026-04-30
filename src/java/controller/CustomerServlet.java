package controller;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Customer;

@WebServlet("/customer")
public class CustomerServlet extends HttpServlet {
    private final CustomerDAO dao = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add" -> request.getRequestDispatcher("WEB-INF/jsp/add-customer.jsp")
                    .forward(request, response);
            case "edit" -> showEditForm(request, response);
            default -> showCustomerList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add" -> addCustomer(request, response);
            case "update" -> updateCustomer(request, response);
            case "disable" -> changeCustomerStatus(request, response, "INACTIVE");
            case "restore" -> changeCustomerStatus(request, response, "ACTIVE");
            default -> response.sendRedirect("customer");
        }
    }

    private void showCustomerList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = trimToEmpty(request.getParameter("keyword"));
        String customer_type = trimToDefault(request.getParameter("customer_type"), "ALL");
        String status = trimToDefault(request.getParameter("status"), "ACTIVE");

        List<Customer> list = dao.searchCustomers(keyword, customer_type, status);
        request.setAttribute("list", list);
        request.setAttribute("keyword", keyword);
        request.setAttribute("customer_type", customer_type);
        request.setAttribute("status", status);
        request.setAttribute("message", request.getParameter("message"));
        request.setAttribute("error", request.getParameter("error"));
        request.getRequestDispatcher("WEB-INF/jsp/customer-list.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        Customer customer = dao.getCustomerById(id);

        if (customer == null) {
            response.sendRedirect("customer");
            return;
        }

        request.setAttribute("customer", customer);
        request.getRequestDispatcher("WEB-INF/jsp/edit-customer.jsp").forward(request, response);
    }

    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Customer customer = buildCustomerFromRequest(request, 0, "ACTIVE");
        List<String> errors = validateCustomer(customer);

        if (errors.isEmpty() && dao.phoneExists(customer.getPhone())) {
            errors.add("Số điện thoại đã tồn tại");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("WEB-INF/jsp/add-customer.jsp").forward(request, response);
            return;
        }

        dao.insertCustomer(customer);
        response.sendRedirect("customer");
    }

    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        Customer customer = buildCustomerFromRequest(request, id, null);
        List<String> errors = validateCustomer(customer);

        if (errors.isEmpty() && dao.phoneExistsExceptId(customer.getPhone(), id)) {
            errors.add("Số điện thoại đã tồn tại ở khách hàng khác");
        }

        if (!errors.isEmpty()) {
            Customer current = dao.getCustomerById(id);
            if (current != null) {
                customer.setStatus(current.getStatus());
                customer.setCreated_at(current.getCreated_at());
            }
            request.setAttribute("errors", errors);
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("WEB-INF/jsp/edit-customer.jsp").forward(request, response);
            return;
        }

        dao.updateCustomer(customer);
        response.sendRedirect("customer");
    }

    private void changeCustomerStatus(HttpServletRequest request, HttpServletResponse response,
            String status) throws IOException {
        int id = parseId(request.getParameter("id"));
        dao.updateStatus(id, status);
        response.sendRedirect("customer");
    }

    private Customer buildCustomerFromRequest(HttpServletRequest request, int id, String status) {
        String full_name = trimToEmpty(request.getParameter("full_name"));
        String phone = trimToEmpty(request.getParameter("phone"));
        String address = trimToEmpty(request.getParameter("address"));
        String customer_type = trimToDefault(request.getParameter("customer_type"), "NORMAL");

        return new Customer(id, full_name, phone, address, customer_type, status);
    }

    private List<String> validateCustomer(Customer customer) {
        List<String> errors = new ArrayList<>();

        if (customer.getFull_name().isEmpty()) {
            errors.add("Họ tên không được để trống");
        }

        if (customer.getPhone().isEmpty()) {
            errors.add("Số điện thoại không được để trống");
        } else if (!customer.getPhone().matches("\\d{9,15}")) {
            errors.add("Số điện thoại chỉ gồm 9-15 chữ số");
        }

        if (!"NORMAL".equals(customer.getCustomer_type()) && !"VIP".equals(customer.getCustomer_type())) {
            errors.add("Loại khách hàng không hợp lệ");
        }

        return errors;
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String trimToDefault(String value, String defaultValue) {
        String trimmed = trimToEmpty(value);
        return trimmed.isEmpty() ? defaultValue : trimmed;
    }
}

