import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/pending_writes.dart';
import '../../features/pads/presentation/providers/pad_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Thin cyber telemetry bar above workspace: offline notice and pending-sync count.
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
              ? 'OFFLINE // $pending $noun waiting to sync'
              : 'OFFLINE // Showing cached telemetry. Will re-sync when online.';
        } else if (pending > 0) {
          message = 'SYNCING // $pending $noun propagating to cloud...';
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    border: Border(
                      bottom: BorderSide(
                        color: color.withValues(alpha: 0.4),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 15, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: AppTheme.mono.copyWith(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
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