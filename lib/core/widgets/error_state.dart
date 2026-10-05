import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'devpad_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message = 'Something went wrong.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              DevPadButton(
                label: 'Try again',
                onPressed: onRetry,
                variant: DevPadButtonVariant.secondary,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}