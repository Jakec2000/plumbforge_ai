import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pricing/domain/models/quote_item.dart';

final offlineSyncProvider = Provider<OfflineSyncEngine>((ref) {
  return OfflineSyncEngine();
});

class OfflineSyncEngine {
  final List<QuoteSummary> _offlineQueue = [];

  bool get hasPendingSync => _offlineQueue.isNotEmpty;
  int get pendingCount => _offlineQueue.length;

  Future<void> queueQuoteForSync(QuoteSummary quote) async {
    _offlineQueue.add(quote);
    // In reality, this saves to Hive or local SQLite
  }

  Future<void> attemptSync() async {
    if (_offlineQueue.isEmpty) return;

    // Simulate network check and sync
    await Future.delayed(const Duration(seconds: 2));
    
    // On success, clear queue
    _offlineQueue.clear();
  }
}
