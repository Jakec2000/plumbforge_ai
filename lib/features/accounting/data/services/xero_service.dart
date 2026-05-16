import 'package:flutter_riverpod/flutter_riverpod.dart';

final xeroServiceProvider = Provider<XeroService>((ref) {
  return XeroService();
});

class XeroService {
  Future<bool> createDraftInvoice(double total, String contactName) async {
    // Simulate OAuth2 and API request to Xero Accounting
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate a successful 200 OK response from Xero
    return true; 
  }
}
