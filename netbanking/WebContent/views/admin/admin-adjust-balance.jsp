<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Adjust Balance - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    String direction = (String) request.getAttribute("direction");
    boolean debitChecked = "debit".equals(direction);
%>
<% String activePage = "admin-adjust-balance"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Adjust Balance</p>
            <p class="page-subtitle">Credit or debit any account. Every adjustment needs a reason and is logged.</p>
        </div>
    </div>

    <div class="card card-narrow">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/admin/adjust-balance">
            <div class="form-group">
                <label class="form-label" for="accountNumber">Account number</label>
                <input class="form-input" type="text" id="accountNumber" name="accountNumber"
                       value="<%= request.getAttribute("accountNumber") != null ? request.getAttribute("accountNumber") : "" %>" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="amount">Amount (&#8377;)</label>
                <input class="form-input" type="number" step="0.01" min="0.01" id="amount" name="amount" required>
            </div>
            <div class="form-group">
                <span class="form-label">Direction</span>
                <div class="radio-row">
                    <label class="radio-pill">
                        <input type="radio" name="direction" value="credit" <%= !debitChecked ? "checked" : "" %>>
                        Credit (add funds)
                    </label>
                    <label class="radio-pill">
                        <input type="radio" name="direction" value="debit" <%= debitChecked ? "checked" : "" %>>
                        Debit (remove funds)
                    </label>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="reason">Reason</label>
                <input class="form-input" type="text" id="reason" name="reason" placeholder="e.g. Goodwill credit, fee reversal"
                       value="<%= request.getAttribute("reason") != null ? request.getAttribute("reason") : "" %>" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Apply Adjustment</button>
        </form>
    </div>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
