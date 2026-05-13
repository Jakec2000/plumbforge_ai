import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../models/historical_insight.dart';

final historicalEngineProvider = Provider<HistoricalEngine>((ref) {
  return HistoricalEngine();
});

class HistoricalEngine {
  HistoricalInsight analyzeForTrends(TakeoffResult result) {
    double buffer = 0.0;
    List<String> reasons = [];

    // Mock trend analysis based on hardcoded knowledge from DB
    bool hasVanity = result.detectedFixtures.any((f) => f.contains("Vanity"));
    if (hasVanity) {
      buffer += 1.0;
      reasons.add("Historical Data: Vanity installs in older postcodes often require +1 hr to adapt galvanized pipes.");
    }

    bool hasLongCopper = result.pipeRuns.any((r) => r.material.contains("Copper") && r.estimatedLength > 3.0);
    if (hasLongCopper) {
      buffer += 1.5;
      reasons.add("Historical Data: Copper runs >3m usually overrun by 1.5 hrs due to brazing complexity.");
    }

    if (buffer > 0) {
      return HistoricalInsight(
        hasTrend: true,
        suggestedLabourBuffer: buffer,
        reason: reasons.join(" "),
      );
    }

    return HistoricalInsight();
  }
}
