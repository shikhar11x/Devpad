import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/cyber_background.dart';
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
        body: CyberBackground(
          child: ErrorState(
            message: 'Could not check your sign-in status.',
            onRetry: () => ref.invalidate(authStateProvider),
          ),
        ),
      );
    }

    return Scaffold(
      body: CyberBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 72),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFF1F5F9), Color(0xFFBAE6FD)],
                ).createShader(bounds),
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '// ${AppConstants.tagline}',
                style: AppTheme.mono.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF38BDF8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 36),
              const LoadingState(message: 'INITIALIZING SESSION // AUTH CHECK'),
            ],
          ),
        ),
      ),
    );
  }
}