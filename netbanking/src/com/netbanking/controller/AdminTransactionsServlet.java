package com.netbanking.controller;

import com.netbanking.service.AdminUserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/transactions")
public class AdminTransactionsServlet extends HttpServlet {

    private final AdminUserService adminUserService = new AdminUserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("transactions", adminUserService.listAllTransactions());
            req.getRequestDispatcher("/views/admin/admin-transactions.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error loading transactions", e);
        }
    }
}
