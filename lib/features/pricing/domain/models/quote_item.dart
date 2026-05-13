class QuoteItem {
  final String description;
  final String partNumber;
  final String waterMarkLicence;
  final int quantity;
  final double unitCost;
  final double markupPercentage;
  final bool isLabour;

  QuoteItem({
    required this.description,
    this.partNumber = '',
    this.waterMarkLicence = '',
    required this.quantity,
    required this.unitCost,
    this.markupPercentage = 0.30, // 30% default markup on materials
    this.isLabour = false,
  });

  double get sellPrice => unitCost * (1 + markupPercentage);
  double get total => sellPrice * quantity;
}

class QuoteSummary {
  final List<QuoteItem> items;
  final double subtotal;
  final double gst;
  final double total;

  QuoteSummary({
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.total,
  });
}
