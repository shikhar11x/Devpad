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
          'Saved',
          AppColors.success,
        ),
      NoteSaveStatus.unsaved => (
          Icons.edit_outlined,
          'Editing...',
          AppColors.textMuted,
        ),
      NoteSaveStatus.saving => (
          Icons.sync,
          'Saving...',
          AppColors.textMuted,
        ),
      NoteSaveStatus.queued => (
          Icons.cloud_off_outlined,
          'Offline · will sync',
          AppColors.warning,
        ),
      NoteSaveStatus.error => (
          Icons.error_outline,
          'Not saved · Retry',
          AppColors.error,
        ),
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono.copyWith(fontSize: 11, color: color),
          ),
        ),
      ],
    );

    if (status != NoteSaveStatus.error) return content;

    return Tooltip(
      message: errorMessage ?? 'Could not save this note.',
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: content,
        ),
      ),
    );
  }
}