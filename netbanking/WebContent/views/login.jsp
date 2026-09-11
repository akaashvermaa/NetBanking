<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log In - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card">
        <a href="<%= request.getContextPath() %>/login" class="brand">
            <span class="brand-mark">NB</span>
            <span class="brand-name">NetBanking</span>
        </a>
        <h1>Welcome back.</h1>
        <p class="subtitle text-muted">Log in to manage your account.</p>

        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success">Registration successful. Please log in.</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
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
            Don't have an account? <a href="<%= request.getContextPath() %>/register">Register</a>
        </div>
    </div>
</div>
</body>
</html>
