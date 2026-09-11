<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.model.Account, com.netbanking.model.Transaction, com.netbanking.model.User,
                 java.math.BigDecimal, java.util.List, java.text.SimpleDateFormat, java.util.Random" %>
<%!
    private static final String[] MONEY_TIPS = {
        "A budget is telling your money where to go instead of wondering where it went.",
        "Do not save what is left after spending; spend what is left after saving.",
        "Small amounts saved consistently build large fortunes over time.",
        "The best time to start saving was yesterday. The next best time is today.",
        "Never spend your money before you have earned it.",
        "Beware of little expenses; a small leak will sink a great ship.",
        "It's not how much money you make, but how much you keep.",
        "Track every rupee. What gets measured gets managed."
    };
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    Account account = (Account) request.getAttribute("account");
    List<Transaction> recentTransactions = (List<Transaction>) request.getAttribute("recentTransactions");
    BigDecimal totalSent = (BigDecimal) request.getAttribute("totalSent");
    BigDecimal totalReceived = (BigDecimal) request.getAttribute("totalReceived");
    BigDecimal netFlow = totalReceived.subtract(totalSent);
    boolean netPositive = netFlow.signum() >= 0;

    SimpleDateFormat dateTimeFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    SimpleDateFormat monthFmt = new SimpleDateFormat("MMM yyyy");
    String today = new SimpleDateFormat("EEEE, dd MMM yyyy").format(new java.util.Date());
    String moneyTip = MONEY_TIPS[new Random().nextInt(MONEY_TIPS.length)];

    User currentUser = (User) session.getAttribute("user");
    String fullName = currentUser.getFullName();
    String firstName = fullName.trim().split("\\s+")[0];
    String statusClass = account.getStatus().toLowerCase();
%>
<% String activePage = "dashboard"; %>
<%@ include file="fragments/sidebar-start.jsp" %>

<div class="db-page">

    <header class="db-header">
        <div>
            <h1 class="db-greeting">Good to see you, <%= firstName %>.</h1>
            <p class="db-subtitle">Here's a clear view of your money.</p>
        </div>
        <p class="db-date"><%= today %></p>
    </header>

    <section class="db-hero">

        <article class="db-balance">
            <div class="db-balance-top">
                <span class="db-label db-label-dark">Available balance</span>
                <span class="db-status db-status-<%= statusClass %>">
                    <span class="db-status-dot"></span><%= account.getStatus() %>
                </span>
            </div>
            <p class="db-balance-amount num">&#8377;<%= String.format("%,.2f", account.getBalance()) %></p>
            <p class="db-balance-meta">Account <span class="num"><%= account.getAccountNumber() %></span></p>
        </article>

        <nav class="db-actions" aria-label="Quick actions">
            <a href="<%= request.getContextPath() %>/transfer" class="db-action db-action-primary">
                <span class="db-action-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                </span>
                <span class="db-action-text">
                    <strong>Send money</strong>
                    <span>Transfer to another account</span>
                </span>
            </a>
            <a href="<%= request.getContextPath() %>/history" class="db-action">
                <span class="db-action-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </span>
                <span class="db-action-text">
                    <strong>Transaction history</strong>
                    <span>Everything on this account</span>
                </span>
            </a>
        </nav>

    </section>

    <section class="db-stats">
        <article class="db-stat">
            <span class="db-label">Received</span>
            <p class="db-stat-value num gain">+&#8377;<%= String.format("%,.2f", totalReceived) %></p>
            <span class="db-stat-caption">Money in, all time</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Sent</span>
            <p class="db-stat-value num loss">&minus;&#8377;<%= String.format("%,.2f", totalSent) %></p>
            <span class="db-stat-caption">Money out, all time</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Net flow</span>
            <p class="db-stat-value num <%= netPositive ? "gain" : "loss" %>"><%= netPositive ? "+" : "&minus;" %>&#8377;<%= String.format("%,.2f", netFlow.abs()) %></p>
            <span class="db-stat-caption">Received minus sent</span>
        </article>
    </section>

    <section class="db-main">

        <article class="db-card db-transactions">
            <div class="db-card-head">
                <h2>Recent transactions</h2>
                <a href="<%= request.getContextPath() %>/history" class="db-link">View all</a>
            </div>

            <% if (recentTransactions == null || recentTransactions.isEmpty()) { %>
                <div class="db-empty">
                    <p class="db-empty-title">No transactions yet</p>
                    <p>Send money to someone and it will show up here.</p>
                </div>
            <% } else { %>
                <ul class="db-txn-list">
                    <% for (Transaction txn : recentTransactions) {
                        boolean isDebit = Transaction.TYPE_DEBIT.equals(txn.getType());
                        boolean hasRemark = txn.getRemark() != null && !txn.getRemark().isEmpty();
                    %>
                    <li class="db-txn">
                        <span class="db-txn-mark <%= isDebit ? "loss" : "gain" %>"><%= isDebit ? "&minus;" : "+" %></span>
                        <span class="db-txn-info">
                            <strong><%= hasRemark ? txn.getRemark() : (isDebit ? "Sent" : "Received") %></strong>
                            <span><%= dateTimeFmt.format(txn.getTransactionDate()) %><%= hasRemark ? (isDebit ? " &middot; Sent" : " &middot; Received") : "" %></span>
                        </span>
                        <span class="db-txn-amount num <%= isDebit ? "loss" : "gain" %>"><%= isDebit ? "&minus;" : "+" %>&#8377;<%= String.format("%,.2f", txn.getAmount()) %></span>
                    </li>
                    <% } %>
                </ul>
            <% } %>
        </article>

        <aside class="db-side">

            <article class="db-card db-tip">
                <p class="db-tip-text">&ldquo;<%= moneyTip %>&rdquo;</p>
            </article>

            <article class="db-card db-details" id="details">
                <h2>Account details</h2>
                <dl class="db-detail-list">
                    <div><dt>Holder</dt><dd><%= fullName %></dd></div>
                    <div><dt>Account number</dt><dd class="num"><%= account.getAccountNumber() %></dd></div>
                    <div><dt>Member since</dt><dd><%= monthFmt.format(account.getCreatedAt()) %></dd></div>
                    <div><dt>Status</dt><dd><%= account.getStatus() %></dd></div>
                </dl>
            </article>

            <p class="db-security">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                Never share your password or OTP. NetBanking will never ask for them by phone or email.
            </p>

        </aside>

    </section>

</div>

<%@ include file="fragments/sidebar-end.jsp" %>
</body>
</html>
