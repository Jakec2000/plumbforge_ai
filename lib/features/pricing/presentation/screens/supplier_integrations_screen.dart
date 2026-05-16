import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/plumbing_supplier.dart';
import '../providers/supplier_integration_provider.dart';

import '../../auth/providers/auth_provider.dart';

class SupplierIntegrationsScreen extends ConsumerWidget {
  const SupplierIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(supplierIntegrationsProvider);
    final primary = ref.watch(primarySupplierProvider);
    final user = ref.watch(authStateProvider).value;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesale Databases'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          final isPrimary = supplier.type == primary;

          return Card(
            elevation: isPrimary ? 4 : 1,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              side: isPrimary 
                  ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: supplier.isConnected ? Colors.green[100] : Colors.grey[200],
                child: Icon(
                  Icons.storefront,
                  color: supplier.isConnected ? Colors.green[700] : Colors.grey[600],
                ),
              ),
              title: Text(
                supplier.type.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(supplier.isConnected ? 'Connected' : 'Not Connected'),
              trailing: isPrimary
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('PRIMARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (supplier.isConnected) ...[
                        Text('Account ID: \${supplier.accountId ?? "N/A"}'),
                        const SizedBox(height: 8),
                        const Text('API Key: ••••••••••••'),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (supplier.isConnected && isAdmin)
                            TextButton(
                              onPressed: () {
                                ref.read(supplierIntegrationsProvider.notifier).disconnectSupplier(supplier.type);
                                if (isPrimary) {
                                  ref.read(primarySupplierProvider.notifier).state = SupplierType.generic;
                                }
                              },
                              child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(width: 8),
                          if (!supplier.isConnected && isAdmin)
                            ElevatedButton(
                              onPressed: () => _showConnectDialog(context, ref, supplier.type),
                              child: const Text('Connect'),
                            ),
                          if (!supplier.isConnected && !isAdmin)
                            const Text('Ask Admin to Connect', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          if (supplier.isConnected && !isPrimary)
                            ElevatedButton(
                              onPressed: () {
                                ref.read(primarySupplierProvider.notifier).state = supplier.type;
                              },
                              child: const Text('Set as Primary'),
                            ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConnectDialog(BuildContext context, WidgetRef ref, SupplierType type) {
    final accountCtrl = TextEditingController();
    final apiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect \${type.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountCtrl,
              decoration: const InputDecoration(labelText: 'Account ID / Trade Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiCtrl,
              decoration: const InputDecoration(labelText: 'API Key / Secret'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(supplierIntegrationsProvider.notifier).connectSupplier(type, accountCtrl.text, apiCtrl.text);
              Navigator.pop(context);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
