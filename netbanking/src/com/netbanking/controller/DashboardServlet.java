package com.netbanking.controller;

import com.netbanking.model.User;
import com.netbanking.service.DashboardData;
import com.netbanking.service.DashboardService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession(false).getAttribute("user");

        try {
            DashboardData data = dashboardService.getDashboardData(user.getUserId());
            req.setAttribute("account", data.getAccount());
            req.setAttribute("recentTransactions", data.getRecentTransactions());
            req.setAttribute("totalSent", data.getTotalSent());
            req.setAttribute("totalReceived", data.getTotalReceived());
            req.getRequestDispatcher("/views/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error loading dashboard", e);
        }
    }
}
