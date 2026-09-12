<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.netbanking.dao.AdminDAO, java.util.List, java.text.SimpleDateFormat" %>
<%!
    // Rounds a value up to a "nice" axis maximum (1/2/5/10 x a power of ten)
    // so gridline labels read as clean numbers instead of odd fractions.
    private static double niceCeiling(double value) {
        if (value <= 0) {
            return 100;
        }
        double magnitude = Math.pow(10, Math.floor(Math.log10(value)));
        double normalized = value / magnitude;
        double niceNormalized;
        if (normalized <= 1) {
            niceNormalized = 1;
        } else if (normalized <= 2) {
            niceNormalized = 2;
        } else if (normalized <= 5) {
            niceNormalized = 5;
        } else {
            niceNormalized = 10;
        }
        return niceNormalized * magnitude;
    }

    private static String compact(double value) {
        if (value >= 1_000_000) {
            return String.format("%.1fM", value / 1_000_000);
        }
        if (value >= 1_000) {
            return String.format("%.1fK", value / 1_000);
        }
        return String.format("%,.0f", value);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard - NetBanking</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/style.css">
</head>
<body>
<%
    AdminDAO.SystemStats stats = (AdminDAO.SystemStats) request.getAttribute("stats");

    List<AdminDAO.DailyFlow> cashFlow = (List<AdminDAO.DailyFlow>) request.getAttribute("cashFlow");
    int flowCount = cashFlow != null ? cashFlow.size() : 0;

    final int chartW = 720;
    final int chartH = 240;
    final int marginLeft = 60;
    final int marginRight = 12;
    final int marginTop = 16;
    final int marginBottom = 28;
    final int plotW = chartW - marginLeft - marginRight;
    final int plotH = chartH - marginTop - marginBottom;

    double[] inflowVals = new double[flowCount];
    double[] outflowVals = new double[flowCount];
    String[] dayLabels = new String[flowCount];
    double maxVal = 0;

    SimpleDateFormat axisFmt = new SimpleDateFormat("d MMM");
    for (int i = 0; i < flowCount; i++) {
        AdminDAO.DailyFlow flow = cashFlow.get(i);
        inflowVals[i] = flow.inflow.doubleValue();
        outflowVals[i] = flow.outflow.doubleValue();
        dayLabels[i] = axisFmt.format(flow.day);
        maxVal = Math.max(maxVal, Math.max(inflowVals[i], outflowVals[i]));
    }
    double axisMax = niceCeiling(maxVal);

    double xStep = flowCount > 1 ? (double) plotW / (flowCount - 1) : 0;
    double[] px = new double[flowCount];
    double[] inflowPy = new double[flowCount];
    double[] outflowPy = new double[flowCount];
    StringBuilder inflowPoints = new StringBuilder();
    StringBuilder outflowPoints = new StringBuilder();
    StringBuilder chartData = new StringBuilder("[");

    for (int i = 0; i < flowCount; i++) {
        px[i] = marginLeft + i * xStep;
        inflowPy[i] = marginTop + plotH - (axisMax > 0 ? (inflowVals[i] / axisMax) * plotH : 0);
        outflowPy[i] = marginTop + plotH - (axisMax > 0 ? (outflowVals[i] / axisMax) * plotH : 0);

        if (i > 0) {
            inflowPoints.append(" ");
            outflowPoints.append(" ");
            chartData.append(",");
        }
        inflowPoints.append(String.format("%.1f,%.1f", px[i], inflowPy[i]));
        outflowPoints.append(String.format("%.1f,%.1f", px[i], outflowPy[i]));
        chartData.append("{\"x\":").append(px[i])
                .append(",\"label\":\"").append(dayLabels[i]).append("\"")
                .append(",\"inflow\":").append(inflowVals[i])
                .append(",\"outflow\":").append(outflowVals[i])
                .append("}");
    }
    chartData.append("]");

    int labelStep = Math.max(1, (int) Math.ceil(flowCount / 6.0));
    boolean showEndLabels = flowCount > 0 && Math.abs(inflowPy[flowCount - 1] - outflowPy[flowCount - 1]) >= 18;
%>
<% String activePage = "admin-dashboard"; %>
<%@ include file="fragments/admin-sidebar-start.jsp" %>

    <div class="topbar">
        <div>
            <p class="page-title">Admin Dashboard</p>
            <p class="page-subtitle">System-wide overview of NetBanking.</p>
        </div>
    </div>

    <section class="card chart-card">
        <div class="db-card-head">
            <div>
                <h2>Cash flow</h2>
                <p class="page-subtitle">Money credited and debited across every account, last 14 days</p>
            </div>
            <div class="chart-legend">
                <span class="chart-legend-item"><span class="chart-legend-swatch chart-legend-swatch-inflow"></span>Inflow</span>
                <span class="chart-legend-item"><span class="chart-legend-swatch chart-legend-swatch-outflow"></span>Outflow</span>
            </div>
        </div>

        <% if (flowCount == 0) { %>
            <div class="empty-state text-muted">No transaction history yet.</div>
        <% } else { %>
            <div class="chart-wrap">
                <svg viewBox="0 0 <%= chartW %> <%= chartH %>" class="cash-flow-svg" id="cashFlowChart"
                     preserveAspectRatio="none" role="img" aria-label="Daily cash inflow and outflow, last 14 days">

                    <% for (int g = 0; g <= 2; g++) {
                        double gridVal = axisMax * g / 2.0;
                        double gridY = marginTop + plotH - (g / 2.0) * plotH;
                    %>
                    <line x1="<%= marginLeft %>" y1="<%= gridY %>" x2="<%= chartW - marginRight %>" y2="<%= gridY %>" class="chart-gridline"></line>
                    <text x="<%= marginLeft - 8 %>" y="<%= gridY + 4 %>" class="chart-axis-label" text-anchor="end">&#8377;<%= compact(gridVal) %></text>
                    <% } %>

                    <% for (int i = 0; i < flowCount; i++) {
                        if (i % labelStep == 0 || i == flowCount - 1) {
                    %>
                    <text x="<%= px[i] %>" y="<%= chartH - 8 %>" class="chart-axis-label" text-anchor="middle"><%= dayLabels[i] %></text>
                    <% } } %>

                    <line id="cfCrosshair" x1="<%= marginLeft %>" y1="<%= marginTop %>" x2="<%= marginLeft %>" y2="<%= marginTop + plotH %>" class="chart-crosshair"></line>

                    <polyline points="<%= outflowPoints %>" class="chart-line chart-line-outflow"></polyline>
                    <polyline points="<%= inflowPoints %>" class="chart-line chart-line-inflow"></polyline>

                    <circle cx="<%= px[flowCount - 1] %>" cy="<%= outflowPy[flowCount - 1] %>" r="4" class="chart-dot chart-dot-outflow"></circle>
                    <circle cx="<%= px[flowCount - 1] %>" cy="<%= inflowPy[flowCount - 1] %>" r="4" class="chart-dot chart-dot-inflow"></circle>

                    <% if (showEndLabels) { %>
                    <text x="<%= px[flowCount - 1] + 8 %>" y="<%= inflowPy[flowCount - 1] + 4 %>" class="chart-end-label chart-end-label-inflow">&#8377;<%= compact(inflowVals[flowCount - 1]) %></text>
                    <text x="<%= px[flowCount - 1] + 8 %>" y="<%= outflowPy[flowCount - 1] + 4 %>" class="chart-end-label chart-end-label-outflow">&#8377;<%= compact(outflowVals[flowCount - 1]) %></text>
                    <% } %>

                    <rect id="cfHitLayer" x="<%= marginLeft %>" y="0" width="<%= plotW %>" height="<%= chartH %>"
                          fill="transparent" tabindex="0" aria-label="Hover or use arrow keys to inspect daily values"></rect>
                </svg>
                <div id="cfTooltip" class="chart-tooltip" hidden></div>
            </div>

            <details class="chart-table-toggle">
                <summary>View as table</summary>
                <div class="table-scroll">
                    <table class="txn-table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th class="text-right">Inflow</th>
                                <th class="text-right">Outflow</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (int i = 0; i < flowCount; i++) { %>
                            <tr>
                                <td><%= dayLabels[i] %></td>
                                <td class="text-right num gain">+&#8377;<%= String.format("%,.2f", inflowVals[i]) %></td>
                                <td class="text-right num loss">&minus;&#8377;<%= String.format("%,.2f", outflowVals[i]) %></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </details>

            <script>
            (function () {
                var data = <%= chartData %>;
                var svg = document.getElementById("cashFlowChart");
                var hitLayer = document.getElementById("cfHitLayer");
                var crosshair = document.getElementById("cfCrosshair");
                var tooltip = document.getElementById("cfTooltip");
                var wrap = svg.parentElement;
                if (!data.length) {
                    return;
                }

                function nearestIndex(xInSvgUnits) {
                    var closest = 0;
                    var minDist = Infinity;
                    for (var i = 0; i < data.length; i++) {
                        var dist = Math.abs(data[i].x - xInSvgUnits);
                        if (dist < minDist) {
                            minDist = dist;
                            closest = i;
                        }
                    }
                    return closest;
                }

                function formatMoney(value) {
                    return "₹" + value.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                }

                function render(index) {
                    var point = data[index];
                    crosshair.setAttribute("x1", point.x);
                    crosshair.setAttribute("x2", point.x);
                    crosshair.classList.add("chart-crosshair-active");

                    tooltip.innerHTML = "";
                    var title = document.createElement("div");
                    title.className = "chart-tooltip-title";
                    title.textContent = point.label;
                    tooltip.appendChild(title);

                    var rows = [
                        ["inflow", "Inflow", point.inflow],
                        ["outflow", "Outflow", point.outflow]
                    ];
                    rows.forEach(function (row) {
                        var line = document.createElement("div");
                        line.className = "chart-tooltip-row";
                        var key = document.createElement("span");
                        key.className = "chart-tooltip-key chart-tooltip-key-" + row[0];
                        var value = document.createElement("span");
                        value.className = "chart-tooltip-value";
                        value.textContent = formatMoney(row[2]);
                        var name = document.createElement("span");
                        name.className = "chart-tooltip-name";
                        name.textContent = row[1];
                        line.appendChild(key);
                        line.appendChild(value);
                        line.appendChild(name);
                        tooltip.appendChild(line);
                    });

                    tooltip.hidden = false;
                    var svgRect = svg.getBoundingClientRect();
                    var wrapRect = wrap.getBoundingClientRect();
                    var scaleX = svgRect.width / <%= chartW %>;
                    var left = (point.x * scaleX) + (svgRect.left - wrapRect.left);
                    var maxLeft = wrapRect.width - tooltip.offsetWidth - 8;
                    tooltip.style.left = Math.max(8, Math.min(left + 12, maxLeft)) + "px";
                    tooltip.style.top = "8px";
                }

                function hide() {
                    crosshair.classList.remove("chart-crosshair-active");
                    tooltip.hidden = true;
                }

                function pointerToSvgX(evt) {
                    var pt = svg.createSVGPoint();
                    pt.x = evt.clientX;
                    pt.y = evt.clientY;
                    return pt.matrixTransform(svg.getScreenCTM().inverse()).x;
                }

                var focusedIndex = data.length - 1;

                hitLayer.addEventListener("pointermove", function (evt) {
                    focusedIndex = nearestIndex(pointerToSvgX(evt));
                    render(focusedIndex);
                });
                hitLayer.addEventListener("pointerleave", hide);
                hitLayer.addEventListener("focus", function () {
                    render(focusedIndex);
                });
                hitLayer.addEventListener("blur", hide);
                hitLayer.addEventListener("keydown", function (evt) {
                    if (evt.key === "ArrowLeft" && focusedIndex > 0) {
                        focusedIndex--;
                        render(focusedIndex);
                        evt.preventDefault();
                    } else if (evt.key === "ArrowRight" && focusedIndex < data.length - 1) {
                        focusedIndex++;
                        render(focusedIndex);
                        evt.preventDefault();
                    }
                });
            })();
            </script>
        <% } %>
    </section>

    <section class="db-stats admin-stats">
        <article class="db-stat">
            <span class="db-label">Total users</span>
            <p class="db-stat-value num"><%= stats.totalUsers %></p>
            <span class="db-stat-caption">Registered customers</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total accounts</span>
            <p class="db-stat-value num"><%= stats.totalAccounts %></p>
            <span class="db-stat-caption">Across all statuses</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total balance</span>
            <p class="db-stat-value num">&#8377;<%= String.format("%,.2f", stats.totalBalance) %></p>
            <span class="db-stat-caption">Held across all accounts</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Total transactions</span>
            <p class="db-stat-value num"><%= stats.totalTransactions %></p>
            <span class="db-stat-caption">Transfers &amp; admin adjustments</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Active</span>
            <p class="db-stat-value num gain"><%= stats.activeCount %></p>
            <span class="db-stat-caption">Accounts in good standing</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Frozen</span>
            <p class="db-stat-value num warn"><%= stats.frozenCount %></p>
            <span class="db-stat-caption">Temporarily suspended</span>
        </article>
        <article class="db-stat">
            <span class="db-label">Closed</span>
            <p class="db-stat-value num loss"><%= stats.closedCount %></p>
            <span class="db-stat-caption">No longer active</span>
        </article>
    </section>

    <section class="card admin-quick-links">
        <h2>Quick actions</h2>
        <div class="admin-quick-links-row">
            <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost">Manage users</a>
            <a href="<%= request.getContextPath() %>/admin/add-user" class="btn btn-ghost">Add a user</a>
            <a href="<%= request.getContextPath() %>/admin/adjust-balance" class="btn btn-ghost">Adjust a balance</a>
            <a href="<%= request.getContextPath() %>/admin/transactions" class="btn btn-ghost">View all transactions</a>
        </div>
    </section>

<%@ include file="fragments/admin-sidebar-end.jsp" %>
</body>
</html>
