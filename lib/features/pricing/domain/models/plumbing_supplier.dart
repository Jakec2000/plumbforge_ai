enum SupplierType {
  reece,
  tradelink,
  knr,
  bunnings,
  samios,
  generic
}

extension SupplierTypeExtension on SupplierType {
  String get displayName {
    switch (this) {
      case SupplierType.reece:
        return 'Reece Plumbing (maX)';
      case SupplierType.tradelink:
        return 'Tradelink';
      case SupplierType.knr:
        return 'KNR Plumbing';
      case SupplierType.bunnings:
        return 'Bunnings Trade';
      case SupplierType.samios:
        return 'Samios Plumbing Supplies';
      case SupplierType.generic:
        return 'Market Average (Fallback)';
    }
  }
}

class PlumbingSupplier {
  final SupplierType type;
  final bool isConnected;
  final String? accountId;
  final String? apiKey;

  const PlumbingSupplier({
    required this.type,
    this.isConnected = false,
    this.accountId,
    this.apiKey,
  });

  PlumbingSupplier copyWith({
    bool? isConnected,
    String? accountId,
    String? apiKey,
  }) {
    return PlumbingSupplier(
      type: type,
      isConnected: isConnected ?? this.isConnected,
      accountId: accountId ?? this.accountId,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
