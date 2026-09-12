<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add User - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<% String activePage = "admin-add-user"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Add User</p>
            <p class="page-subtitle">Create a customer account the same way self-registration does.</p>
        </div>
    </div>

    <div class="card card-narrow">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/admin/add-user">
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
            <button type="submit" class="btn btn-primary btn-block">Create User</button>
        </form>
    </div>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
