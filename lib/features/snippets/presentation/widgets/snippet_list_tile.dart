import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/snippet.dart';
import '../code_languages.dart';

class SnippetListTile extends StatefulWidget {
  const SnippetListTile({
    super.key,
    required this.snippet,
    required this.selected,
    required this.onTap,
  });

  final Snippet snippet;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<SnippetListTile> createState() => _SnippetListTileState();
}

class _SnippetListTileState extends State<SnippetListTile> {
  bool _hovered = false;

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
    final radius = BorderRadius.circular(AppTheme.radiusSm);
    final snippet = widget.snippet;
    final selected = widget.selected;
    final title = snippet.title.trim();
    final preview = _firstLine(snippet.code);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.1)
              : (_hovered
                  ? AppColors.surfaceHigh.withValues(alpha: 0.5)
                  : Colors.transparent),
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.55)
                : (_hovered
                    ? AppColors.borderBright
                    : Colors.transparent),
            width: 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.code,
                        size: 16,
                        color: selected ? AppColors.accent : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title.isEmpty ? 'untitled_snippet' : title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: title.isEmpty
                                ? AppColors.textDim
                                : (selected ? AppColors.accent : AppColors.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          languageLabel(snippet.language).toUpperCase(),
                          style: AppTheme.mono.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.mono.copyWith(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'MODIFIED // ${DateFormatter.relative(snippet.updatedAt)}',
                    style: AppTheme.mono.copyWith(
                      fontSize: 10,
                      color: AppColors.textDim,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}