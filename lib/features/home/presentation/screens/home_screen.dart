import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/planned_features.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../pads/presentation/widgets/recent_pads_section.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = context.screenSize.isMobile ? 16.0 : 32.0;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 24),
          sliver: const SliverToBoxAdapter(child: _Hero()),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          sliver: const SliverToBoxAdapter(child: RecentPadsSection()),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'ROADMAP',
                style: AppTheme.mono.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340,
              mainAxisExtent: 148,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: plannedFeatures.length,
            itemBuilder: (context, i) =>
                FeatureCard(feature: plannedFeatures[i]),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandMark(size: 56),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.tagline,
          style: AppTheme.mono.copyWith(fontSize: 16, color: AppColors.accent),
        ),
        const SizedBox(height: 12),
        Text(
          'A developer workspace for ideas, notes, code, diagrams and tasks.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 8, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Stage 9 · Canvas ready',
              style: AppTheme.mono.copyWith(
                fontSize: 12,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
