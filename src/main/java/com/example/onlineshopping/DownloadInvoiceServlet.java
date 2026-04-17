package com.example.onlineshopping;

import com.example.onlineshopping.dao.OrderDAO;
import com.example.onlineshopping.model.Order;
import com.example.onlineshopping.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import java.awt.Color;
import java.io.IOException;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "DownloadInvoiceServlet", value = "/download-invoice")
public class DownloadInvoiceServlet extends HttpServlet {
    private static final DecimalFormat PRICE_FORMAT = new DecimalFormat("0.00");
    private static final float PAGE_MARGIN = 48f;
    private static final float ROW_HEIGHT = 24f;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User auth = (User) request.getSession().getAttribute("authUser");
        if (auth == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String orderGroupId = request.getParameter("orderGroupId");
        if (orderGroupId == null || orderGroupId.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderGroupId");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByGroup(auth.getId(), orderGroupId.trim());
        if (orders.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No invoice found for this order");
            return;
        }

        String safeOrderId = orderGroupId.replaceAll("[^A-Za-z0-9_-]", "_");
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=invoice-" + safeOrderId + ".pdf");

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            float y = page.getMediaBox().getHeight() - PAGE_MARGIN;
            float pageWidth = page.getMediaBox().getWidth();

            try (PDPageContentStream content = new PDPageContentStream(document, page)) {
                double grandTotal = 0.0;
                int totalQty = 0;
                for (Order order : orders) {
                    grandTotal += order.getPrice() * order.getQuantity();
                    totalQty += order.getQuantity();
                }

                y = writeText(content, PDType1Font.HELVETICA_BOLD, 22, PAGE_MARGIN, y, "FLIPZON INVOICE");
                y -= 4;
                y = writeText(content, PDType1Font.HELVETICA, 11, PAGE_MARGIN, y, "Order ID: " + orderGroupId);
                y = writeText(content, PDType1Font.HELVETICA, 11, PAGE_MARGIN, y, "Customer: " + auth.getUsername() + " (" + auth.getEmail() + ")");
                y = writeText(content, PDType1Font.HELVETICA, 11, PAGE_MARGIN, y, "Generated On: " + LocalDate.now());
                if (!orders.isEmpty()) {
                    y = writeText(content, PDType1Font.HELVETICA, 11, PAGE_MARGIN, y, "Order Date: " + orders.get(0).getDate());
                }

                y -= 8;
                float tableX = PAGE_MARGIN;
                float tableWidth = pageWidth - (2 * PAGE_MARGIN);
                float tableTopY = y;

                float[] colWidths = new float[]{tableWidth * 0.50f, tableWidth * 0.12f, tableWidth * 0.18f, tableWidth * 0.20f};
                float[] colX = new float[colWidths.length + 1];
                colX[0] = tableX;
                for (int i = 0; i < colWidths.length; i++) {
                    colX[i + 1] = colX[i] + colWidths[i];
                }

                float tableBottomY = tableTopY - ROW_HEIGHT * (orders.size() + 1);

                content.setNonStrokingColor(new Color(236, 243, 250));
                content.addRect(tableX, tableTopY - ROW_HEIGHT, tableWidth, ROW_HEIGHT);
                content.fill();

                content.setStrokingColor(new Color(160, 160, 160));
                for (int r = 0; r <= orders.size() + 1; r++) {
                    float rowY = tableTopY - (r * ROW_HEIGHT);
                    content.moveTo(tableX, rowY);
                    content.lineTo(tableX + tableWidth, rowY);
                }
                for (float x : colX) {
                    content.moveTo(x, tableTopY);
                    content.lineTo(x, tableBottomY);
                }
                content.stroke();

                float headerY = tableTopY - 16;
                writeCellText(content, PDType1Font.HELVETICA_BOLD, 11, colX[0] + 8, headerY, "Item");
                writeRightAlignedText(content, PDType1Font.HELVETICA_BOLD, 11, colX[2] - 8, headerY, "Qty");
                writeRightAlignedText(content, PDType1Font.HELVETICA_BOLD, 11, colX[3] - 8, headerY, "Unit Price");
                writeRightAlignedText(content, PDType1Font.HELVETICA_BOLD, 11, colX[4] - 8, headerY, "Total");

                for (int i = 0; i < orders.size(); i++) {
                    Order order = orders.get(i);
                    double lineTotal = order.getPrice() * order.getQuantity();
                    float rowTextY = tableTopY - ROW_HEIGHT * (i + 1) - 16;

                    writeCellText(content, PDType1Font.HELVETICA, 11, colX[0] + 8, rowTextY, truncate(order.getName(), 33));
                    writeRightAlignedText(content, PDType1Font.HELVETICA, 11, colX[2] - 8, rowTextY, String.valueOf(order.getQuantity()));
                    writeRightAlignedText(content, PDType1Font.HELVETICA, 11, colX[3] - 8, rowTextY, "$" + PRICE_FORMAT.format(order.getPrice()));
                    writeRightAlignedText(content, PDType1Font.HELVETICA, 11, colX[4] - 8, rowTextY, "$" + PRICE_FORMAT.format(lineTotal));
                }

                y = tableBottomY - 28;

                float summaryBoxWidth = 250f;
                float summaryX = tableX + tableWidth - summaryBoxWidth;
                float summaryHeight = 78f;
                content.setStrokingColor(new Color(190, 190, 190));
                content.addRect(summaryX, y - summaryHeight + 18, summaryBoxWidth, summaryHeight);
                content.stroke();

                writeText(content, PDType1Font.HELVETICA, 12, summaryX + 12, y, "Total Items: " + totalQty);
                writeText(content, PDType1Font.HELVETICA_BOLD, 16, summaryX + 12, y - 28, "Grand Total: $" + PRICE_FORMAT.format(grandTotal));

                writeText(content, PDType1Font.HELVETICA_OBLIQUE, 10, PAGE_MARGIN, 48, "Thank you for shopping with FlipZon.");
            }

            document.save(response.getOutputStream());
        }
    }

    private float writeText(PDPageContentStream content, PDFont font, int fontSize, float x, float y, String text) throws IOException {
        content.beginText();
        content.setFont(font, fontSize);
        content.newLineAtOffset(x, y);
        content.showText(text == null ? "" : text);
        content.endText();
        return y - (fontSize + 6);
    }

    private void writeCellText(PDPageContentStream content, PDFont font, int fontSize, float x, float y, String text) throws IOException {
        content.beginText();
        content.setFont(font, fontSize);
        content.newLineAtOffset(x, y);
        content.showText(text == null ? "" : text);
        content.endText();
    }

    private void writeRightAlignedText(PDPageContentStream content, PDFont font, int fontSize, float rightX, float y, String text) throws IOException {
        String value = text == null ? "" : text;
        float textWidth = font.getStringWidth(value) / 1000f * fontSize;
        writeCellText(content, font, fontSize, rightX - textWidth, y, value);
    }

    private String truncate(String text, int width) {
        String value = text == null ? "" : text;
        if (value.length() <= width) {
            return value;
        }
        if (width <= 3) {
            return value.substring(0, width);
        }
        return value.substring(0, width - 3) + "...";
    }
}