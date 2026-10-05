import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    super.key,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final Note note;
  final bool selected;
  final VoidCallback onTap;

  static final _markdownLead =
      RegExp(r'^(#{1,6}\s+|[-*+]\s+(\[[ xX]\]\s+)?|>\s+)');

  static String _title(Note n) {
    final t = n.title.trim();
    return t.isEmpty ? 'Untitled note' : t;
  }

  /// First non-empty line, without its leading Markdown marker.
  static String _preview(String content) {
    for (final raw in content.split('\n')) {
      final line = raw.trim();
      if (line.isNotEmpty) return line.replaceFirst(_markdownLead, '');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(8);
    final preview = _preview(note.content);

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
              Text(
                _title(note),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: note.title.trim().isEmpty
                      ? AppColors.textMuted
                      : AppColors.text,
                ),
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Edited ${DateFormatter.relative(note.updatedAt)}',
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