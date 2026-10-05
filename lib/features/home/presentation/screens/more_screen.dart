import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/planned_features.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/devpad_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: plannedFeatures.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'More',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }
        final f = plannedFeatures[i - 1];
        return DevPadCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(f.icon, color: AppColors.accent),
            title: Text(f.title),
            subtitle: Text(
              f.description,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            trailing: const ComingSoonBadge(),
          ),
        );
      },
    );
  }
}