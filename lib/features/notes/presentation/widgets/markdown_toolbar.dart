import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../markdown_formatter.dart';

/// Formatting buttons for cyber markdown editor.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({super.key, required this.onAction});

  final ValueChanged<MarkdownAction> onAction;

  static const _items = <(MarkdownAction, IconData, String)>[
    (MarkdownAction.bold, Icons.format_bold, 'Bold (Ctrl+B)'),
    (MarkdownAction.italic, Icons.format_italic, 'Italic (Ctrl+I)'),
    (MarkdownAction.heading, Icons.title, 'Heading'),
    (MarkdownAction.bulletList, Icons.format_list_bulleted, 'Bullet list'),
    (MarkdownAction.checklist, Icons.checklist, 'Checklist'),
    (MarkdownAction.quote, Icons.format_quote, 'Quote'),
    (MarkdownAction.inlineCode, Icons.code, 'Inline code'),
    (MarkdownAction.codeBlock, Icons.data_object, 'Code block'),
    (MarkdownAction.link, Icons.link, 'Link'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          children: [
            for (final (action, icon, tip) in _items)
              IconButton(
                tooltip: tip,
                visualDensity: VisualDensity.compact,
                icon: Icon(icon, size: 17),
                color: AppColors.textMuted,
                hoverColor: AppColors.accent.withValues(alpha: 0.12),
                onPressed: () => onAction(action),
              ),
          ],
        ),
      ),
    );
  }
}