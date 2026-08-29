import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rental/features/profile/services/company_profile_service.dart';
import 'package:rental/features/rentals/models/rental_model.dart';

class InvoicePdfGenerator {
  /// Generate Invoice PDF Uint8List bytes
  static Future<Uint8List> generateInvoicePdf(RentalModel rental) async {
    final company = await CompanyProfileService().getCompanyProfile();
    final pdf = pw.Document();

    final companyName = (company.companyName.isNotEmpty) ? company.companyName : 'Warmonks';
    final gstNum = company.gstNumber ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Row: Tenant / Company Details & Invoice Badge
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(company.registeredAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text('Phone: ${company.phoneNumber} | Email: ${company.contactEmail}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (gstNum.isNotEmpty)
                        pw.Text('GSTIN: $gstNum', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue900,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'RENTAL INVOICE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Invoice #: ${rental.id}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Date: ${rental.pickupDate}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Status: ${rental.status}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 12),

              // Customer & Rental Period Information
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CUSTOMER DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text(rental.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('Phone: ${rental.customerPhone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RENTAL PERIOD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text('${rental.pickupDate} to ${rental.returnDate}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Duration: ${rental.duration}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // Rented Items Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
                headerHeight: 24,
                cellHeight: 24,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headers: ['#', 'Item Name', 'Qty', 'Mode', 'Rate / Day', 'Total Amount'],
                data: List<List<dynamic>>.generate(rental.items.length, (index) {
                  final item = rental.items[index];
                  return [
                    '${index + 1}',
                    item.name,
                    '${item.quantity}',
                    item.pricingMode.toUpperCase(),
                    'Rs. ${item.ratePerDay.toStringAsFixed(2)}',
                    'Rs. ${item.total.toStringAsFixed(2)}',
                  ];
                }),
              ),

              pw.SizedBox(height: 16),

              // Summary & Financials
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PAYMENT SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      if (rental.payments.isNotEmpty)
                        ...rental.payments.map((p) => pw.Text('${p.date} - ${p.mode}: Rs. ${p.amount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)))
                      else
                        pw.Text('Paid Amount: Rs. ${rental.paidAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal:', 'Rs. ${rental.subtotal.toStringAsFixed(2)}'),
                        if (rental.discount > 0)
                          _buildSummaryRow('Discount:', '- Rs. ${rental.discount.toStringAsFixed(2)}'),
                        if (rental.securityDeposit > 0)
                          _buildSummaryRow('Security Deposit:', 'Rs. ${rental.securityDeposit.toStringAsFixed(2)}'),
                        pw.Divider(color: PdfColors.grey400),
                        _buildSummaryRow('Grand Total:', 'Rs. ${rental.totalAmount.toStringAsFixed(2)}', isBold: true),
                        _buildSummaryRow('Paid Amount:', 'Rs. ${rental.paidAmount.toStringAsFixed(2)}', isBold: true, color: PdfColors.green800),
                        _buildSummaryRow('Balance Due:', 'Rs. ${rental.balanceDue.toStringAsFixed(2)}', isBold: true, color: PdfColors.red800),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer Branding
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Thank you for renting with $companyName!',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Generate & open native system share dialog for PDF invoice
  static Future<void> shareInvoice(BuildContext context, RentalModel rental) async {
    try {
      final pdfBytes = await generateInvoicePdf(rental);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Invoice_${rental.id}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
