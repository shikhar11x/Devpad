import 'package:flutter/material.dart';

import '../../core/widgets/coming_soon.dart';
import '../../core/widgets/disabled_search_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Middle column of the desktop layout. Real Pad list arrives in Stage 2.
class PadExplorerPanel extends StatelessWidget {
  const PadExplorerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'PADS',
              style: AppTheme.mono.copyWith(
                fontSize: 11,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DisabledSearchField(),
          ),
          const Expanded(
            child: ComingSoonPlaceholder(
              icon: Icons.folder_copy_outlined,
              title: 'Pad Explorer',
              description: 'Your Pads will be listed here.',
            ),
          ),
        ],
      ),
    );
  }
}