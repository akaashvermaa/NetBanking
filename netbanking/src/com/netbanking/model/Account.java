package com.netbanking.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Account {

    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_FROZEN = "FROZEN";
    public static final String STATUS_CLOSED = "CLOSED";

    public static final String TYPE_SAVINGS = "SAVINGS";
    public static final String TYPE_CURRENT = "CURRENT";

    private int accountId;
    private int userId;
    private String accountNumber;
    private BigDecimal balance;
    private String status;
    private String accountType;
    private Timestamp createdAt;


    private String holderName;
    private String holderEmail;
    private String holderProfilePhoto;

    public Account() {
    }

    public Account(int accountId, int userId, String accountNumber, BigDecimal balance, String status,
            Timestamp createdAt) {
        this.accountId = accountId;
        this.userId = userId;
        this.accountNumber = accountNumber;
        this.balance = balance;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getHolderName() {
        return holderName;
    }

    public void setHolderName(String holderName) {
        this.holderName = holderName;
    }

    public String getHolderEmail() {
        return holderEmail;
    }

    public void setHolderEmail(String holderEmail) {
        this.holderEmail = holderEmail;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getHolderProfilePhoto() {
        return holderProfilePhoto;
    }

    public void setHolderProfilePhoto(String holderProfilePhoto) {
        this.holderProfilePhoto = holderProfilePhoto;
    }
}
