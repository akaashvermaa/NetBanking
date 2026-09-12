<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Transaction, java.util.List, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>History - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<% String activePage = "history"; %>
<%@ include file="fragments/sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Transaction History</p>
            <p class="page-subtitle">Everything that's happened on your account.</p>
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
                        <th>Type</th>
                        <th>Remark</th>
                        <th class="text-right">Amount</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Transaction txn : transactions) {
                    boolean isDebit = Transaction.TYPE_DEBIT.equals(txn.getType());
                %>
                    <tr>
                        <td><%= sdf.format(txn.getTransactionDate()) %></td>
                        <td><span class="badge <%= isDebit ? "badge-debit" : "badge-credit" %>"><%= txn.getType() %></span></td>
                        <td class="text-muted"><%= (txn.getRemark() != null && !txn.getRemark().isEmpty()) ? txn.getRemark() : "&mdash;" %></td>
                        <td class="text-right <%= isDebit ? "txn-amount debit" : "txn-amount credit" %>">
                            <%= isDebit ? "-" : "+" %>&#8377;<%= String.format("%,.2f", txn.getAmount()) %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            </div>
        <% } %>
    </div>

<%@ include file="fragments/sidebar-end.jsp" %>
</body>
</html>
