package com.netbanking.dao;

import com.netbanking.model.Account;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO {

    public Account create(Account account) throws SQLException {
        String sql = "INSERT INTO accounts (user_id, account_number, balance, status, account_type) "
                + "VALUES (?, ?, ?, ?, ?) RETURNING account_id, created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, account.getUserId());
            ps.setString(2, account.getAccountNumber());
            ps.setBigDecimal(3, account.getBalance());
            ps.setString(4, account.getStatus());
            ps.setString(5, account.getAccountType());
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
        String sql = "SELECT account_id, user_id, account_number, balance, status, account_type, created_at "
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

    public Account findById(int accountId) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, account_type, created_at "
                + "FROM accounts WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public Account findByUserId(int userId) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, account_type, created_at "
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
     * Admin listing: every account joined with its owner's name and email
     * (populates Account.holderName / holderEmail).
     */
    public List<Account> findAllWithHolders() throws SQLException {
        String sql = "SELECT a.account_id, a.user_id, a.account_number, a.balance, a.status, a.account_type, a.created_at, "
                + "u.full_name, u.email, u.profile_photo "
                + "FROM accounts a JOIN users u ON u.user_id = a.user_id "
                + "ORDER BY a.created_at DESC";
        List<Account> accounts = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Account account = mapRow(rs);
                account.setHolderName(rs.getString("full_name"));
                account.setHolderEmail(rs.getString("email"));
                account.setHolderProfilePhoto(rs.getString("profile_photo"));
                accounts.add(account);
            }
        }
        return accounts;
    }

    /**
     * Other active accounts (not the caller's own) for the transfer page's
     * recipient picker - lets a demo pick a payee instead of typing an account
     * number from memory. Capped to the dozen most recently created accounts;
     * only ACTIVE ones, since a suggested recipient the transfer would then
     * reject (frozen/closed) is worse than not suggesting one at all.
     */
    public List<Account> findOtherActiveAccounts(int excludeUserId) throws SQLException {
        String sql = "SELECT a.account_id, a.user_id, a.account_number, a.balance, a.status, a.account_type, a.created_at, "
                + "u.full_name "
                + "FROM accounts a JOIN users u ON u.user_id = a.user_id "
                + "WHERE a.user_id != ? AND a.status = ? "
                + "ORDER BY a.created_at DESC "
                + "LIMIT 12";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, excludeUserId);
            ps.setString(2, Account.STATUS_ACTIVE);
            try (ResultSet rs = ps.executeQuery()) {
                List<Account> accounts = new ArrayList<>();
                while (rs.next()) {
                    Account account = mapRow(rs);
                    account.setHolderName(rs.getString("full_name"));
                    accounts.add(account);
                }
                return accounts;
            }
        }
    }

    public void updateStatus(int accountId, String status) throws SQLException {
        String sql = "UPDATE accounts SET status = ? WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }
    }

    /**
     * Fetches the account row locked (FOR UPDATE) within the caller's transaction,
     * so concurrent transfers against the same account can't both read a stale
     * balance and overdraw it. Must be called with autoCommit disabled.
     */
    public Account findByIdForUpdate(int accountId, Connection conn) throws SQLException {
        String sql = "SELECT account_id, user_id, account_number, balance, status, account_type, created_at "
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
        account.setAccountType(rs.getString("account_type"));
        account.setCreatedAt(rs.getTimestamp("created_at"));
        return account;
    }
}
