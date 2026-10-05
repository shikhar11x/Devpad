import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/snippet.dart';
import '../code_languages.dart';

class SnippetListTile extends StatelessWidget {
  const SnippetListTile({
    super.key,
    required this.snippet,
    required this.selected,
    required this.onTap,
  });

  final Snippet snippet;
  final bool selected;
  final VoidCallback onTap;

  static String _firstLine(String code) {
    for (final raw in code.split('\n')) {
      final line = raw.trim();
      if (line.isNotEmpty) return line;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(8);
    final title = snippet.title.trim();
    final preview = _firstLine(snippet.code);

    return Material(
      color: selected
          ? AppColors.accent.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? 'Untitled snippet' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: title.isEmpty
                            ? AppColors.textMuted
                            : AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      languageLabel(snippet.language),
                      style: AppTheme.mono.copyWith(
                        fontSize: 10,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Edited ${DateFormatter.relative(snippet.updatedAt)}',
                style: AppTheme.mono.copyWith(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}