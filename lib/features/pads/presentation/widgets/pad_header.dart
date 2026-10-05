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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(padIconFor(pad.icon), color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pad.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (pad.archived)
                  Text(
                    'ARCHIVED',
                    style: AppTheme.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.warning,
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