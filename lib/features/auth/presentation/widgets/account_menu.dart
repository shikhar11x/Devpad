import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';

enum _AccountAction { signOut }

/// Avatar button with cyber glow, online telemetry beacon, and stylized popup.
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final email = user.email;

    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account // Operator Info',
      color: AppColors.surfaceElevated,
      elevation: 16,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.cyan.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
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
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OPERATOR // ONLINE',
                    style: AppTheme.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user.label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (email != null && email != user.label) ...[
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTheme.mono.copyWith(
                    color: AppColors.textDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_AccountAction>(
          value: _AccountAction.signOut,
          child: Row(
            children: [
              Icon(Icons.power_settings_new_rounded, size: 18, color: AppColors.rose.withValues(alpha: 0.9)),
              const SizedBox(width: 10),
              Text(
                'DISCONNECT // SIGN OUT',
                style: AppTheme.mono.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.rose,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.cyan, AppColors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.initial.toUpperCase(),
                  style: AppTheme.mono.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald,
                  border: Border.all(color: AppColors.background, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.emerald,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}