import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pricing/domain/models/quote_item.dart';
import '../domain/models/quote_status.dart';

final followUpServiceProvider = Provider<FollowUpService>((ref) {
  return FollowUpService();
});

class FollowUpService {
  final List<QuoteSummary> _mockDatabase = [
    QuoteSummary(
      items: [],
      subtotal: 1000,
      gst: 100,
      total: 1100,
      status: QuoteStatus.sent,
      sentDate: DateTime.now().subtract(const Duration(hours: 50)), // Needs follow-up!
    ),
    QuoteSummary(
      items: [],
      subtotal: 500,
      gst: 50,
      total: 550,
      status: QuoteStatus.sent,
      sentDate: DateTime.now().subtract(const Duration(hours: 10)), // Safe
    ),
  ];

  int get pendingFollowUpsCount {
    return _mockDatabase.where((q) => 
      q.status == QuoteStatus.sent && 
      q.sentDate != null && 
      DateTime.now().difference(q.sentDate!).inHours >= 48
    ).length;
  }

  Future<void> sendAutomatedFollowUp(QuoteSummary quote) async {
    // Simulate API call to Twilio or SendGrid
    await Future.delayed(const Duration(seconds: 1));
    // In reality, we'd update the quote status in Firebase
  }
}
