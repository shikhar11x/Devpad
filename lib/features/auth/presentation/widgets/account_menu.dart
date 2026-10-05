import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';

enum _AccountAction { signOut }

/// Avatar button with the signed-in user and a Sign out action.
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final email = user.email;

    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account',
      color: AppColors.surfaceHigh,
      offset: const Offset(0, 40),
      onSelected: (action) {
        if (action == _AccountAction.signOut) {
          ref.read(authControllerProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AccountAction>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (email != null && email != user.label)
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.signOut,
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
          child: Text(
            user.initial,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}