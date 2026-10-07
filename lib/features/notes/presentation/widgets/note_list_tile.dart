import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';

class NoteListTile extends StatefulWidget {
  const NoteListTile({
    super.key,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final Note note;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<NoteListTile> createState() => _NoteListTileState();
}

class _NoteListTileState extends State<NoteListTile> {
  bool _hovered = false;

  static final _markdownLead =
      RegExp(r'^(#{1,6}\s+|[-*+]\s+(\[[ xX]\]\s+)?|>\s+)');

  static String _title(Note n) {
    final t = n.title.trim();
    return t.isEmpty ? 'untitled_note.md' : t;
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
    final radius = BorderRadius.circular(AppTheme.radiusSm);
    final note = widget.note;
    final selected = widget.selected;
    final preview = _preview(note.content);

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
                        Icons.sticky_note_2_outlined,
                        size: 15,
                        color: selected ? AppColors.accent : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _title(note),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: note.title.trim().isEmpty
                                ? AppColors.textDim
                                : (selected ? AppColors.accent : AppColors.text),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'EDITED // ${DateFormatter.relative(note.updatedAt)}',
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