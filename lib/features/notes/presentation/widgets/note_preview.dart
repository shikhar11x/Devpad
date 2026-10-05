import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Rendered Markdown in the DevPad dark style.
class NotePreview extends StatelessWidget {
  const NotePreview({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const Center(
        child: Text(
          'Nothing to preview yet.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final theme = Theme.of(context);
    final sheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      a: const TextStyle(color: AppColors.accent),
      code: AppTheme.mono.copyWith(
        fontSize: 13,
        color: AppColors.text,
        backgroundColor: AppColors.surfaceHigh,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      blockquotePadding: const EdgeInsets.all(12),
      blockquoteDecoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
    );

    return Markdown(
      data: content,
      selectable: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      styleSheet: sheet,
    );
  }
}