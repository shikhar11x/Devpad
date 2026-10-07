import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/pending_writes.dart';
import '../../features/pads/presentation/providers/pad_providers.dart';
import '../theme/app_colors.dart';

/// Thin bar above the workspace: offline notice and pending-sync count.
/// Hidden when everything is online and synced.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectionProvider).value ?? true;

    return ValueListenableBuilder<int>(
      valueListenable: PendingWrites.count,
      builder: (context, pending, _) {
        String? message;
        var icon = Icons.cloud_off_outlined;
        var color = AppColors.warning;
        final noun = pending == 1 ? 'change' : 'changes';

        if (!online) {
          message = pending > 0
              ? 'Offline · $pending $noun waiting to sync'
              : 'Offline · showing saved data. Changes sync when you reconnect.';
        } else if (pending > 0) {
          message = 'Syncing $pending $noun...';
          icon = Icons.sync;
          color = AppColors.accent;
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}