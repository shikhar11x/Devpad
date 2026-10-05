import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../providers/auth_providers.dart';

/// Shown while Firebase restores the saved session. The router redirects
/// away automatically once auth state is known.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    if (auth.hasError && !auth.hasValue) {
      return Scaffold(
        body: ErrorState(
          message: 'Could not check your sign-in status.',
          onRetry: () => ref.invalidate(authStateProvider),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.tagline,
              style: AppTheme.mono.copyWith(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            const LoadingState(message: 'Checking session...'),
          ],
        ),
      ),
    );
  }
}