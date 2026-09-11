package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.TransactionDAO;
import com.netbanking.model.Account;
import com.netbanking.model.Transaction;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

public class DashboardService {

    private static final int RECENT_TRANSACTIONS_LIMIT = 5;

    private final AccountDAO accountDAO = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    public DashboardData getDashboardData(int userId) throws SQLException {
        Account account = accountDAO.findByUserId(userId);
        List<Transaction> recentTransactions =
                transactionDAO.findRecentByAccountId(account.getAccountId(), RECENT_TRANSACTIONS_LIMIT);
        BigDecimal totalSent = transactionDAO.getTotalSent(account.getAccountId());
        BigDecimal totalReceived = transactionDAO.getTotalReceived(account.getAccountId());
        return new DashboardData(account, recentTransactions, totalSent, totalReceived);
    }

    public List<Transaction> getFullHistory(int userId) throws SQLException {
        Account account = accountDAO.findByUserId(userId);
        return transactionDAO.findAllByAccountId(account.getAccountId());
    }
}
