<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Transfer - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<% String activePage = "transfer"; %>
<%@ include file="fragments/sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Send Money</p>
            <p class="page-subtitle">Transfer funds to another NetBanking account.</p>
        </div>
    </div>

    <div class="card" style="max-width: 480px;">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/transfer">
            <div class="form-group">
                <label class="form-label" for="recipientAccountNumber">Recipient account number</label>
                <input class="form-input" type="text" id="recipientAccountNumber" name="recipientAccountNumber" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="amount">Amount (&#8377;)</label>
                <input class="form-input" type="number" step="0.01" min="0.01" id="amount" name="amount" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="remark">Remark (optional)</label>
                <input class="form-input" type="text" id="remark" name="remark" placeholder="e.g. Rent, dinner split">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Send Money</button>
        </form>
    </div>

<%@ include file="fragments/sidebar-end.jsp" %>
</body>
</html>
