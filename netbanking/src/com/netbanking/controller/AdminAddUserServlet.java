package com.netbanking.controller;

import com.netbanking.model.Account;
import com.netbanking.service.AdminUserService;
import com.netbanking.service.AuthException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/add-user")
public class AdminAddUserServlet extends HttpServlet {

    private final AdminUserService adminUserService = new AdminUserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);

        if (password == null || !password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }

        try {
            Account account = adminUserService.createUser(fullName, email, password);
            req.getSession().setAttribute("flashSuccess",
                    "User " + account.getHolderName() + " created with account " + account.getAccountNumber());
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error creating user", e);
        }
    }
}
