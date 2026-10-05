import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/devpad_text_field.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(authControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final ok =
        await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (ok && mounted) {
      setState(() {
        _successMessage =
            'If an account exists for $email, a reset link is on its way. Check your inbox.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;

    return AuthScaffold(
      title: 'Reset password',
      subtitle: "Enter your email and we'll send a reset link.",
      footer: TextButton.icon(
        onPressed: busy ? null : () => context.go(AppRoutes.login),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: const Text('Back to sign in'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthMessageBanner(message: auth.errorMessage),
            AuthMessageBanner(message: _successMessage, isError: false),
            DevPadTextField(
              controller: _email,
              label: 'EMAIL',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onFieldSubmitted: (_) => busy ? null : _submit(),
              enabled: !busy,
            ),
            const SizedBox(height: 20),
            DevPadButton(
              label: 'Send reset link',
              isLoading: auth.action == AuthAction.reset,
              onPressed: busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}