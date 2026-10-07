import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

enum DevPadButtonVariant { primary, secondary }

/// Refined Cyber Hacker Glowing Button with interactive hover animation.
class DevPadButton extends StatefulWidget {
  const DevPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = DevPadButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final DevPadButtonVariant variant;
  final bool expand;

  @override
  State<DevPadButton> createState() => _DevPadButtonState();
}

class _DevPadButtonState extends State<DevPadButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == DevPadButtonVariant.primary;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final radius = BorderRadius.circular(AppTheme.radiusSm);

    final content = widget.isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: isPrimary ? Colors.white : AppColors.accent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.mono.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: !enabled
                        ? AppColors.textDim
                        : isPrimary
                            ? Colors.white
                            : AppColors.text,
                  ),
                ),
              ),
            ],
          );

    final VoidCallback? onTap = widget.isLoading ? () {} : widget.onPressed;

    final Widget buttonWidget = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          _hovered && enabled ? -1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: isPrimary
              ? (enabled
                  ? LinearGradient(
                      colors: _hovered
                          ? const [Color(0xFF06B6D4), Color(0xFF6366F1)]
                          : const [Color(0xFF0EA5E9), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF161E2E),
                      ],
                    ))
              : null,
          color: isPrimary
              ? null
              : (_hovered && enabled
                  ? AppColors.surfaceHigh
                  : AppColors.surfaceCard),
          border: Border.all(
            color: isPrimary
                ? (_hovered && enabled
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7))
                : (_hovered && enabled
                    ? AppColors.accent.withValues(alpha: 0.6)
                    : AppColors.border),
            width: 1.1,
          ),
          boxShadow: enabled
              ? (isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(
                          alpha: _hovered ? 0.35 : 0.22,
                        ),
                        blurRadius: _hovered ? 16 : 10,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(
                          alpha: _hovered ? 0.25 : 0.15,
                        ),
                        blurRadius: 8,
                      ),
                    ]
                  : (_hovered
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ]
                      : null))
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              constraints: const BoxConstraints(minHeight: 42),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: buttonWidget)
        : buttonWidget;
  }
}