import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../pad_section.dart';

/// Horizontally scrollable tab strip, so it fits phones and desktops alike.
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final section in PadSection.values)
              _SectionTab(
                section: section,
                selected: section == selected,
                onTap: () => onSelected(section),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final PadSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(section.icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              section.label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}