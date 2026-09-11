<%@ page import="com.netbanking.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String fullName = currentUser != null ? currentUser.getFullName() : "";
    String initial = fullName.isEmpty() ? "?" : fullName.substring(0, 1).toUpperCase();
%>
<div class="app-shell">
    <aside class="sidebar">
        <div>
            <a href="<%= request.getContextPath() %>/dashboard" class="brand">
                <span class="brand-mark">NB</span>
                <span class="brand-name">NetBanking</span>
            </a>
            <nav class="sidebar-nav">
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                    Home
                </a>
                <a href="<%= request.getContextPath() %>/transfer" class="nav-item <%= "transfer".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                    Transfer
                </a>
                <a href="<%= request.getContextPath() %>/history" class="nav-item <%= "history".equals(activePage) ? "active" : "" %>">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    History
                </a>
            </nav>
        </div>
        <div class="sidebar-footer">
            <div class="avatar"><%= initial %></div>
            <div style="flex:1; min-width:0;">
                <div style="font-weight:600; font-size:13px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"><%= fullName %></div>
                <a href="<%= request.getContextPath() %>/logout" class="text-muted" style="font-size:12px; text-decoration:none;">Log out</a>
            </div>
        </div>
    </aside>
    <main class="main">
