import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pricing/domain/models/quote_item.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../../../historical_learning/domain/models/historical_insight.dart';

final pdfGeneratorProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

class PdfGeneratorService {
  Future<Uint8List> generateQuotePdf(QuoteSummary summary, TakeoffResult takeoffResult, {HistoricalInsight? insight}) async {
    final pdf = pw.Document();

    // 1. Cover & Quote Summary Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('PlumbForge AI', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('TAX INVOICE / QUOTE', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                  ]
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: \${DateTime.now().toLocal().toString().split(' ')[0]}'),
              pw.Text('Valid For: 14 Days'),
              pw.SizedBox(height: 40),
              pw.Text('Scope of Work:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(takeoffResult.recommendedSolution),
              pw.SizedBox(height: 40),
              
              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [pw.Text('Subtotal:'), pw.Text('\$\${summary.subtotal.toStringAsFixed(2)}')]
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [pw.Text('GST (10%):'), pw.Text('\$\${summary.gst.toStringAsFixed(2)}')]
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total (AUD):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)), 
                          pw.Text('\$\${summary.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))
                        ]
                      ),
                    ]
                  )
                )
              )
            ],
          );
        },
      ),
    );

    // 2. Line Item & Compliance Breakdown Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detailed Breakdown & Compliance', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 20),
              
              pw.Table.fromTextArray(
                headers: ['Item', 'Part #', 'WaterMark', 'Qty', 'Unit Price', 'Total'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellAlignment: pw.Alignment.centerLeft,
                data: summary.items.map((item) => [
                  item.description,
                  item.partNumber,
                  item.waterMarkLicence,
                  item.quantity.toString(),
                  '\$\${item.sellPrice.toStringAsFixed(2)}',
                  '\$\${item.total.toStringAsFixed(2)}'
                ]).toList(),
              ),
              
              pw.SizedBox(height: 40),
              pw.Text('AS/NZS 3500 Compliance Notes:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...takeoffResult.complianceFlags.map((flag) => pw.Bullet(text: flag)),
              
              if (insight != null && insight.hasTrend) ...[
                pw.SizedBox(height: 20),
                pw.Text('PlumbForge AI Historical Learning Note:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                pw.SizedBox(height: 10),
                pw.Text(insight.reason, style: const pw.TextStyle(color: PdfColors.orange800)),
              ],
              
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Generated by PlumbForge AI - 100% Compliant Quotes in Seconds', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              )
            ]
          );
        }
      )
    );

    return pdf.save();
  }
}
