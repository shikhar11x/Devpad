import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/devpad_card.dart';

/// Shared centered layout for Login / Signup / Forgot password.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 48),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.tagline,
                    style: AppTheme.mono.copyWith(
                      fontSize: 12,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DevPadCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),
                        child,
                      ],
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 16),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}