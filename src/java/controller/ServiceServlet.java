package controller;

import dao.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Service;

@WebServlet("/service")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB (Kích thước file tối đa)
    maxRequestSize = 1024 * 1024 * 50     // 50MB (Kích thước request tối đa)
)
public class ServiceServlet extends HttpServlet {
    private final ServiceDAO dao = new ServiceDAO();

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
            case "add" -> request.getRequestDispatcher("WEB-INF/jsp/add-service.jsp").forward(request, response);
            case "edit" -> showEditForm(request, response);
            default -> showServiceList(request, response);
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
            case "add" -> addService(request, response);
            case "update" -> updateService(request, response);
            case "delete" -> deleteService(request, response);
            case "restore" -> changeServiceStatus(request, response, "ACTIVE");
            default -> response.sendRedirect("service");
        }
    }

    // ==========================================
    // LOGIC UPLOAD FILE (MỚI THÊM)
    // ==========================================
    private String uploadImage(HttpServletRequest request, String oldImage) throws IOException, ServletException {
        Part filePart = request.getPart("image_file");
        
        // Nếu người dùng có chọn file mới
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = filePart.getSubmittedFileName();
            // Thêm thời gian vào tên file để tránh bị trùng tên
            fileName = System.currentTimeMillis() + "_" + fileName;

            // Tìm đường dẫn thực tế của thư mục assets trên server
            String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "services";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs(); // Tự động tạo thư mục nếu chưa có
            }

            // Lưu file vào ổ cứng
            filePart.write(uploadPath + File.separator + fileName);
            return fileName;
        }
        
        // Nếu không tải ảnh mới, giữ nguyên ảnh cũ (hoặc ảnh mặc định)
        return (oldImage != null && !oldImage.isEmpty()) ? oldImage : "default-service.png";
    }

    private void showServiceList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = trimToEmpty(request.getParameter("keyword"));
        String status = trimToDefault(request.getParameter("status"), "ACTIVE");

        List<Service> list = dao.searchServices(keyword, status);
        request.setAttribute("list", list);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("message", request.getParameter("message"));
        request.setAttribute("error", request.getParameter("error"));
        
        request.setAttribute("currentPage", "service");
        request.getRequestDispatcher("WEB-INF/jsp/service-list.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        Service service = dao.getServiceById(id);

        if (service == null) {
            response.sendRedirect("service");
            return;
        }

        request.setAttribute("service", service);
        request.setAttribute("currentPage", "service");
        request.getRequestDispatcher("WEB-INF/jsp/edit-service.jsp").forward(request, response);
    }

    private void addService(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Gọi hàm upload ảnh trước khi build đối tượng
        String imagePath = uploadImage(request, "default-service.png");
        Service service = buildServiceFromRequest(request, 0, "ACTIVE", imagePath);
        
        List<String> errors = validateService(service);

        if (errors.isEmpty() && dao.nameExistsExceptId(service.getName(), 0)) {
            errors.add("Tên dịch vụ đã tồn tại trong hệ thống.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("service", service);
            request.setAttribute("currentPage", "service");
            request.getRequestDispatcher("WEB-INF/jsp/add-service.jsp").forward(request, response);
            return;
        }

        dao.insertService(service);
        response.sendRedirect("service?message=add_success");
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        String oldImage = request.getParameter("old_image"); // Lấy tên ảnh cũ từ hidden input
        
        // Gọi hàm upload ảnh
        String imagePath = uploadImage(request, oldImage);
        Service service = buildServiceFromRequest(request, id, null, imagePath);
        
        List<String> errors = validateService(service);

        if (errors.isEmpty() && dao.nameExistsExceptId(service.getName(), id)) {
            errors.add("Tên dịch vụ đã bị trùng với một dịch vụ khác.");
        }

        if (!errors.isEmpty()) {
            Service current = dao.getServiceById(id);
            if (current != null) {
                service.setStatus(current.getStatus());
            }
            request.setAttribute("errors", errors);
            request.setAttribute("service", service);
            request.setAttribute("currentPage", "service");
            request.getRequestDispatcher("WEB-INF/jsp/edit-service.jsp").forward(request, response);
            return;
        }

        dao.updateService(service);
        response.sendRedirect("service?message=update_success");
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = parseId(request.getParameter("id"));
        if (dao.checkServiceInUnpaidInvoice(id)) {
            response.sendRedirect("service?error=cannot_delete_unpaid_invoice");
            return;
        }
        dao.updateStatus(id, "INACTIVE");
        response.sendRedirect("service?message=delete_success");
    }

    private void changeServiceStatus(HttpServletRequest request, HttpServletResponse response, String status) throws IOException {
        int id = parseId(request.getParameter("id"));
        dao.updateStatus(id, status);
        response.sendRedirect("service?message=restore_success");
    }

    // Cập nhật hàm này để nhận image_path từ bên ngoài truyền vào
    private Service buildServiceFromRequest(HttpServletRequest request, int id, String status, String imagePath) {
        String name = trimToEmpty(request.getParameter("name"));
        double price = parseDouble(request.getParameter("price"));
        int stock_quantity = parseId(request.getParameter("stock_quantity"));
        String description = trimToEmpty(request.getParameter("description"));

        return new Service(id, name, price, stock_quantity, status, description, imagePath);
    }

    private List<String> validateService(Service service) {
        List<String> errors = new ArrayList<>();
        if (service.getName().isEmpty()) errors.add("Tên dịch vụ không được để trống.");
        if (service.getPrice() < 0) errors.add("Giá bán phải lớn hơn hoặc bằng 0.");
        if (service.getStock_quantity() < 0) errors.add("Số lượng tồn kho phải lớn hơn hoặc bằng 0.");
        return errors;
    }

    private int parseId(String value) {
        try { return Integer.parseInt(value); } 
        catch (Exception e) { return 0; }
    }

    private double parseDouble(String value) {
        try { return Double.parseDouble(value); } 
        catch (Exception e) { return -1; }
    }

    private String trimToEmpty(String value) { return value == null ? "" : value.trim(); }
    private String trimToDefault(String value, String defaultValue) {
        String trimmed = trimToEmpty(value);
        return trimmed.isEmpty() ? defaultValue : trimmed;
    }
}