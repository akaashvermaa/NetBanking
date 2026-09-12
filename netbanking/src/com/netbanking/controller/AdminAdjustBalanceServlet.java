package com.netbanking.controller;

import com.netbanking.service.AdminBalanceService;
import com.netbanking.service.AdminException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/admin/adjust-balance")
public class AdminAdjustBalanceServlet extends HttpServlet {

    private final AdminBalanceService adminBalanceService = new AdminBalanceService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        req.setAttribute("accountNumber", req.getParameter("accountNumber"));
        req.getRequestDispatcher("/views/admin/admin-adjust-balance.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accountNumber = req.getParameter("accountNumber");
        String amountText = req.getParameter("amount");
        String direction = req.getParameter("direction");
        String reason = req.getParameter("reason");

        req.setAttribute("accountNumber", accountNumber);
        req.setAttribute("reason", reason);
        req.setAttribute("direction", direction);

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountText);
        } catch (NumberFormatException | NullPointerException e) {
            req.setAttribute("error", "Invalid amount");
            req.getRequestDispatcher("/views/admin/admin-adjust-balance.jsp").forward(req, resp);
            return;
        }

        try {
            boolean credit = "credit".equals(direction);
            adminBalanceService.adjust(accountNumber, amount, credit, reason);





            req.setAttribute("success", (credit ? "Credited " : "Debited ") + "\u20B9"
                    + String.format("%,.2f", amount) + (credit ? " to " : " from ") + accountNumber);
            req.removeAttribute("reason");
            req.getRequestDispatcher("/views/admin/admin-adjust-balance.jsp").forward(req, resp);
        } catch (AdminException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/admin/admin-adjust-balance.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error adjusting balance", e);
        }
    }
}
