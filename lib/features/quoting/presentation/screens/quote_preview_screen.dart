import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../domain/services/pdf_generator_service.dart';
import '../../../pricing/domain/models/quote_item.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';

class QuotePreviewScreen extends ConsumerWidget {
  final QuoteSummary quoteSummary;
  final TakeoffResult takeoffResult;

  const QuotePreviewScreen({
    super.key,
    required this.quoteSummary,
    required this.takeoffResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Quote & Compliance PDF'),
      ),
      body: PdfPreview(
        build: (format) => pdfService.generateQuotePdf(quoteSummary, takeoffResult),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
