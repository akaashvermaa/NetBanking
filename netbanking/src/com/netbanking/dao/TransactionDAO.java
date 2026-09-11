package com.netbanking.dao;

import com.netbanking.model.Transaction;
import com.netbanking.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    /**
     * Transactional insert: caller owns the Connection's commit/rollback so this
     * can be combined atomically with both accounts' balance updates (see
     * TransferService).
     */
    public void insert(Transaction txn, Connection conn) throws SQLException {
        String sql = "INSERT INTO transactions (from_account_id, to_account_id, amount, remark, status) "
                + "VALUES (?, ?, ?, ?, ?) RETURNING transaction_id, transaction_date";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, txn.getFromAccountId());
            ps.setInt(2, txn.getToAccountId());
            ps.setBigDecimal(3, txn.getAmount());
            ps.setString(4, txn.getRemark());
            ps.setString(5, txn.getStatus());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    txn.setTransactionId(rs.getInt("transaction_id"));
                    txn.setTransactionDate(rs.getTimestamp("transaction_date"));
                }
            }
        }
    }

    public List<Transaction> findRecentByAccountId(int accountId, int limit) throws SQLException {
        String sql = "SELECT transaction_id, from_account_id, to_account_id, amount, remark, status, transaction_date "
                + "FROM transactions WHERE from_account_id = ? OR to_account_id = ? "
                + "ORDER BY transaction_date DESC LIMIT ?";
        return queryList(sql, accountId, limit);
    }

    public List<Transaction> findAllByAccountId(int accountId) throws SQLException {
        String sql = "SELECT transaction_id, from_account_id, to_account_id, amount, remark, status, transaction_date "
                + "FROM transactions WHERE from_account_id = ? OR to_account_id = ? "
                + "ORDER BY transaction_date DESC";
        return queryList(sql, accountId, null);
    }

    private List<Transaction> queryList(String sql, int accountId, Integer limit) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, accountId);
            if (limit != null) {
                ps.setInt(3, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapRow(rs, accountId));
                }
            }
        }
        return transactions;
    }

    /**
     * A transfer row has no stored DEBIT/CREDIT column (it depends on which side
     * you're viewing it from), so type is derived here relative to the account
     * whose history is being fetched.
     */
    private Transaction mapRow(ResultSet rs, int perspectiveAccountId) throws SQLException {
        Transaction txn = new Transaction();
        txn.setTransactionId(rs.getInt("transaction_id"));
        txn.setFromAccountId(rs.getInt("from_account_id"));
        txn.setToAccountId(rs.getInt("to_account_id"));
        txn.setAmount(rs.getBigDecimal("amount"));
        txn.setRemark(rs.getString("remark"));
        txn.setStatus(rs.getString("status"));
        txn.setTransactionDate(rs.getTimestamp("transaction_date"));
        txn.setType(txn.getFromAccountId() == perspectiveAccountId ? Transaction.TYPE_DEBIT : Transaction.TYPE_CREDIT);
        return txn;
    }
}
