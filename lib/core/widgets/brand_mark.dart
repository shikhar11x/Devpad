import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Animated Cyber Terminal logo tile with glowing border and blinking `_` prompt.
class BrandMark extends StatefulWidget {
  const BrandMark({super.key, this.size = 32});

  final double size;

  @override
  State<BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<BrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = size * 0.26;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141D33),
            Color(0xFF0D1322),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D8F6).withValues(alpha: 0.22),
            blurRadius: size * 0.35,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF818CF8).withValues(alpha: 0.15),
            blurRadius: size * 0.45,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '>',
            style: AppTheme.mono.copyWith(
              color: const Color(0xFF00D8F6),
              fontWeight: FontWeight.w800,
              fontSize: size * 0.44,
              shadows: const [
                Shadow(color: Color(0xFF00D8F6), blurRadius: 6),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _blinkController,
            builder: (context, _) {
              final opacity = _blinkController.value > 0.45 ? 1.0 : 0.12;
              return Opacity(
                opacity: opacity,
                child: Text(
                  '_',
                  style: AppTheme.mono.copyWith(
                    color: const Color(0xFF38BDF8),
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.44,
                    shadows: const [
                      Shadow(color: Color(0xFF38BDF8), blurRadius: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Cyber Logo + app name with glowing title and tech badge.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(size: 28),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0)],
          ).createShader(bounds),
          child: Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Text(
            'DEV',
            style: AppTheme.mono.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}