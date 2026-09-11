package com.netbanking.dao;

import com.netbanking.model.Account;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AccountDAO {

    public Account create(Account account) throws SQLException {
        String sql = "INSERT INTO accounts (user_id, account_number, balance, status) VALUES (?, ?, ?, ?) "
                + "RETURNING account_id, created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, account.getUserId());
            ps.setString(2, account.getAccountNumber());
            ps.setBigDecimal(3, account.getBalance());
            ps.setString(4, account.getStatus());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    account.setAccountId(rs.getInt("account_id"));
                    account.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        }
        return account;
    }

    public Account findByAccountNumber(String accountNumber) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, created_at "
                + "FROM accounts WHERE account_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, accountNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public Account findByUserId(int userId) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, created_at "
                + "FROM accounts WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Fetches the account row locked (FOR UPDATE) within the caller's transaction,
     * so concurrent transfers against the same account can't both read a stale
     * balance and overdraw it. Must be called with autoCommit disabled.
     */
    public Account findByIdForUpdate(int accountId, Connection conn) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, created_at "
                + "FROM accounts WHERE account_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Transactional update: caller owns the Connection's commit/rollback so this
     * can be combined atomically with the counterpart account's update and the
     * transaction log insert (see TransferService).
     */
    public void updateBalance(int accountId, BigDecimal newBalance, Connection conn) throws SQLException {
        String sql = "UPDATE accounts SET balance = ? WHERE account_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, newBalance);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }
    }

    private Account mapRow(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountId(rs.getInt("account_id"));
        account.setUserId(rs.getInt("user_id"));
        account.setAccountNumber(rs.getString("account_number"));
        account.setBalance(rs.getBigDecimal("balance"));
        account.setStatus(rs.getString("status"));
        account.setCreatedAt(rs.getTimestamp("created_at"));
        return account;
    }
}
