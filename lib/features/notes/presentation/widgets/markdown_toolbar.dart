import 'package:flutter/material.dart';

import '../markdown_formatter.dart';

/// Formatting buttons. Scrolls sideways on narrow screens.
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final (action, icon, tip) in _items)
            IconButton(
              tooltip: tip,
              visualDensity: VisualDensity.compact,
              icon: Icon(icon, size: 18),
              onPressed: () => onAction(action),
            ),
        ],
      ),
    );
  }
}