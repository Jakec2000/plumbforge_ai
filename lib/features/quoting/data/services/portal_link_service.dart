import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

final portalLinkProvider = Provider<PortalLinkService>((ref) {
  return PortalLinkService();
});

class PortalLinkService {
  Future<String> generateMagicLink(String customerId, double totalAmount) async {
    // Simulate pushing quote payload to Firebase/Vercel
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate a secure, unique portal link
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'https://portal.plumbforge.ai/quote/\$customerId-\$randomId';
  }
}
