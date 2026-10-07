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
      showCornerBrackets: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(feature.icon, size: 16, color: AppColors.accent),
              ),
              const SizedBox(width: 8),
              Text(
                '0x${feature.stage.toString().padLeft(2, '0')} // MODULE',
                style: AppTheme.mono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDim,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const ComingSoonBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}