package com.netbanking.controller;

import com.netbanking.service.AdminException;
import com.netbanking.service.AdminUserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {

    private final AdminUserService adminUserService = new AdminUserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Flash messages set by doPost survive the redirect via the session, then are consumed here.
        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("success", session.getAttribute("flashSuccess"));
            req.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashSuccess");
            session.removeAttribute("flashError");
        }

        try {
            req.setAttribute("accounts", adminUserService.listAccounts());
            req.getRequestDispatcher("/views/admin/admin-users.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error loading accounts", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);

        try {
            int accountId = Integer.parseInt(req.getParameter("accountId"));
            switch (action == null ? "" : action) {
                case "freeze":
                    adminUserService.freeze(accountId);
                    session.setAttribute("flashSuccess", "Account frozen");
                    break;
                case "unfreeze":
                    adminUserService.unfreeze(accountId);
                    session.setAttribute("flashSuccess", "Account unfrozen");
                    break;
                case "close":
                    adminUserService.close(accountId);
                    session.setAttribute("flashSuccess", "Account closed");
                    break;
                case "reactivate":
                    adminUserService.reactivate(accountId);
                    session.setAttribute("flashSuccess", "Account reactivated");
                    break;
                default:
                    session.setAttribute("flashError", "Unknown action");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Invalid account");
        } catch (AdminException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Database error updating account", e);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
