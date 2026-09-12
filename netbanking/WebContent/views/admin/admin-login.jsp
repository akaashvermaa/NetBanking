<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Login - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card">
        <a href="<%= request.getContextPath() %>/admin/login" class="brand">
            <span class="brand-mark">NB</span>
            <span class="brand-name">NetBanking <span class="admin-tag">Admin</span></span>
        </a>
        <h1>Admin access.</h1>
        <p class="subtitle text-muted">Sign in to manage NetBanking.</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/admin/login">
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <input class="form-input" type="email" id="email" name="email"
                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input class="form-input" type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Log In</button>
        </form>

        <div class="auth-footer text-muted">
            Not an admin? <a href="<%= request.getContextPath() %>/login">Customer login</a>
        </div>
    </div>
</div>
</body>
</html>
