package com.netbanking.dao;

import com.netbanking.model.Admin;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    public Admin create(Admin admin) throws SQLException {
        String sql = "INSERT INTO admins (full_name, email, password_hash) VALUES (?, ?, ?) RETURNING admin_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, admin.getFullName());
            ps.setString(2, admin.getEmail());
            ps.setString(3, admin.getPasswordHash());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    admin.setAdminId(rs.getInt("admin_id"));
                }
            }
        }
        return admin;
    }

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

    /**
     * Daily cash movement for the trailing {@code days} days (inclusive of
     * today): inflow is everything credited to any account that day (ordinary
     * transfers-in plus admin credits), outflow is everything debited from any
     * account (transfers-out plus admin debits). Days with no activity are
     * still returned with zero amounts via generate_series, so the chart
     * never has gaps.
     */
    public List<DailyFlow> getDailyCashFlow(int days) throws SQLException {
        String sql = "SELECT d.day::date AS day, "
                + "COALESCE(SUM(CASE WHEN t.to_account_id IS NOT NULL THEN t.amount END), 0) AS inflow, "
                + "COALESCE(SUM(CASE WHEN t.from_account_id IS NOT NULL THEN t.amount END), 0) AS outflow "
                + "FROM generate_series(CURRENT_DATE - make_interval(days => ?), CURRENT_DATE, INTERVAL '1 day') AS d(day) "
                + "LEFT JOIN transactions t ON t.transaction_date::date = d.day "
                + "GROUP BY d.day "
                + "ORDER BY d.day";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(days, 1) - 1);
            try (ResultSet rs = ps.executeQuery()) {
                List<DailyFlow> flows = new ArrayList<>();
                while (rs.next()) {
                    DailyFlow flow = new DailyFlow();
                    flow.day = rs.getDate("day");
                    flow.inflow = rs.getBigDecimal("inflow");
                    flow.outflow = rs.getBigDecimal("outflow");
                    flows.add(flow);
                }
                return flows;
            }
        }
    }

    public static class DailyFlow {
        public Date day;
        public BigDecimal inflow;
        public BigDecimal outflow;
    }
}
