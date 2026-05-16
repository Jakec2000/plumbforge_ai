import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../field_mode/presentation/widgets/field_mode_toggle.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quoting/data/services/follow_up_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldModeToggle(),
            const SizedBox(height: 24),
            Text('Welcome back, Pro', style: theme.textTheme.displayLarge),
            const SizedBox(height: 8),
            Text('You have 3 quotes pending approval.', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 40),
            
            _buildActionCard(
              context,
              title: 'New AI Quote',
              subtitle: 'Photo & Voice to Quote',
              icon: Icons.camera_alt,
              color: theme.colorScheme.primary,
              onTap: () => context.pushNamed('intake'),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              title: 'Compliance Checker',
              subtitle: 'Scan against AS/NZS 3500:2025',
              icon: Icons.check_circle_outline,
              color: theme.colorScheme.secondary,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              title: 'AI Routing & Scheduling',
              subtitle: 'Optimize driving for today',
              icon: Icons.route,
              color: Colors.blue[700]!,
              onTap: () => context.pushNamed('routing'),
            ),
            const SizedBox(height: 16),

            _buildActionCard(
              context,
              title: 'Wholesale Integrations',
              subtitle: 'Connect Reece, Tradelink & more',
              icon: Icons.storefront,
              color: Colors.purple[700]!,
              onTap: () => context.pushNamed('integrations'),
            ),
            const SizedBox(height: 16),

            Consumer(
              builder: (context, ref, child) {
                final followUpService = ref.watch(followUpServiceProvider);
                final pendingCount = followUpService.pendingFollowUpsCount;
                if (pendingCount > 0) {
                  return Card(
                    color: Colors.orange[50],
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      title: Text('\$pendingCount Quotes Need Follow-Up!'),
                      subtitle: const Text('Tap to send automated SMS reminders.'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Send All'),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

            Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(authStateProvider).value;
                if (user?.isAdmin == true) {
                  return _buildActionCard(
                    context,
                    title: 'Admin Dashboard',
                    subtitle: 'Team management & revenue',
                    icon: Icons.shield,
                    color: Colors.red[800]!,
                    onTap: () => context.pushNamed('admin'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
