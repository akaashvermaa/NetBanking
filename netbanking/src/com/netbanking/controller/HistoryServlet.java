package com.netbanking.controller;

import com.netbanking.model.User;
import com.netbanking.service.DashboardService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession(false).getAttribute("user");

        try {
            req.setAttribute("transactions", dashboardService.getFullHistory(user.getUserId()));
            req.getRequestDispatcher("/views/history.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error loading history", e);
        }
    }
}
