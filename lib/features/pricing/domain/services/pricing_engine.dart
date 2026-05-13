import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../../../historical_learning/domain/models/historical_insight.dart';
import '../models/quote_item.dart';

final pricingEngineProvider = Provider<PricingEngine>((ref) {
  return PricingEngine();
});

class PricingEngine {
  // Hardcoded mappings based on mock JSON data for quick execution
  final Map<String, QuoteItem> _mockDb = {
    "100mm PVC-U Pipe": QuoteItem(
      description: "100mm PVC-U DWV Pipe",
      partNumber: "RE-PVC-100",
      waterMarkLicence: "WMKA12345",
      unitCost: 12.50,
      quantity: 1,
    ),
    "20mm Copper Pipe": QuoteItem(
      description: "20mm Copper Tube (Type B)",
      partNumber: "RE-CU-20",
      waterMarkLicence: "WMKA98765",
      unitCost: 18.00,
      quantity: 1,
    ),
    "Toilet (WC)": QuoteItem(
      description: "Toilet Suite - WELS 4 Star",
      partNumber: "DW-WC-STD",
      waterMarkLicence: "WMKA55555",
      unitCost: 250.00,
      quantity: 1,
    ),
    "Vanity Basin": QuoteItem(
      description: "Vanity Unit 900mm w/ Ceramic Top",
      partNumber: "DW-VB-900",
      waterMarkLicence: "WMKA66666",
      unitCost: 450.00,
      quantity: 1,
    ),
  };

  QuoteSummary generateQuote(TakeoffResult result, {HistoricalInsight? insight}) {
    List<QuoteItem> items = [];

    // 1. Process Fixtures
    for (final fixture in result.detectedFixtures) {
      if (fixture.contains("Toilet") || fixture.contains("WC")) {
        items.add(_mockDb["Toilet (WC)"]!);
      } else if (fixture.contains("Vanity") || fixture.contains("Basin")) {
        items.add(_mockDb["Vanity Basin"]!);
      } else {
        items.add(QuoteItem(description: fixture, quantity: 1, unitCost: 100.00));
      }
    }

    // 2. Process Pipe Runs
    for (final run in result.pipeRuns) {
      if (run.material.toUpperCase().contains("PVC")) {
        items.add(QuoteItem(
          description: "\${run.diameter}mm \${run.material} Pipe",
          partNumber: _mockDb["100mm PVC-U Pipe"]!.partNumber,
          waterMarkLicence: _mockDb["100mm PVC-U Pipe"]!.waterMarkLicence,
          unitCost: _mockDb["100mm PVC-U Pipe"]!.unitCost,
          quantity: run.estimatedLength.ceil(),
        ));
      } else if (run.material.toUpperCase().contains("COPPER")) {
        items.add(QuoteItem(
          description: "\${run.diameter}mm \${run.material} Pipe",
          partNumber: _mockDb["20mm Copper Pipe"]!.partNumber,
          waterMarkLicence: _mockDb["20mm Copper Pipe"]!.waterMarkLicence,
          unitCost: _mockDb["20mm Copper Pipe"]!.unitCost,
          quantity: run.estimatedLength.ceil(),
        ));
      }
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
