import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  static const String standardsBoxName = 'standards_cache';
  static const String pricingBoxName = 'pricing_cache';

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(standardsBoxName);
    await Hive.openBox(pricingBoxName);
  }

  // Pre-load mock standards
  Future<void> seedStandardsCache(Map<String, dynamic> standardsData) async {
    final box = Hive.box(standardsBoxName);
    await box.put('as_nzs_3500_2025', standardsData);
  }

  // Fetch standards instantly even without Firestore
  Map<dynamic, dynamic>? getStandardsCache() {
    final box = Hive.box(standardsBoxName);
    return box.get('as_nzs_3500_2025');
  }
}
