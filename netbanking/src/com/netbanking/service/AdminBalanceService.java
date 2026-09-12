package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.TransactionDAO;
import com.netbanking.model.Account;
import com.netbanking.model.Transaction;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public class AdminBalanceService {

    private final AccountDAO accountDAO = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    /**
     * Credits or debits an account and writes the audit log entry in the same DB
     * transaction, so the balance change and its record can never diverge.
     */
    public void adjust(String accountNumber, BigDecimal amount, boolean credit, String reason)
            throws AdminException, SQLException {

        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AdminException("Amount must be positive");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new AdminException("A reason is required for every adjustment");
        }

        Account account = accountDAO.findByAccountNumber(accountNumber);
        if (account == null) {
            throw new AdminException("Account not found");
        }
        if (Account.STATUS_CLOSED.equals(account.getStatus())) {
            throw new AdminException("Cannot adjust a closed account");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Account locked = accountDAO.findByIdForUpdate(account.getAccountId(), conn);
            BigDecimal newBalance = credit ? locked.getBalance().add(amount) : locked.getBalance().subtract(amount);
            if (newBalance.compareTo(BigDecimal.ZERO) < 0) {
                throw new AdminException("Debit would take the balance below zero (current: "
                        + locked.getBalance() + ")");
            }

            accountDAO.updateBalance(locked.getAccountId(), newBalance, conn);

            Transaction txn = new Transaction();
            if (credit) {
                txn.setToAccountId(locked.getAccountId());
                txn.setKind(Transaction.KIND_ADMIN_CREDIT);
            } else {
                txn.setFromAccountId(locked.getAccountId());
                txn.setKind(Transaction.KIND_ADMIN_DEBIT);
            }
            txn.setAmount(amount);
            txn.setRemark(reason.trim());
            txn.setStatus(Transaction.STATUS_SUCCESS);
            transactionDAO.insert(txn, conn);

            conn.commit();
        } catch (AdminException | SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }
}
