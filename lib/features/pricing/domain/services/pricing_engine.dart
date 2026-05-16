import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../../../historical_learning/domain/models/historical_insight.dart';
import '../models/quote_item.dart';
import '../../data/services/supplier_api_service.dart';

final pricingEngineProvider = Provider<PricingEngine>((ref) {
  return PricingEngine();
});

class PricingEngine {
  Future<QuoteSummary> generateQuote(TakeoffResult result, SupplierApiService supplier, {HistoricalInsight? insight}) async {
    List<QuoteItem> items = [];

    // 1. Process Fixtures
    for (final fixture in result.detectedFixtures) {
      double livePrice = await supplier.fetchMaterialCost(fixture);
      items.add(QuoteItem(
        description: fixture, 
        quantity: 1, 
        unitCost: livePrice,
        partNumber: '\${supplier.getPartPrefix()}\${fixture.substring(0, fixture.length > 3 ? 3 : fixture.length).toUpperCase()}',
      ));
    }

    // 2. Process Pipe Runs
    for (final run in result.pipeRuns) {
      double livePrice = await supplier.fetchMaterialCost(run.material);
      items.add(QuoteItem(
        description: "\${run.diameter}mm \${run.material} Pipe",
        partNumber: '\${supplier.getPartPrefix()}PIPE',
        unitCost: livePrice,
        quantity: run.estimatedLength.ceil(),
      ));
    }

    // 3. Add Estimated Labour (Assuming 4 hours at \$140/hr)
    items.add(QuoteItem(
      description: "Plumbing Labour & Installation",
      quantity: 4,
      unitCost: 140.00,
      markupPercentage: 0.0, // No markup on raw labour rate
      isLabour: true,
    ));

    // 4. Inject Historical AI Labour Buffer if applicable
    if (insight != null && insight.hasTrend) {
      items.add(QuoteItem(
        description: "AI Historical Risk Adjustment (Labour)",
        quantity: insight.suggestedLabourBuffer.ceil(),
        unitCost: 140.00,
        markupPercentage: 0.0,
        isLabour: true,
      ));
    }

    // Calculate totals
    double subtotal = items.fold(0, (sum, item) => sum + item.total);
    double gst = subtotal * 0.10; // 10% GST
    double total = subtotal + gst;

    return QuoteSummary(
      items: items,
      subtotal: subtotal,
      gst: gst,
      total: total,
    );
  }
}
