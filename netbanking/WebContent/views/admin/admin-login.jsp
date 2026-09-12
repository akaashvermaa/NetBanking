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
<div class="auth-shell">

    <aside class="auth-visual">
        <a href="<%= request.getContextPath() %>/admin/login" class="brand brand-on-dark">
            <span class="brand-mark">NB</span>
            <span class="brand-name">NetBanking <span class="admin-tag">Admin</span></span>
        </a>

        <div>
            <p class="eyebrow auth-visual-eyebrow">Admin console</p>
            <h2 class="auth-visual-title">System oversight, in one place.</h2>
            <ul class="auth-visual-list">
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Freeze, close or reactivate any account
                </li>
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Credit or debit balances with an audited reason
                </li>
                <li>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    A global log of every transaction on the system
                </li>
            </ul>
        </div>

        <p class="auth-visual-foot">Admin access is separate from customer accounts and is logged.</p>
    </aside>

    <main class="auth-form-panel">
        <div class="auth-form-inner">
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

            <p class="auth-footer text-muted">
                Not an admin? <a href="<%= request.getContextPath() %>/login">Customer login</a>
            </p>
        </div>
    </main>

</div>
</body>
</html>
