import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/planned_features.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/devpad_card.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.feature});

  final PlannedFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DevPadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(feature.icon, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'STAGE ${feature.stage}',
                style: AppTheme.mono.copyWith(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              const ComingSoonBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}