import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../providers/pad_providers.dart';
import 'pad_icons.dart';

/// Recently opened Pads for the Home screen. Hidden when there are none.
class RecentPadsSection extends ConsumerWidget {
  const RecentPadsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pads = ref.watch(recentPadsProvider);
    if (pads.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'RECENT PADS',
              style: AppTheme.mono.copyWith(
                fontSize: 11,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final pad in pads)
                SizedBox(
                  width: 260,
                  child: DevPadCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => context.go(AppRoutes.padDetail(pad.id)),
                    child: Row(
                      children: [
                        Icon(padIconFor(pad.icon), color: AppColors.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pad.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Opened ${DateFormatter.relative(pad.lastOpenedAt!)}',
                                style: AppTheme.mono.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}