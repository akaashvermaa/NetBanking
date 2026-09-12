package com.netbanking.controller;

import com.netbanking.model.Account;
import com.netbanking.service.AdminUserService;
import com.netbanking.service.AuthException;
import com.netbanking.util.PhotoStorage;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/admin/add-user")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
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
        String openingBalanceText = req.getParameter("openingBalance");
        String accountType = req.getParameter("accountType");

        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("openingBalance", openingBalanceText);
        req.setAttribute("accountType", accountType);

        if (password == null || !password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }

        BigDecimal openingBalance;
        try {
            openingBalance = new BigDecimal(openingBalanceText);
        } catch (NumberFormatException | NullPointerException e) {
            req.setAttribute("error", "Invalid opening credit amount");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }
        if (openingBalance.signum() < 0) {
            req.setAttribute("error", "Opening credit cannot be negative");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }

        if (!Account.TYPE_SAVINGS.equals(accountType) && !Account.TYPE_CURRENT.equals(accountType)) {
            req.setAttribute("error", "Choose an account type");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }

        Part photoPart;
        try {
            photoPart = req.getPart("profilePhoto");
        } catch (IllegalStateException e) {


            req.setAttribute("error", "Photo is too large (max 2MB)");
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        }

        String profilePhoto;
        try {
            String uploadsPath = getServletContext().getRealPath("/static/uploads/profile-photos");
            profilePhoto = PhotoStorage.save(photoPart, uploadsPath);
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/admin/admin-add-user.jsp").forward(req, resp);
            return;
        } catch (IOException e) {
            throw new ServletException("Failed to save uploaded photo", e);
        }

        try {
            Account account = adminUserService.createUser(
                    fullName, email, password, openingBalance, accountType, profilePhoto);
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
