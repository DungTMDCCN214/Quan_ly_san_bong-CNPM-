/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.CourtDAO;
import model.Court;

import jakarta.servlet.ServletException;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 *
 * @author Admin
 */
@WebServlet("/court")
public class CourtServlet extends HttpServlet {

    CourtDAO dao = new CourtDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "delete" -> {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteCourt(id);
                response.sendRedirect("court");
            }
            case "edit" -> {
                int editId = Integer.parseInt(request.getParameter("id"));
                Court c = dao.getCourtById(editId);
                request.setAttribute("court", c);
                request.getRequestDispatcher("WEB-INF/jsp/edit-court.jsp").forward(request, (ServletResponse) response);
            }
            case "add" ->{
                request.getRequestDispatcher("WEB-INF/jsp/add-court.jsp")
                        .forward(request, response);
            }

            default -> {
                List<Court> list = dao.getAllCourts();
                request.setAttribute("list", list);
                request.getRequestDispatcher("WEB-INF/jsp/court-list.jsp").forward(request, (ServletResponse) response);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        String name = request.getParameter("name");
        String type = request.getParameter("type");           // Thêm type
        double price = Double.parseDouble(request.getParameter("price"));
        String status = request.getParameter("status");
        String desc = request.getParameter("description");

        if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            // Cập nhật: thêm tham số type vào constructor
            dao.updateCourt(new Court(id, name, type, price, status, desc));
        } else {
            // Thêm mới: tham số type, created_at sẽ tự động set trong DAO
            dao.insertCourt(new Court(0, name, type, price, status, desc));
        }
        response.sendRedirect("court");
    }
}