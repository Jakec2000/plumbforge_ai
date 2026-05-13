import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/field_mode_provider.dart';

class FieldModeToggle extends ConsumerWidget {
  const FieldModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFieldMode = ref.watch(fieldModeProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isFieldMode ? theme.colorScheme.error.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFieldMode ? theme.colorScheme.error : Colors.grey[400]!,
        )
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFieldMode ? Icons.offline_bolt : Icons.cloud_done,
            color: isFieldMode ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isFieldMode ? 'Field Mode (Offline)' : 'Office Mode (Online)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFieldMode ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isFieldMode,
            activeColor: theme.colorScheme.error,
            onChanged: (value) {
              ref.read(fieldModeProvider.notifier).state = value;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'Field Mode Activated: Voice First & Offline Syncing Enabled' : 'Office Mode Activated'),
                  backgroundColor: value ? theme.colorScheme.error : theme.colorScheme.primary,
                  duration: const Duration(seconds: 2),
                )
              );
            },
          )
        ],
      ),
    );
  }
}
