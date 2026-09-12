<%@ page import="com.netbanking.model.Admin" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("admin");
    String adminName = currentAdmin != null ? currentAdmin.getFullName() : "";
    String adminInitial = adminName.isEmpty() ? "?" : adminName.substring(0, 1).toUpperCase();
%>
<div class="app-shell">
    <aside class="sidebar">
        <div>
            <a href="<%= request.getContextPath() %>/admin/dashboard" class="brand">
                <span class="brand-mark">NB</span>
                <span class="brand-name">NetBanking <span class="admin-tag">Admin</span></span>
            </a>
            <nav class="sidebar-nav">
                <a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-item <%= "admin-dashboard".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/users" class="nav-item <%= "admin-users".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    Users
                </a>
                <a href="<%= request.getContextPath() %>/admin/add-user" class="nav-item <%= "admin-add-user".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                    Add User
                </a>
                <a href="<%= request.getContextPath() %>/admin/adjust-balance" class="nav-item <%= "admin-adjust-balance".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    Adjust Balance
                </a>
                <a href="<%= request.getContextPath() %>/admin/transactions" class="nav-item <%= "admin-transactions".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    Transactions
                </a>
            </nav>
        </div>
        <div class="sidebar-footer">
            <div class="avatar"><%= adminInitial %></div>
            <div style="flex:1; min-width:0;">
                <div style="font-weight:600; font-size:13px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"><%= adminName %></div>
                <a href="<%= request.getContextPath() %>/admin/logout" class="text-muted" style="font-size:12px; text-decoration:none;">Log out</a>
            </div>
        </div>
    </aside>
    <main class="main">
