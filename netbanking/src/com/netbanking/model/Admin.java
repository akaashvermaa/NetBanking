package com.netbanking.model;

public class Admin {

    private int adminId;
    private String fullName;
    private String email;
    private String passwordHash;

    public Admin() {
    }

    public Admin(int adminId, String fullName, String email, String passwordHash) {
        this.adminId = adminId;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
}
