import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../pad_section.dart';

/// Next-Gen Cyber Tab Strip for workspace sections with illuminated glow and tech indices.
class PadSectionBar extends StatelessWidget {
  const PadSectionBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PadSection selected;
  final ValueChanged<PadSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (int i = 0; i < PadSection.values.length; i++)
              _SectionTab(
                index: i + 1,
                section: PadSection.values[i],
                selected: PadSection.values[i] == selected,
                onTap: () => onSelected(PadSection.values[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTab extends StatefulWidget {
  const _SectionTab({
    required this.index,
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final PadSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SectionTab> createState() => _SectionTabState();
}

class _SectionTabState extends State<_SectionTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final color = selected
        ? AppColors.accent
        : (_hovered ? AppColors.text : AppColors.textMuted);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.08)
                : (_hovered
                    ? AppColors.surfaceHigh.withValues(alpha: 0.5)
                    : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 2.2,
              ),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '0${widget.index}',
                  style: AppTheme.mono.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.accent
                        : AppColors.textDim,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                widget.section.icon,
                size: 15,
                color: color,
                shadows: selected
                    ? const [Shadow(color: AppColors.accent, blurRadius: 8)]
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                widget.section.label,
                style: AppTheme.mono.copyWith(
                  fontSize: 12,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                  shadows: selected
                      ? const [Shadow(color: AppColors.accent, blurRadius: 6)]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}