package com.netbanking.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Transaction {

    public static final String TYPE_DEBIT = "DEBIT";
    public static final String TYPE_CREDIT = "CREDIT";

    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";

    public static final String KIND_TRANSFER = "TRANSFER";
    public static final String KIND_ADMIN_CREDIT = "ADMIN_CREDIT";
    public static final String KIND_ADMIN_DEBIT = "ADMIN_DEBIT";

    private int transactionId;

    private int fromAccountId;
    private int toAccountId;
    private BigDecimal amount;
    private String kind;
    private String type;
    private String remark;
    private String status;
    private Timestamp transactionDate;


    private String fromAccountNumber;
    private String toAccountNumber;

    public Transaction() {
    }

    public Transaction(int transactionId, int fromAccountId, int toAccountId, BigDecimal amount, String type,
            String remark, String status, Timestamp transactionDate) {
        this.transactionId = transactionId;
        this.fromAccountId = fromAccountId;
        this.toAccountId = toAccountId;
        this.amount = amount;
        this.type = type;
        this.remark = remark;
        this.status = status;
        this.transactionDate = transactionDate;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getFromAccountId() {
        return fromAccountId;
    }

    public void setFromAccountId(int fromAccountId) {
        this.fromAccountId = fromAccountId;
    }

    public int getToAccountId() {
        return toAccountId;
    }

    public void setToAccountId(int toAccountId) {
        this.toAccountId = toAccountId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getKind() {
        return kind;
    }

    public void setKind(String kind) {
        this.kind = kind;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getFromAccountNumber() {
        return fromAccountNumber;
    }

    public void setFromAccountNumber(String fromAccountNumber) {
        this.fromAccountNumber = fromAccountNumber;
    }

    public String getToAccountNumber() {
        return toAccountNumber;
    }

    public void setToAccountNumber(String toAccountNumber) {
        this.toAccountNumber = toAccountNumber;
    }
}
