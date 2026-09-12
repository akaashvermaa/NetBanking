package com.netbanking.service;

import com.netbanking.model.Account;
import com.netbanking.model.Transaction;

import java.math.BigDecimal;
import java.util.List;





public class DashboardData {

    private final Account account;
    private final List<Transaction> recentTransactions;
    private final BigDecimal totalSent;
    private final BigDecimal totalReceived;

    public DashboardData(Account account, List<Transaction> recentTransactions,
            BigDecimal totalSent, BigDecimal totalReceived) {
        this.account = account;
        this.recentTransactions = recentTransactions;
        this.totalSent = totalSent;
        this.totalReceived = totalReceived;
    }

    public Account getAccount() {
        return account;
    }

    public List<Transaction> getRecentTransactions() {
        return recentTransactions;
    }

    public BigDecimal getTotalSent() {
        return totalSent;
    }

    public BigDecimal getTotalReceived() {
        return totalReceived;
    }
}
