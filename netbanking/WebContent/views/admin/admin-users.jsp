<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Account, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Users - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
%>
<% String activePage = "admin-users"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Manage Users</p>
            <p class="page-subtitle">Every account on NetBanking, with its holder, photo, type, and status.</p>
        </div>
        <a href="<%= request.getContextPath() %>/admin/add-user" class="btn btn-dark">+ Add user</a>
    </div>

    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("success") %></div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error"><%= request.getAttribute("error") %></div>
    <% } %>

    <div class="card">
        <% if (accounts == null || accounts.isEmpty()) { %>
            <div class="empty-state text-muted">No accounts yet.</div>
        <% } else { %>
            <div class="table-scroll">
            <table class="txn-table">
                <thead>
                    <tr>
                        <th>Photo</th>
                        <th>Holder</th>
                        <th>Email</th>
                        <th>Account number</th>
                        <th>Type</th>
                        <th class="text-right">Balance</th>
                        <th>Status</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Account account : accounts) {
                    String statusClass = account.getStatus().toLowerCase();
                    String photo = account.getHolderProfilePhoto();
                    boolean hasPhoto = photo != null && !photo.isEmpty();
                    boolean isCurrent = Account.TYPE_CURRENT.equals(account.getAccountType());
                %>
                    <tr>
                        <td>
                            <% if (hasPhoto) { %>
                                <img class="user-photo-thumb" src="<%= request.getContextPath() %>/static/uploads/profile-photos/<%= photo %>" alt="Profile photo of <%= account.getHolderName() %>">
                            <% } else { %>
                                <span class="user-photo-none">No Profile Photo</span>
                            <% } %>
                        </td>
                        <td><%= account.getHolderName() %></td>
                        <td class="text-muted"><%= account.getHolderEmail() %></td>
                        <td class="num"><%= account.getAccountNumber() %></td>
                        <td><span class="badge <%= isCurrent ? "badge-current" : "badge-savings" %>"><%= account.getAccountType() %></span></td>
                        <td class="text-right num">&#8377;<%= String.format("%,.2f", account.getBalance()) %></td>
                        <td>
                            <span class="status-pill status-pill-<%= statusClass %>">
                                <span class="status-pill-dot"></span><%= account.getStatus() %>
                            </span>
                        </td>
                        <td class="admin-row-actions">
                            <a class="btn btn-ghost btn-sm" href="<%= request.getContextPath() %>/admin/adjust-balance?accountNumber=<%= account.getAccountNumber() %>">Adjust balance</a>
                            <% if (Account.STATUS_ACTIVE.equals(account.getStatus())) { %>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" class="inline-form">
                                    <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                    <input type="hidden" name="action" value="freeze">
                                    <button type="submit" class="btn btn-ghost btn-sm">Freeze</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" class="inline-form">
                                    <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                    <input type="hidden" name="action" value="close">
                                    <button type="submit" class="btn btn-ghost btn-sm btn-danger">Close</button>
                                </form>
                            <% } else if (Account.STATUS_FROZEN.equals(account.getStatus())) { %>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" class="inline-form">
                                    <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                    <input type="hidden" name="action" value="unfreeze">
                                    <button type="submit" class="btn btn-ghost btn-sm">Unfreeze</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" class="inline-form">
                                    <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                    <input type="hidden" name="action" value="close">
                                    <button type="submit" class="btn btn-ghost btn-sm btn-danger">Close</button>
                                </form>
                            <% } else { %>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" class="inline-form">
                                    <input type="hidden" name="accountId" value="<%= account.getAccountId() %>">
                                    <input type="hidden" name="action" value="reactivate">
                                    <button type="submit" class="btn btn-ghost btn-sm">Reactivate</button>
                                </form>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            </div>
        <% } %>
    </div>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
