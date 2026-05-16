import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../domain/services/pdf_generator_service.dart';
import '../../../pricing/domain/models/quote_item.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../../data/services/portal_link_service.dart';
import '../../../accounting/data/services/xero_service.dart';
import '../../../core/sync/offline_sync_engine.dart';

class QuotePreviewScreen extends ConsumerStatefulWidget {
  final QuoteSummary quoteSummary;
  final TakeoffResult takeoffResult;

  const QuotePreviewScreen({
    super.key,
    required this.quoteSummary,
    required this.takeoffResult,
  });

  @override
  ConsumerState<QuotePreviewScreen> createState() => _QuotePreviewScreenState();
}

class _QuotePreviewScreenState extends ConsumerState<QuotePreviewScreen> {
  bool _isGeneratingLink = false;
  bool _isSyncingXero = false;

  void _generateMagicLink() async {
    setState(() => _isGeneratingLink = true);
    final portalService = ref.read(portalLinkProvider);
    try {
      final link = await portalService.generateMagicLink("CUST-123", widget.quoteSummary.total);
      
      // Queue for offline sync to ensure it eventually hits Firebase
      await ref.read(offlineSyncProvider).queueQuoteForSync(widget.quoteSummary);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Magic Link SMS sent: \$link. Synced to Cloud!'),
          backgroundColor: Colors.green,
        ));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingLink = false);
    }
  }

  void _syncToXero() async {
    setState(() => _isSyncingXero = true);
    final xeroService = ref.read(xeroServiceProvider);
    try {
      final success = await xeroService.createDraftInvoice(widget.quoteSummary.total, "John Doe");
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Draft Invoice synced to Xero successfully!'),
          backgroundColor: Colors.blue,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSyncingXero = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfService = ref.watch(pdfGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Quote & Compliance PDF'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isGeneratingLink ? null : _generateMagicLink,
                  icon: _isGeneratingLink 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.send_to_mobile),
                  label: const Text('SMS Magic Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSyncingXero ? null : _syncToXero,
                  icon: _isSyncingXero 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.cloud_sync),
                  label: const Text('Sync to Xero'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: (format) => pdfService.generateQuotePdf(widget.quoteSummary, widget.takeoffResult),
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
        ],
      ),
    );
  }
}
