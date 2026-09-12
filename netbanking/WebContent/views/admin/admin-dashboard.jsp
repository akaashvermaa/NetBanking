<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.dao.AdminDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    AdminDAO.SystemStats stats = (AdminDAO.SystemStats) request.getAttribute("stats");
%>
<% String activePage = "admin-dashboard"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Admin Dashboard</p>
            <p class="page-subtitle">System-wide overview of NetBanking.</p>
        </div>
    </div>

    <section class="db-stats admin-stats">
        <article class="db-stat">
            <span class="db-label">Total users</span>
            <p class="db-stat-value num"><%= stats.totalUsers %></p>
            <span class="db-stat-caption">Registered customers</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total accounts</span>
            <p class="db-stat-value num"><%= stats.totalAccounts %></p>
            <span class="db-stat-caption">Across all statuses</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total balance</span>
            <p class="db-stat-value num">&#8377;<%= String.format("%,.2f", stats.totalBalance) %></p>
            <span class="db-stat-caption">Held across all accounts</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total transactions</span>
            <p class="db-stat-value num"><%= stats.totalTransactions %></p>
            <span class="db-stat-caption">Transfers &amp; admin adjustments</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Active</span>
            <p class="db-stat-value num gain"><%= stats.activeCount %></p>
            <span class="db-stat-caption">Accounts in good standing</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Frozen</span>
            <p class="db-stat-value num" style="color:#B45309;"><%= stats.frozenCount %></p>
            <span class="db-stat-caption">Temporarily suspended</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Closed</span>
            <p class="db-stat-value num loss"><%= stats.closedCount %></p>
            <span class="db-stat-caption">No longer active</span>
        </article>
    </section>

    <section class="card admin-quick-links">
        <h2>Quick actions</h2>
        <div class="admin-quick-links-row">
            <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost">Manage users</a>
            <a href="<%= request.getContextPath() %>/admin/add-user" class="btn btn-ghost">Add a user</a>
            <a href="<%= request.getContextPath() %>/admin/adjust-balance" class="btn btn-ghost">Adjust a balance</a>
            <a href="<%= request.getContextPath() %>/admin/transactions" class="btn btn-ghost">View all transactions</a>
        </div>
    </section>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
