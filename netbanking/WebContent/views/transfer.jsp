<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Account, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Transfer - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    List<Account> recipients = (List<Account>) request.getAttribute("recipients");
    boolean hasRecipients = recipients != null && !recipients.isEmpty();
%>
<% String activePage = "transfer"; %>
<%@ include file="fragments/sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Send Money</p>
            <p class="page-subtitle">Transfer funds to another NetBanking account.</p>
        </div>
    </div>

    <div class="transfer-layout">

        <section class="card recipients-card">
            <h2>Send to</h2>
            <p class="page-subtitle recipients-subtitle">Pick a recipient to fill in their account number, or enter one manually.</p>

            <% if (!hasRecipients) { %>
                <div class="empty-state text-muted">
                    No other active accounts yet &mdash; enter a recipient's account number manually below.
                </div>
            <% } else { %>
                <div class="recipient-grid">
                    <% for (Account r : recipients) {
                        String rName = r.getHolderName();
                        String rInitial = (rName == null || rName.isEmpty()) ? "?" : String.valueOf(Character.toUpperCase(rName.charAt(0)));
                        boolean rCurrent = Account.TYPE_CURRENT.equals(r.getAccountType());
                    %>
                    <button type="button" class="recipient-chip" data-account="<%= r.getAccountNumber() %>" data-name="<%= rName %>">
                        <span class="avatar recipient-avatar"><%= rInitial %></span>
                        <span class="recipient-info">
                            <strong><%= rName %></strong>
                            <span class="num"><%= r.getAccountNumber() %></span>
                        </span>
                        <span class="badge <%= rCurrent ? "badge-current" : "badge-savings" %> recipient-type"><%= r.getAccountType() %></span>
                    </button>
                    <% } %>
                </div>
            <% } %>
        </section>

        <section class="card transfer-form-card">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success"><%= request.getAttribute("success") %></div>
            <% } %>

            <p id="selectedRecipient" class="selected-recipient" hidden>
                Sending to <strong id="selectedRecipientName"></strong>
            </p>

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
        </section>

    </div>

    <% if (hasRecipients) { %>
    <script>
    (function () {
        var chips = document.querySelectorAll(".recipient-chip");
        var accountInput = document.getElementById("recipientAccountNumber");
        var amountInput = document.getElementById("amount");
        var selectedNote = document.getElementById("selectedRecipient");
        var selectedName = document.getElementById("selectedRecipientName");

        chips.forEach(function (chip) {
            chip.addEventListener("click", function () {
                accountInput.value = chip.getAttribute("data-account");
                selectedName.textContent = chip.getAttribute("data-name");
                selectedNote.hidden = false;
                chips.forEach(function (c) { c.classList.remove("recipient-chip-active"); });
                chip.classList.add("recipient-chip-active");
                amountInput.focus();
            });
        });
    })();
    </script>
    <% } %>

<%@ include file="fragments/sidebar-end.jsp" %>
</body>
</html>
