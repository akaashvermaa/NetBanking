package com.netbanking.controller;

import com.netbanking.service.AuthException;
import com.netbanking.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (password == null || !password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match");
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            authService.register(fullName, email, password);
            resp.sendRedirect(req.getContextPath() + "/login?registered=true");
        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error during registration", e);
        }
    }
}
