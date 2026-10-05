import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

enum DevPadButtonVariant { primary, secondary }

class DevPadButton extends StatelessWidget {
  const DevPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = DevPadButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final DevPadButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == DevPadButtonVariant.primary;

    final content = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isPrimary ? Colors.white : AppColors.accent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
    );
    // While loading, ignore taps but keep the normal (non-greyed) look.
    final VoidCallback? onTap = isLoading ? () {} : onPressed;

    final button = isPrimary
        ? FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: shape,
            ),
            child: content,
          )
        : OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: shape,
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.border),
            ),
            child: content,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}