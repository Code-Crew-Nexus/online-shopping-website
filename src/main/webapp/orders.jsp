<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="com.example.onlineshopping.model.Order" %>
<%@ page import="com.example.onlineshopping.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%
    User auth = (User) session.getAttribute("authUser");
    if (auth == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Map<String, List<Order>> groupedOrders = (Map<String, List<Order>>) request.getAttribute("groupedOrders");
    if (groupedOrders == null) {
        groupedOrders = new LinkedHashMap<>();
    }

    String status = request.getParameter("status");
    boolean success = "success".equalsIgnoreCase(status);
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<html>
<head>
    <title>Orders - FlipZon</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .order-section {
            margin-bottom: 24px;
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 20px;
            background: var(--card-bg);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            transition: all 0.3s ease;
        }

        .order-section:hover {
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 2px solid var(--line);
        }

        .order-id-section {
            flex: 1;
        }

        .order-id {
            font-size: 24px;
            font-weight: 800;
            color: var(--brand-a);
            margin: 0 0 4px 0;
        }

        .order-date {
            font-size: 14px;
            color: var(--text-muted);
            margin: 0;
        }

        .order-status-badge {
            display: inline-block;
            padding: 8px 14px;
            background: var(--ok);
            color: white;
            border-radius: 20px;
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
        }

        .order-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 16px;
        }

        .btn-small {
            padding: 8px 12px;
            font-size: 13px;
            border-radius: 8px;
            text-decoration: none;
            border: 1px solid var(--line);
            background: var(--card-bg);
            color: var(--text-main);
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-small:hover {
            background: var(--brand-a);
            color: white;
            border-color: var(--brand-a);
            transform: translateY(-1px);
        }

        .btn-small-brand {
            background: var(--brand-a);
            color: white;
            border-color: var(--brand-a);
        }

        .items-grid {
            display: grid;
            gap: 12px;
            margin-bottom: 20px;
        }

        .order-item {
            display: grid;
            grid-template-columns: 80px 1fr auto;
            gap: 16px;
            padding: 12px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            align-items: center;
        }

        :root[data-theme="dark"] .order-item {
            background: rgba(255, 255, 255, 0.05);
        }

        .item-image {
            width: 80px;
            height: 80px;
            border-radius: 8px;
            object-fit: cover;
        }

        .item-info h4 {
            margin: 0 0 4px 0;
            font-size: 15px;
            color: var(--text-main);
        }

        .item-info p {
            margin: 0;
            font-size: 13px;
            color: var(--text-muted);
        }

        .item-price {
            text-align: right;
            font-weight: 700;
            font-size: 16px;
            color: var(--brand-b);
        }

        .order-summary {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            padding: 16px;
            background: rgba(11, 114, 133, 0.06);
            border-radius: 10px;
            margin-top: 16px;
        }

        :root[data-theme="dark"] .order-summary {
            background: rgba(77, 184, 208, 0.08);
        }

        .summary-item {
            text-align: center;
        }

        .summary-label {
            font-size: 12px;
            color: var(--text-muted);
            text-transform: uppercase;
            margin-bottom: 4px;
        }

        .summary-value {
            font-size: 20px;
            font-weight: 800;
            color: var(--brand-a);
        }

        .invoice-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .invoice-modal.show {
            display: flex;
        }

        .invoice-content {
            background: var(--card-bg);
            border-radius: 16px;
            padding: 40px;
            max-width: 600px;
            width: 95%;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .invoice-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--line);
        }

        .invoice-header h2 {
            margin: 0;
            color: var(--brand-a);
        }

        .invoice-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .invoice-detail-block h4 {
            margin: 0 0 8px 0;
            font-size: 12px;
            color: var(--text-muted);
            text-transform: uppercase;
        }

        .invoice-detail-block p {
            margin: 4px 0;
            font-size: 14px;
        }

        .invoice-items {
            margin-bottom: 20px;
        }

        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        .invoice-table th {
            text-align: left;
            padding: 10px 0;
            border-bottom: 2px solid var(--line);
            font-weight: 700;
            color: var(--text-muted);
            font-size: 12px;
            text-transform: uppercase;
        }

        .invoice-table td {
            padding: 12px 0;
            border-bottom: 1px solid var(--line);
        }

        .invoice-total {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 20px;
            padding: 20px 0;
            border-top: 2px solid var(--line);
            font-size: 16px;
            font-weight: 700;
        }

        .invoice-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid var(--line);
        }

        .close-invoice {
            position: absolute;
            top: 20px;
            right: 20px;
            background: var(--line);
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 24px;
            color: var(--text-main);
            transition: all 0.2s ease;
        }

        .close-invoice:hover {
            background: var(--brand-a);
            color: white;
        }

        @media print {
            .close-invoice, .invoice-actions {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }

            .order-summary {
                grid-template-columns: repeat(2, 1fr);
            }

            .invoice-details {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="layout">
    <div class="top-nav">
        <div class="links">
            <a class="btn-link" href="${pageContext.request.contextPath}/index.jsp">Home</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/products">Products</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/cart.jsp">Cart</a>
            <a class="btn-link" href="${pageContext.request.contextPath}/orders">Orders</a>
            <a class="btn-link btn-danger" href="${pageContext.request.contextPath}/logout">Logout</a>
        </div>
        <button class="btn" type="button" data-theme-toggle>Switch Mode</button>
    </div>

    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <div>
                <h2>📦 Order History</h2>
                <p class="muted">Track all your orders and manage invoices</p>
            </div>
            <% if (!groupedOrders.isEmpty()) { %>
            <form method="post" action="${pageContext.request.contextPath}/orders" style="display: inline;">
                <button type="button" class="btn btn-danger" onclick="clearAllOrders()" style="margin: 0;">
                    🗑️ Clear All Delivered Orders
                </button>
            </form>
            <% } %>
        </div>

        <% if (success && request.getParameter("total") != null) { %>
            <p class="alert alert-ok">
                ✓ Order placed successfully! Total: $<%= request.getParameter("total") %>
            </p>
        <% } %>

        <% if (groupedOrders.isEmpty()) { %>
            <p class="muted">You haven't placed any orders yet.</p>
            <a class="btn btn-brand" href="${pageContext.request.contextPath}/products">Start Shopping</a>
        <% } else { %>
            <% for (Map.Entry<String, List<Order>> entry : groupedOrders.entrySet()) {
                String orderGroupId = entry.getKey();
                List<Order> items = entry.getValue();
                
                double orderTotal = 0;
                Date orderDate = null;
                
                for (Order order : items) {
                    orderTotal += order.getPrice() * order.getQuantity();
                    if (orderDate == null) {
                        try {
                            orderDate = dateFormat.parse(order.getDate());
                        } catch (Exception e) {
                            orderDate = new Date();
                        }
                    }
                }
                
                // Calculate expected delivery date (5-7 days from order)
                Calendar calendar = Calendar.getInstance();
                if (orderDate != null) {
                    calendar.setTime(orderDate);
                } else {
                    calendar.setTime(new Date());
                }
                calendar.add(Calendar.DAY_OF_YEAR, 6);
                Date deliveryDate = calendar.getTime();
            %>
            <div class="order-section">
                <div class="order-header">
                    <div class="order-id-section">
                        <p class="order-id"><%= orderGroupId %></p>
                        <p class="order-date">Placed on <%= orderDate != null ? sdf.format(orderDate) : "N/A" %></p>
                    </div>
                    <span class="order-status-badge">✓ Delivered</span>
                </div>

                <div class="order-actions">
                    <button class="btn-small btn-small-brand" onclick="showInvoice('<%= orderGroupId %>')">📄 View Invoice</button>
                    <button class="btn-small" onclick="downloadInvoiceAsPDF('<%= orderGroupId %>')">⬇️ Download Invoice</button>
                    <button class="btn-small" onclick="printInvoice('<%= orderGroupId %>')">🖨️ Print</button>
                    <button class="btn-small btn-danger" onclick="deleteOrder('<%= orderGroupId %>')">🗑️ Delete</button>
                </div>

                <div class="items-grid">
                    <% for (Order order : items) { %>
                    <div class="order-item">
                        <div>
                            <% if (order.getImageUrl() != null && !order.getImageUrl().isEmpty()) { %>
                            <img src="<%= order.getImageUrl() %>" alt="<%= order.getName() %>" class="item-image" onerror="this.style.display='none'">
                            <% } else { %>
                            <div style="width: 80px; height: 80px; background: var(--bg-soft); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-size: 32px;">📦</div>
                            <% } %>
                        </div>
                        <div class="item-info">
                            <h4><%= order.getName() %></h4>
                            <p>Qty: <%= order.getQuantity() %> × $<%= String.format("%.2f", order.getPrice()) %></p>
                        </div>
                        <div class="item-price">
                            $<%= String.format("%.2f", order.getPrice() * order.getQuantity()) %>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="order-summary">
                    <div class="summary-item">
                        <div class="summary-label">Items</div>
                        <div class="summary-value"><%= items.size() %></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-label">Subtotal</div>
                        <div class="summary-value">$<%= String.format("%.2f", orderTotal) %></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-label">Delivery</div>
                        <div class="summary-value" style="color: var(--ok);">FREE</div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-label">Expected By</div>
                        <div class="summary-value" style="font-size: 14px; color: var(--brand-a);"><%= sdf.format(deliveryDate) %></div>
                    </div>
                </div>
            </div>

            <!-- Invoice Modal -->
            <div id="invoice-<%= orderGroupId.hashCode() %>" class="invoice-modal">
                <button class="close-invoice" onclick="closeInvoice('<%= orderGroupId %>')">✕</button>
                <div class="invoice-content">
                    <div class="invoice-header">
                        <h2>INVOICE</h2>
                        <p style="margin: 10px 0 0 0; color: var(--text-muted);">Order <%= orderGroupId %></p>
                    </div>

                    <div class="invoice-details">
                        <div class="invoice-detail-block">
                            <h4>Bill To</h4>
                            <p><strong><%= auth.getUsername() %></strong></p>
                            <p><%= auth.getEmail() %></p>
                        </div>
                        <div class="invoice-detail-block">
                            <h4>Order Details</h4>
                            <p><strong>Order Date:</strong><br><%= orderDate != null ? sdf.format(orderDate) : "N/A" %></p>
                            <p><strong>Expected Delivery:</strong><br><%= sdf.format(deliveryDate) %></p>
                        </div>
                    </div>

                    <div class="invoice-items">
                        <table class="invoice-table">
                            <thead>
                            <tr>
                                <th>Item</th>
                                <th>Qty</th>
                                <th>Unit Price</th>
                                <th>Total</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (Order order : items) { %>
                            <tr>
                                <td><%= order.getName() %></td>
                                <td><%= order.getQuantity() %></td>
                                <td>$<%= String.format("%.2f", order.getPrice()) %></td>
                                <td>$<%= String.format("%.2f", order.getPrice() * order.getQuantity()) %></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="invoice-total">
                        <div style="font-size: 14px;">TOTAL:</div>
                        <div style="color: var(--brand-a); font-size: 20px;">$<%= String.format("%.2f", orderTotal) %></div>
                    </div>

                    <div class="invoice-actions">
                        <button class="btn btn-small btn-small-brand" onclick="printInvoice('<%= orderGroupId %>')">🖨️ Print</button>
                        <button class="btn btn-small btn-small-brand" onclick="downloadInvoiceAsPDF('<%= orderGroupId %>')">⬇️ Download Invoice</button>
                        <button class="btn btn-small" onclick="closeInvoice('<%= orderGroupId %>')">Close</button>
                    </div>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>
</div>

<script>
    function showInvoice(orderGroupId) {
        const hashCode = orderGroupId.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        document.getElementById('invoice-' + hashCode).classList.add('show');
    }

    function closeInvoice(orderGroupId) {
        const hashCode = orderGroupId.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        document.getElementById('invoice-' + hashCode).classList.remove('show');
    }

    function printInvoice(orderGroupId) {
        const hashCode = orderGroupId.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        const modal = document.getElementById('invoice-' + hashCode);
        
        if (!modal) {
            alert('Invoice not found');
            return;
        }
        
        // Clone the invoice content
        const printContent = modal.querySelector('.invoice-content').cloneNode(true);
        
        // Remove close button and actions for print
        const closeBtn = printContent.querySelector('.close-invoice');
        if (closeBtn) closeBtn.remove();
        const actions = printContent.querySelector('.invoice-actions');
        if (actions) actions.remove();
        
        // Use a popup window created from the click event to keep print reliable.
        const printWindow = window.open('', '_blank', 'width=900,height=700');
        if (!printWindow) {
            alert('Unable to open print window. Please allow pop-ups for this site and try again.');
            return;
        }

        const html = '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<title>Invoice ' + orderGroupId + '</title>' +
            '<style>' +
            '* { margin: 0; padding: 0; box-sizing: border-box; }' +
            'body { font-family: Arial, sans-serif; padding: 20px; color: #333; }' +
            '.invoice-content { max-width: 720px; margin: 0 auto; }' +
            'h2 { color: #0b7285; margin-bottom: 10px; }' +
            'table { width: 100%; border-collapse: collapse; margin: 20px 0; }' +
            'th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }' +
            'th { background-color: #f5f5f5; font-weight: bold; }' +
            '.invoice-header { text-align: center; margin-bottom: 20px; border-bottom: 2px solid #0b7285; padding-bottom: 15px; }' +
            '.invoice-details { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }' +
            '.invoice-detail-block h4 { font-size: 12px; color: #666; text-transform: uppercase; margin-bottom: 8px; }' +
            '.invoice-total { display: flex; justify-content: space-between; font-weight: bold; padding-top: 20px; border-top: 2px solid #0b7285; }' +
            '@media print { body { margin: 0; padding: 10px; } }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<div class="invoice-content">' + printContent.innerHTML + '</div>' +
            '</body>' +
            '</html>';

        let hasPrinted = false;
        const triggerPrint = function () {
            if (hasPrinted) {
                return;
            }
            hasPrinted = true;
            printWindow.focus();
            printWindow.print();
        };

        printWindow.document.open();
        printWindow.document.write(html);
        printWindow.document.close();

        printWindow.onload = function () {
            setTimeout(triggerPrint, 120);
        };

        printWindow.onafterprint = function () {
            printWindow.close();
        };

        // Fallback in case onload is delayed.
        setTimeout(triggerPrint, 450);
    }

    function downloadInvoiceAsPDF(orderGroupId) {
        const hashCode = orderGroupId.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        const modal = document.getElementById('invoice-' + hashCode);
        
        if (!modal) {
            alert('Invoice not found');
            return;
        }
        
        const contextPath = '<%= request.getContextPath() %>';
        const url = contextPath + '/download-invoice?orderGroupId=' + encodeURIComponent(orderGroupId);
        window.location.href = url;
    }

    function deleteOrder(orderGroupId) {
        if (confirm('Are you sure you want to delete this order?')) {
            const form = document.createElement('form');
            form.method = 'GET';
            form.action = '${pageContext.request.contextPath}/orders';
            
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'deleteOrderId';
            input.value = orderGroupId;
            form.appendChild(input);
            
            document.body.appendChild(form);
            form.submit();
        }
    }

    function clearAllOrders() {
        if (confirm('Are you sure you want to clear all delivered orders? This action cannot be undone.')) {
            const orders = document.querySelectorAll('.order-section');
            const orderIds = [];
            
            orders.forEach((order, index) => {
                const orderIdText = order.querySelector('.order-id').textContent;
                orderIds.push(orderIdText);
            });
            
            // Delete all orders
            orderIds.forEach(orderId => {
                const form = document.createElement('form');
                form.method = 'GET';
                form.action = '${pageContext.request.contextPath}/orders';
                
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'deleteOrderId';
                input.value = orderId;
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
                document.body.removeChild(form);
                
                // Add a small delay between deletions
                setTimeout(() => {}, 100);
            });
        }
    }

    // Close modal when clicking outside
    document.addEventListener('click', function(event) {
        if (event.target.classList.contains('invoice-modal')) {
            const modal = event.target;
            const modalId = modal.id.split('-')[1];
            
            // Find the corresponding order group ID and close it
            const orderSections = document.querySelectorAll('.order-section');
            orderSections.forEach(section => {
                const orderId = section.querySelector('.order-id').textContent;
                const hashCode = orderId.split('').reduce((a, b) => {
                    a = ((a << 5) - a) + b.charCodeAt(0);
                    return a & a;
                }, 0);
                if (hashCode.toString() === modalId) {
                    closeInvoice(orderId);
                }
            });
        }
    });
</script>

<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</body>
</html>