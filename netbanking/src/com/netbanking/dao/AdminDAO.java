package com.netbanking.dao;

import com.netbanking.model.Admin;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminDAO {

    public Admin findByEmail(String email) throws SQLException {
        String sql = "SELECT admin_id, full_name, email, password_hash FROM admins WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin();
                    admin.setAdminId(rs.getInt("admin_id"));
                    admin.setFullName(rs.getString("full_name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setPasswordHash(rs.getString("password_hash"));
                    return admin;
                }
            }
        }
        return null;
    }

    /** System-wide figures for the admin dashboard, fetched in a single round trip. */
    public SystemStats getSystemStats() throws SQLException {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM users) AS total_users, "
                + "COUNT(*) AS total_accounts, "
                + "COALESCE(SUM(balance), 0) AS total_balance, "
                + "COUNT(*) FILTER (WHERE status = 'ACTIVE') AS active_count, "
                + "COUNT(*) FILTER (WHERE status = 'FROZEN') AS frozen_count, "
                + "COUNT(*) FILTER (WHERE status = 'CLOSED') AS closed_count, "
                + "(SELECT COUNT(*) FROM transactions) AS total_transactions "
                + "FROM accounts";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            SystemStats stats = new SystemStats();
            stats.totalUsers = rs.getInt("total_users");
            stats.totalAccounts = rs.getInt("total_accounts");
            stats.totalBalance = rs.getBigDecimal("total_balance");
            stats.activeCount = rs.getInt("active_count");
            stats.frozenCount = rs.getInt("frozen_count");
            stats.closedCount = rs.getInt("closed_count");
            stats.totalTransactions = rs.getInt("total_transactions");
            return stats;
        }
    }

    public static class SystemStats {
        public int totalUsers;
        public int totalAccounts;
        public BigDecimal totalBalance;
        public int activeCount;
        public int frozenCount;
        public int closedCount;
        public int totalTransactions;
    }
}
