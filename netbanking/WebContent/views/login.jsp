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
<div class="auth-shell">

    <aside class="auth-visual">
        <a href="<%= request.getContextPath() %>/login" class="brand brand-on-dark">
            <span class="brand-mark">NB</span>
            <span class="brand-name">NetBanking</span>
        </a>

        <div>
            <p class="eyebrow auth-visual-eyebrow">Personal banking</p>
            <h2 class="auth-visual-title">Your money, always in view.</h2>
            <ul class="auth-visual-list">
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Instant transfers between NetBanking accounts
                </li>
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    A full, searchable history of every transaction
                </li>
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Passwords hashed, transfers locked against overdraft
                </li>
            </ul>
        </div>

        <p class="auth-visual-foot">NetBanking will never ask for your password or OTP by phone or email.</p>
    </aside>

    <main class="auth-form-panel">
        <div class="auth-form-inner">
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

            <p class="auth-footer text-muted">
                Don't have an account? <a href="<%= request.getContextPath() %>/register">Register</a>
            </p>
        </div>
    </main>

</div>
</body>
</html>
