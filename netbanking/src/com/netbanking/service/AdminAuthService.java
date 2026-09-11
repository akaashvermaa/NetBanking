package com.netbanking.service;

import com.netbanking.dao.AdminDAO;
import com.netbanking.model.Admin;
import com.netbanking.util.PasswordUtil;

import java.sql.SQLException;

public class AdminAuthService {

    private final AdminDAO adminDAO = new AdminDAO();

    public Admin login(String email, String plainPassword) throws AuthException, SQLException {
        Admin admin = adminDAO.findByEmail(email);
        if (admin == null || !PasswordUtil.verify(plainPassword, admin.getPasswordHash())) {
            throw new AuthException("Invalid admin credentials");
        }
        return admin;
    }
}
