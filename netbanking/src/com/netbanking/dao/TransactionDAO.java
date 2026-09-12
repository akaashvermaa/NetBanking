package com.netbanking.dao;

import com.netbanking.model.Transaction;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {






    public void insert(Transaction txn, Connection conn) throws SQLException {
        String sql = "INSERT INTO transactions (from_account_id, to_account_id, amount, kind, remark, status) "
                + "VALUES (?, ?, ?, ?, ?, ?) RETURNING transaction_id, transaction_date";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setAccountIdOrNull(ps, 1, txn.getFromAccountId());
            setAccountIdOrNull(ps, 2, txn.getToAccountId());
            ps.setBigDecimal(3, txn.getAmount());
            ps.setString(4, txn.getKind());
            ps.setString(5, txn.getRemark());
            ps.setString(6, txn.getStatus());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    txn.setTransactionId(rs.getInt("transaction_id"));
                    txn.setTransactionDate(rs.getTimestamp("transaction_date"));
                }
            }
        }
    }

    private static final String SELECT_COLUMNS =
            "SELECT transaction_id, from_account_id, to_account_id, amount, kind, remark, status, transaction_date ";

    public List<Transaction> findRecentByAccountId(int accountId, int limit) throws SQLException {
        String sql = SELECT_COLUMNS
                + "FROM transactions WHERE from_account_id = ? OR to_account_id = ? "
                + "ORDER BY transaction_date DESC LIMIT ?";
        return queryList(sql, accountId, limit);
    }

    public List<Transaction> findAllByAccountId(int accountId) throws SQLException {
        String sql = SELECT_COLUMNS
                + "FROM transactions WHERE from_account_id = ? OR to_account_id = ? "
                + "ORDER BY transaction_date DESC";
        return queryList(sql, accountId, null);
    }





    public List<Transaction> findAll() throws SQLException {
        String sql = "SELECT t.transaction_id, t.from_account_id, t.to_account_id, t.amount, t.kind, "
                + "t.remark, t.status, t.transaction_date, "
                + "fa.account_number AS from_account_number, ta.account_number AS to_account_number "
                + "FROM transactions t "
                + "LEFT JOIN accounts fa ON fa.account_id = t.from_account_id "
                + "LEFT JOIN accounts ta ON ta.account_id = t.to_account_id "
                + "ORDER BY t.transaction_date DESC";
        List<Transaction> transactions = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Transaction txn = mapRow(rs, null);
                txn.setFromAccountNumber(rs.getString("from_account_number"));
                txn.setToAccountNumber(rs.getString("to_account_number"));
                transactions.add(txn);
            }
        }
        return transactions;
    }

    private void setAccountIdOrNull(PreparedStatement ps, int index, int accountId) throws SQLException {
        if (accountId == 0) {
            ps.setNull(index, java.sql.Types.INTEGER);
        } else {
            ps.setInt(index, accountId);
        }
    }

    public BigDecimal getTotalSent(int accountId) throws SQLException {
        return sumWhere("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE from_account_id = ?", accountId);
    }

    public BigDecimal getTotalReceived(int accountId) throws SQLException {
        return sumWhere("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE to_account_id = ?", accountId);
    }

    private BigDecimal sumWhere(String sql, int accountId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
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






    private Transaction mapRow(ResultSet rs, Integer perspectiveAccountId) throws SQLException {
        Transaction txn = new Transaction();
        txn.setTransactionId(rs.getInt("transaction_id"));
        txn.setFromAccountId(rs.getInt("from_account_id"));
        txn.setToAccountId(rs.getInt("to_account_id"));
        txn.setAmount(rs.getBigDecimal("amount"));
        txn.setKind(rs.getString("kind"));
        txn.setRemark(rs.getString("remark"));
        txn.setStatus(rs.getString("status"));
        txn.setTransactionDate(rs.getTimestamp("transaction_date"));
        if (perspectiveAccountId != null) {
            txn.setType(txn.getFromAccountId() == perspectiveAccountId
                    ? Transaction.TYPE_DEBIT : Transaction.TYPE_CREDIT);
        }
        return txn;
    }
}
