import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pricing/domain/models/plumbing_supplier.dart';
import '../../pricing/providers/supplier_integration_provider.dart';

final supplierApiProvider = Provider<SupplierApiService>((ref) {
  final activeSupplier = ref.watch(primarySupplierProvider);
  return SupplierApiService(activeSupplier);
});

class SupplierApiService {
  final SupplierType supplier;

  SupplierApiService(this.supplier);

  String getPartPrefix() {
    switch (supplier) {
      case SupplierType.reece: return 'RE-';
      case SupplierType.tradelink: return 'TL-';
      case SupplierType.knr: return 'KNR-';
      case SupplierType.bunnings: return 'BUN-';
      case SupplierType.samios: return 'SAM-';
      case SupplierType.generic: return 'MKT-';
    }
  }

  // Simulates a live API call to the specific supplier's B2B database
  Future<double> fetchMaterialCost(String itemName) async {
    // Artificial network delay to simulate real API
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = itemName.toLowerCase();
    
    // Base market rate
    double baseRate = 85.00;
    if (normalized.contains('toilet') || normalized.contains('wc')) {
      baseRate = 350.00;
    } else if (normalized.contains('vanity')) {
      baseRate = 450.00;
    } else if (normalized.contains('pvc')) {
      baseRate = 15.50; 
    } else if (normalized.contains('copper')) {
      baseRate = 28.00; 
    } else if (normalized.contains('shower')) {
      baseRate = 220.00;
    } else if (normalized.contains('tap')) {
      baseRate = 110.00;
    }
    
    // Apply supplier-specific variance (mocking their tiered discount structures)
    switch (supplier) {
      case SupplierType.reece:
        return baseRate * 1.15; // Premium tier
      case SupplierType.tradelink:
        return baseRate * 1.05; // Standard trade
      case SupplierType.bunnings:
        return baseRate * 0.85; // Cheaper retail
      case SupplierType.knr:
        return baseRate * 0.95; 
      case SupplierType.samios:
        return baseRate * 0.90;
      case SupplierType.generic:
        return baseRate;
    }
  }
}
