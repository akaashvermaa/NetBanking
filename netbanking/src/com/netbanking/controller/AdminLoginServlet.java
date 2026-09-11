package com.netbanking.controller;

import com.netbanking.model.Admin;
import com.netbanking.service.AdminAuthService;
import com.netbanking.service.AuthException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    private final AdminAuthService adminAuthService = new AdminAuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/admin/admin-login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            Admin admin = adminAuthService.login(email, password);

            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("admin", admin);

            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("email", email);
            req.getRequestDispatcher("/views/admin/admin-login.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error during admin login", e);
        }
    }
}
