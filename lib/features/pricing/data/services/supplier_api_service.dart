import 'package:flutter_riverpod/flutter_riverpod.dart';

final supplierApiProvider = Provider<SupplierApiService>((ref) {
  return SupplierApiService();
});

class SupplierApiService {
  // Simulates a live API call to Reece / Tradelink
  Future<double> fetchMaterialCost(String itemName) async {
    // Artificial network delay to simulate real API
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = itemName.toLowerCase();
    
    // Simulated dynamic market prices based on current "market" rates
    if (normalized.contains('toilet') || normalized.contains('wc')) {
      return 350.00;
    } else if (normalized.contains('vanity')) {
      return 450.00;
    } else if (normalized.contains('pvc')) {
      return 15.50; // Per meter
    } else if (normalized.contains('copper')) {
      return 28.00; // Per meter
    } else if (normalized.contains('shower')) {
      return 220.00;
    } else if (normalized.contains('tap')) {
      return 110.00;
    }
    
    // Fallback base price if item is unknown to supplier
    return 85.00;
  }
}
