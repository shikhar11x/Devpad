import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/devpad_button.dart';
import '../providers/auth_controller.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return DevPadButton(
      label: 'Continue with Google',
      icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
      variant: DevPadButtonVariant.secondary,
      isLoading: auth.action == AuthAction.google,
      onPressed: auth.isLoading
          ? null
          : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
    );
  }
}