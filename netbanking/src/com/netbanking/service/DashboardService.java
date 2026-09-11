package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.TransactionDAO;
import com.netbanking.model.Account;
import com.netbanking.model.Transaction;

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
        return new DashboardData(account, recentTransactions);
    }

    public List<Transaction> getFullHistory(int userId) throws SQLException {
        Account account = accountDAO.findByUserId(userId);
        return transactionDAO.findAllByAccountId(account.getAccountId());
    }
}
