import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'devpad_button.dart';

/// Shows a cyber hacker styled confirmation modal for destructive or critical actions.
Future<bool?> showCyberConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  IconData icon = Icons.warning_amber_rounded,
  Color accentColor = AppColors.rose,
  bool isDestructive = true,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => CyberConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      accentColor: accentColor,
      isDestructive: isDestructive,
    ),
  );
}

class CyberConfirmDialog extends StatelessWidget {
  const CyberConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.icon = Icons.warning_amber_rounded,
    this.accentColor = AppColors.rose,
    this.isDestructive = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final Color accentColor;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDanger = isDestructive;

    return AlertDialog(
      backgroundColor: AppColors.surfaceSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDanger ? 'CONFIRM DESTRUCTION' : 'SYSTEM CONFIRMATION',
                  style: AppTheme.mono.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textDim,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        DevPadButton(
          label: confirmLabel,
          icon: Icon(icon, size: 16),
          variant: isDanger
              ? DevPadButtonVariant.danger
              : DevPadButtonVariant.primary,
          expand: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
