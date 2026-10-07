import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/pad.dart';
import 'pad_icons.dart';
import 'pad_menu.dart';

/// Pad icon, title, archived flag and options menu. Shows a back button
/// on mobile/tablet, where the Pad list is a separate screen.
class PadHeader extends StatelessWidget {
  const PadHeader({super.key, required this.pad});

  final Pad pad;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final theme = Theme.of(context);
    final edge = size.isMobile ? 16.0 : 32.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(edge, 16, edge, 12),
      child: Row(
        children: [
          if (!size.isDesktop) ...[
            IconButton(
              tooltip: 'All Pads',
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => context.go(AppRoutes.pads),
            ),
            const SizedBox(width: 4),
          ],
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(padIconFor(pad.icon), size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '0xPAD',
                        style: AppTheme.mono.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (pad.archived)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'STATUS // ARCHIVED',
                      style: AppTheme.mono.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  )
                else
                  Text(
                    'STATUS // ONLINE & SYNCED',
                    style: AppTheme.mono.copyWith(
                      fontSize: 10,
                      color: AppColors.textDim,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
          PadMenuButton(pad: pad, leaveOnDelete: true),
        ],
      ),
    );
  }
}