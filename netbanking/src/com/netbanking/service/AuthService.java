package com.netbanking.service;

import com.netbanking.dao.AccountDAO;
import com.netbanking.dao.UserDAO;
import com.netbanking.model.Account;
import com.netbanking.model.User;
import com.netbanking.util.PasswordUtil;

import java.math.BigDecimal;
import java.sql.SQLException;

public class AuthService {

    private static final BigDecimal SIGNUP_BONUS = new BigDecimal("1000.00");

    private final UserDAO userDAO = new UserDAO();
    private final AccountDAO accountDAO = new AccountDAO();


    public User register(String fullName, String email, String plainPassword) throws AuthException, SQLException {
        return register(fullName, email, plainPassword, SIGNUP_BONUS, Account.TYPE_SAVINGS, null);
    }






    public User register(String fullName, String email, String plainPassword, BigDecimal openingBalance,
            String accountType, String profilePhoto) throws AuthException, SQLException {
        if (userDAO.findByEmail(email) != null) {
            throw new AuthException("Email already registered");
        }

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hash(plainPassword));
        user.setProfilePhoto(profilePhoto);
        userDAO.create(user);

        Account account = new Account();
        account.setUserId(user.getUserId());
        account.setAccountNumber(generateAccountNumber(user.getUserId()));
        account.setBalance(openingBalance);
        account.setAccountType(accountType);
        account.setStatus(Account.STATUS_ACTIVE);
        accountDAO.create(account);

        return user;
    }

    public User login(String email, String plainPassword) throws AuthException, SQLException {
        User user = userDAO.findByEmail(email);
        if (user == null || !PasswordUtil.verify(plainPassword, user.getPasswordHash())) {
            throw new AuthException("Invalid email or password");
        }

        Account account = accountDAO.findByUserId(user.getUserId());
        if (account == null) {
            throw new AuthException("No account associated with this user");
        }
        if (Account.STATUS_FROZEN.equals(account.getStatus())) {
            throw new AuthException("Your account has been frozen. Please contact support.");
        }
        if (Account.STATUS_CLOSED.equals(account.getStatus())) {
            throw new AuthException("This account has been closed.");
        }

        return user;
    }

    private String generateAccountNumber(int userId) {
        return "NB" + String.format("%010d", userId);
    }
}
