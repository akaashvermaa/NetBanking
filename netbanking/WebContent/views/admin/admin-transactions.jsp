<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Transaction, java.util.List, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>All Transactions - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<% String activePage = "admin-transactions"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">All Transactions</p>
            <p class="page-subtitle">The global log &mdash; transfers and admin adjustments, newest first.</p>
        </div>
    </div>

    <div class="card">
        <% if (transactions == null || transactions.isEmpty()) { %>
            <div class="empty-state text-muted">No transactions yet.</div>
        <% } else { %>
            <div class="table-scroll">
            <table class="txn-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>From</th>
                        <th>To</th>
                        <th>Kind</th>
                        <th>Remark</th>
                        <th class="text-right">Amount</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Transaction txn : transactions) {
                    boolean isAdminCredit = Transaction.KIND_ADMIN_CREDIT.equals(txn.getKind());
                    boolean isAdminDebit = Transaction.KIND_ADMIN_DEBIT.equals(txn.getKind());
                    String kindBadgeClass = isAdminCredit ? "badge-credit" : (isAdminDebit ? "badge-debit" : "badge-transfer");
                    String amountClass = isAdminCredit ? "txn-amount credit" : (isAdminDebit ? "txn-amount debit" : "num");
                    String amountSign = isAdminCredit ? "+" : (isAdminDebit ? "-" : "");
                %>
                    <tr>
                        <td><%= sdf.format(txn.getTransactionDate()) %></td>
                        <td class="num"><%= txn.getFromAccountNumber() != null ? txn.getFromAccountNumber() : "&mdash;" %></td>
                        <td class="num"><%= txn.getToAccountNumber() != null ? txn.getToAccountNumber() : "&mdash;" %></td>
                        <td><span class="badge <%= kindBadgeClass %>"><%= txn.getKind() %></span></td>
                        <td class="text-muted"><%= (txn.getRemark() != null && !txn.getRemark().isEmpty()) ? txn.getRemark() : "&mdash;" %></td>
                        <td class="text-right <%= amountClass %>">
                            <%= amountSign %>&#8377;<%= String.format("%,.2f", txn.getAmount()) %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            </div>
        <% } %>
    </div>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
