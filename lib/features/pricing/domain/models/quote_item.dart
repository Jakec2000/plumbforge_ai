import '../../quoting/domain/models/quote_status.dart';

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
  final QuoteStatus status;
  final DateTime? sentDate;

  QuoteSummary({
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.total,
    this.status = QuoteStatus.draft,
    this.sentDate,
  });

  QuoteSummary copyWith({
    List<QuoteItem>? items,
    double? subtotal,
    double? gst,
    double? total,
    QuoteStatus? status,
    DateTime? sentDate,
  }) {
    return QuoteSummary(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      total: total ?? this.total,
      status: status ?? this.status,
      sentDate: sentDate ?? this.sentDate,
    );
  }
}
