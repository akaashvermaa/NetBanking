package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.AdminDAO;
import com.netbanking.dao.TransactionDAO;
import com.netbanking.model.Account;
import com.netbanking.model.Transaction;
import com.netbanking.model.User;

import java.sql.SQLException;
import java.util.List;

public class AdminUserService {

    private final AccountDAO accountDAO = new AccountDAO();
    private final AdminDAO adminDAO = new AdminDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final AuthService authService = new AuthService();

    public AdminDAO.SystemStats getSystemStats() throws SQLException {
        return adminDAO.getSystemStats();
    }

    public List<Account> listAccounts() throws SQLException {
        return accountDAO.findAllWithHolders();
    }

    public List<Transaction> listAllTransactions() throws SQLException {
        return transactionDAO.findAll();
    }

    /** Admin-created users go through exactly the same path as self-registration. */
    public Account createUser(String fullName, String email, String plainPassword) throws AuthException, SQLException {
        User user = authService.register(fullName, email, plainPassword);
        Account account = accountDAO.findByUserId(user.getUserId());
        account.setHolderName(user.getFullName());
        account.setHolderEmail(user.getEmail());
        return account;
    }

    public void freeze(int accountId) throws AdminException, SQLException {
        transition(accountId, Account.STATUS_ACTIVE, Account.STATUS_FROZEN, "Only active accounts can be frozen");
    }

    public void unfreeze(int accountId) throws AdminException, SQLException {
        transition(accountId, Account.STATUS_FROZEN, Account.STATUS_ACTIVE, "Only frozen accounts can be unfrozen");
    }

    public void close(int accountId) throws AdminException, SQLException {
        Account account = requireAccount(accountId);
        if (Account.STATUS_CLOSED.equals(account.getStatus())) {
            throw new AdminException("Account is already closed");
        }
        accountDAO.updateStatus(accountId, Account.STATUS_CLOSED);
    }

    public void reactivate(int accountId) throws AdminException, SQLException {
        transition(accountId, Account.STATUS_CLOSED, Account.STATUS_ACTIVE, "Only closed accounts can be reactivated");
    }

    private void transition(int accountId, String from, String to, String errorMessage)
            throws AdminException, SQLException {
        Account account = requireAccount(accountId);
        if (!from.equals(account.getStatus())) {
            throw new AdminException(errorMessage);
        }
        accountDAO.updateStatus(accountId, to);
    }

    private Account requireAccount(int accountId) throws AdminException, SQLException {
        Account account = accountDAO.findById(accountId);
        if (account == null) {
            throw new AdminException("Account not found");
        }
        return account;
    }
}
