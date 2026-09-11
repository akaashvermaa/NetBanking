package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.TransactionDAO;
import com.netbanking.model.Account;
import com.netbanking.model.Transaction;
import com.netbanking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public class TransferService {

    private final AccountDAO accountDAO = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    public void transfer(int senderUserId, String recipientAccountNumber, BigDecimal amount, String remark)
            throws TransferException, SQLException {

        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new TransferException("Transfer amount must be positive");
        }

        Account sender = accountDAO.findByUserId(senderUserId);
        if (sender == null) {
            throw new TransferException("Sender account not found");
        }
        Account recipient = accountDAO.findByAccountNumber(recipientAccountNumber);
        if (recipient == null) {
            throw new TransferException("Recipient account not found");
        }
        if (sender.getAccountId() == recipient.getAccountId()) {
            throw new TransferException("Cannot transfer to your own account");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Re-fetch with row locks inside the transaction so concurrent transfers
            // against the same account can't both read a stale balance and overdraw it.
            Account lockedSender = accountDAO.findByIdForUpdate(sender.getAccountId(), conn);
            Account lockedRecipient = accountDAO.findByIdForUpdate(recipient.getAccountId(), conn);

            if (Account.STATUS_FROZEN.equals(lockedSender.getStatus())) {
                throw new TransferException("Your account is frozen and cannot make transfers");
            }
            if (Account.STATUS_FROZEN.equals(lockedRecipient.getStatus())) {
                throw new TransferException("Recipient account is frozen and cannot receive transfers");
            }
            if (lockedSender.getBalance().compareTo(amount) < 0) {
                throw new TransferException("Insufficient balance");
            }

            accountDAO.updateBalance(lockedSender.getAccountId(), lockedSender.getBalance().subtract(amount), conn);
            accountDAO.updateBalance(lockedRecipient.getAccountId(), lockedRecipient.getBalance().add(amount), conn);

            Transaction txn = new Transaction();
            txn.setFromAccountId(lockedSender.getAccountId());
            txn.setToAccountId(lockedRecipient.getAccountId());
            txn.setAmount(amount);
            txn.setRemark(remark);
            txn.setStatus(Transaction.STATUS_SUCCESS);
            transactionDAO.insert(txn, conn);

            conn.commit();
        } catch (TransferException | SQLException e) {
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
