package com.netbanking.controller;

import com.netbanking.model.User;
import com.netbanking.service.TransferException;
import com.netbanking.service.TransferService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/transfer")
public class TransferServlet extends HttpServlet {

    private final TransferService transferService = new TransferService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/transfer.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession(false).getAttribute("user");

        String recipientAccountNumber = req.getParameter("recipientAccountNumber");
        String amountText = req.getParameter("amount");
        String remark = req.getParameter("remark");

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountText);
        } catch (NumberFormatException | NullPointerException e) {
            req.setAttribute("error", "Invalid amount");
            req.getRequestDispatcher("/views/transfer.jsp").forward(req, resp);
            return;
        }

        try {
            transferService.transfer(user.getUserId(), recipientAccountNumber, amount, remark);
            req.setAttribute("success", "Transfer completed successfully");
            req.getRequestDispatcher("/views/transfer.jsp").forward(req, resp);
        } catch (TransferException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/transfer.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error during transfer", e);
        }
    }
}
