import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/pad.dart';
import 'pad_icons.dart';
import 'pad_menu.dart';

class PadListTile extends StatefulWidget {
  const PadListTile({
    super.key,
    required this.pad,
    required this.selected,
    required this.onTap,
  });

  final Pad pad;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<PadListTile> createState() => _PadListTileState();
}

class _PadListTileState extends State<PadListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppTheme.radiusSm);
    final pad = widget.pad;
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.12)
              : (_hovered
                  ? AppColors.surfaceHigh.withValues(alpha: 0.5)
                  : Colors.transparent),
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.5)
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
              padding: const EdgeInsets.fromLTRB(10, 8, 2, 8),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.surfaceCard
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent.withValues(alpha: 0.7)
                            : AppColors.border,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      padIconFor(pad.icon),
                      size: 18,
                      color: selected
                          ? AppColors.accent
                          : (_hovered ? AppColors.text : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pad.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: selected ? AppColors.text : null,
                          ),
                        ),
                        if (pad.description.isNotEmpty)
                          Text(
                            pad.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        Text(
                          'UPDATED // ${DateFormatter.relative(pad.updatedAt)}',
                          style: AppTheme.mono.copyWith(
                            fontSize: 10,
                            color: selected
                                ? AppColors.accent.withValues(alpha: 0.8)
                                : AppColors.textDim,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PadMenuButton(pad: pad, leaveOnDelete: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}