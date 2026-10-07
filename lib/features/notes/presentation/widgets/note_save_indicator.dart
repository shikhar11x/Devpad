import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

enum NoteSaveStatus { saved, unsaved, saving, queued, error }

class NoteSaveIndicator extends StatelessWidget {
  const NoteSaveIndicator({
    super.key,
    required this.status,
    this.errorMessage,
    this.onRetry,
  });

  final NoteSaveStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status) {
      NoteSaveStatus.saved => (
          Icons.check_circle_outline,
          'SYNCED',
          AppColors.neonGreen,
        ),
      NoteSaveStatus.unsaved => (
          Icons.edit_outlined,
          'BUFFER_DIRTY',
          AppColors.textMuted,
        ),
      NoteSaveStatus.saving => (
          Icons.sync,
          'PERSISTING...',
          AppColors.accent,
        ),
      NoteSaveStatus.queued => (
          Icons.cloud_off_outlined,
          'OFFLINE // QUEUED',
          AppColors.warning,
        ),
      NoteSaveStatus.error => (
          Icons.error_outline,
          'WRITE_ERROR // RETRY',
          AppColors.error,
        ),
    };

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
            shadows: status == NoteSaveStatus.saved || status == NoteSaveStatus.saving
                ? [Shadow(color: color, blurRadius: 6)]
                : null,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );

    final interactive = status == NoteSaveStatus.error && onRetry != null;

    final child = interactive
        ? InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(4),
            child: content,
          )
        : content;

    return errorMessage == null ? child : Tooltip(message: errorMessage, child: child);
  }
}