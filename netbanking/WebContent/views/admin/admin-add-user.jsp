<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Account" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add User - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    String openingBalance = (String) request.getAttribute("openingBalance");
    if (openingBalance == null) {
        openingBalance = "1000";
    }
    String accountType = (String) request.getAttribute("accountType");
    boolean currentChecked = Account.TYPE_CURRENT.equals(accountType);
%>
<% String activePage = "admin-add-user"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Add User</p>
            <p class="page-subtitle">Create a customer account with a chosen opening credit, account type, and photo.</p>
        </div>
    </div>

    <div class="card card-narrow">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/admin/add-user" enctype="multipart/form-data">
            <div class="form-group">
                <label class="form-label" for="fullName">Full name</label>
                <input class="form-input" type="text" id="fullName" name="fullName"
                       value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <input class="form-input" type="email" id="email" name="email"
                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input class="form-input" type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirm password</label>
                <input class="form-input" type="password" id="confirmPassword" name="confirmPassword" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="openingBalance">Opening credit (&#8377;)</label>
                <input class="form-input" type="number" step="0.01" min="0" id="openingBalance" name="openingBalance"
                       value="<%= openingBalance %>" required>
                <span class="form-hint">Defaults to &#8377;1,000 &mdash; set it to whatever this customer should start with, including &#8377;0.</span>
            </div>

            <div class="form-group">
                <span class="form-label">Account type</span>
                <div class="radio-row">
                    <label class="radio-pill">
                        <input type="radio" name="accountType" value="<%= Account.TYPE_SAVINGS %>" <%= !currentChecked ? "checked" : "" %>>
                        Savings
                    </label>
                    <label class="radio-pill">
                        <input type="radio" name="accountType" value="<%= Account.TYPE_CURRENT %>" <%= currentChecked ? "checked" : "" %>>
                        Current
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="profilePhoto">Profile photo (optional)</label>
                <input class="form-input" type="file" id="profilePhoto" name="profilePhoto" accept="image/jpeg,image/png,image/webp">
                <span class="form-hint">JPG, PNG, or WEBP, up to 2MB.</span>
            </div>

            <button type="submit" class="btn btn-primary btn-block">Create User</button>
        </form>
    </div>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
