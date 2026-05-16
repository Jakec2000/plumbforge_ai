import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/plumbing_supplier.dart';

// The currently selected "Primary" supplier to use for quotes
final primarySupplierProvider = StateProvider<SupplierType>((ref) => SupplierType.generic);

// The list of all available suppliers and their connection status
final supplierIntegrationsProvider = StateNotifierProvider<SupplierIntegrationsNotifier, List<PlumbingSupplier>>((ref) {
  return SupplierIntegrationsNotifier();
});

class SupplierIntegrationsNotifier extends StateNotifier<List<PlumbingSupplier>> {
  SupplierIntegrationsNotifier() : super([
    const PlumbingSupplier(type: SupplierType.reece),
    const PlumbingSupplier(type: SupplierType.tradelink),
    const PlumbingSupplier(type: SupplierType.knr),
    const PlumbingSupplier(type: SupplierType.bunnings),
    const PlumbingSupplier(type: SupplierType.samios),
  ]);

  void connectSupplier(SupplierType type, String accountId, String apiKey) {
    state = [
      for (final supplier in state)
        if (supplier.type == type)
          supplier.copyWith(isConnected: true, accountId: accountId, apiKey: apiKey)
        else
          supplier
    ];
  }

  void disconnectSupplier(SupplierType type) {
    state = [
      for (final supplier in state)
        if (supplier.type == type)
          const PlumbingSupplier(type: SupplierType.reece).copyWith(type: type) // Reset to defaults
        else
          supplier
    ];
  }
}
