package com.netbanking.service;

import com.netbanking.model.Account;
import com.netbanking.model.Transaction;

import java.util.List;

/**
 * Plain carrier for what DashboardServlet needs in one call: the user's own
 * account and their most recent transactions.
 */
public class DashboardData {

    private final Account account;
    private final List<Transaction> recentTransactions;

    public DashboardData(Account account, List<Transaction> recentTransactions) {
        this.account = account;
        this.recentTransactions = recentTransactions;
    }

    public Account getAccount() {
        return account;
    }

    public List<Transaction> getRecentTransactions() {
        return recentTransactions;
    }
}
