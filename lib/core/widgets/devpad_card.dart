import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Next-Gen Cyber HUD Glass Card with glowing animated border,
/// corner bracket accents, and subtle hover lift.
class DevPadCard extends StatefulWidget {
  const DevPadCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.showCornerBrackets = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final bool showCornerBrackets;

  @override
  State<DevPadCard> createState() => _DevPadCardState();
}

class _DevPadCardState extends State<DevPadCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final highlight = _hovered;
    final radius = BorderRadius.circular(AppTheme.radius);
    final glow = widget.glowColor ?? AppColors.accent;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          highlight && interactive ? -2.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: highlight ? AppColors.surfaceHigh : AppColors.surfaceCard,
          borderRadius: radius,
          border: Border.all(
            color: highlight
                ? glow.withValues(alpha: 0.55)
                : AppColors.border,
            width: highlight ? 1.15 : 1.0,
          ),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: glow.withValues(alpha: interactive ? 0.18 : 0.09),
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppColors.accentAlt.withValues(alpha: 0.08),
                    blurRadius: 22,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // Corner HUD highlight lines on hover or when enabled
              if (highlight || widget.showCornerBrackets)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CornerBracketPainter(
                        color: glow.withValues(alpha: highlight ? 0.7 : 0.25),
                      ),
                    ),
                  ),
                ),
              // Main content
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  splashColor: glow.withValues(alpha: 0.1),
                  highlightColor: glow.withValues(alpha: 0.05),
                  child: Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const len = 7.0;

    // Top-left bracket
    canvas.drawLine(const Offset(4, 4), const Offset(4 + len, 4), paint);
    canvas.drawLine(const Offset(4, 4), const Offset(4, 4 + len), paint);

    // Top-right bracket
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4 - len, 4), paint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4, 4 + len), paint);

    // Bottom-left bracket
    canvas.drawLine(Offset(4, size.height - 4), Offset(4 + len, size.height - 4), paint);
    canvas.drawLine(Offset(4, size.height - 4), Offset(4, size.height - 4 - len), paint);

    // Bottom-right bracket
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4 - len, size.height - 4), paint);
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4, size.height - 4 - len), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}