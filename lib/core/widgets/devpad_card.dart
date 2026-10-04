import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Bordered panel. Hover/ripple effects only apply when [onTap] is set.
class DevPadCard extends StatefulWidget {
  const DevPadCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<DevPadCard> createState() => _DevPadCardState();
}

class _DevPadCardState extends State<DevPadCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final highlight = interactive && _hovered;
    final radius = BorderRadius.circular(AppTheme.radius);

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: highlight ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: radius,
          border: Border.all(
            color: highlight
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}