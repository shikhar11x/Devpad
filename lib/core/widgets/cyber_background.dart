import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Next-Generation Cyber Hacker Ambient Canvas.
/// Paints a living cyber matrix grid, breathing atmospheric nebula flares,
/// and a subtle sweeping holographic scanline.
class CyberBackground extends StatefulWidget {
  const CyberBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showScanline = true,
    this.pulseGlow = true,
    this.primaryGlow = const Color(0xFF00D8F6),
    this.secondaryGlow = const Color(0xFF6366F1),
  });

  final Widget child;
  final bool showGrid;
  final bool showScanline;
  final bool pulseGlow;
  final Color primaryGlow;
  final Color secondaryGlow;

  @override
  State<CyberBackground> createState() => _CyberBackgroundState();
}

class _CyberBackgroundState extends State<CyberBackground>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cyber Canvas backdrop
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _scanController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _CyberPainter(
                  pulseProgress: widget.pulseGlow ? _pulseController.value : 0.5,
                  scanProgress: widget.showScanline ? _scanController.value : 0.0,
                  showGrid: widget.showGrid,
                  showScanline: widget.showScanline,
                  primaryColor: widget.primaryGlow,
                  secondaryColor: widget.secondaryGlow,
                ),
              );
            },
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _CyberPainter extends CustomPainter {
  _CyberPainter({
    required this.pulseProgress,
    required this.scanProgress,
    required this.showGrid,
    required this.showScanline,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double pulseProgress;
  final double scanProgress;
  final bool showGrid;
  final bool showScanline;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Midnight Base
    final basePaint = Paint()..color = AppColors.background;
    canvas.drawRect(Offset.zero & size, basePaint);

    // 2. Dual Atmospheric Nebula Blooms
    final pulseScale = 0.9 + (0.2 * pulseProgress);

    // Top-left Sky/Cyan bloom
    final flare1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.75),
        radius: 1.25 * pulseScale,
        colors: [
          primaryColor.withValues(alpha: 0.07 * pulseScale),
          primaryColor.withValues(alpha: 0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, flare1);

    // Bottom-right Indigo bloom
    final flare2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, 0.8),
        radius: 1.35 * pulseScale,
        colors: [
          secondaryColor.withValues(alpha: 0.065 * pulseScale),
          secondaryColor.withValues(alpha: 0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, flare2);

    // Center subtle Emerald flare
    final flare3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.2, -0.2),
        radius: 0.8 * pulseScale,
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.02 * pulseScale),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, flare3);

    // 3. Cyber Tech Perspective Grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.022)
        ..strokeWidth = 1.0;

      const gridSize = 42.0;
      final cols = (size.width / gridSize).ceil();
      final rows = (size.height / gridSize).ceil();

      for (int i = 0; i <= cols; i++) {
        final x = i * gridSize;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }

      for (int j = 0; j <= rows; j++) {
        final y = j * gridSize;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      // Tech Crosshairs & Intersections
      final dotPaint = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.07)
        ..strokeWidth = 1.5;

      const crossStep = 3;
      for (int i = 0; i <= cols; i += crossStep) {
        for (int j = 0; j <= rows; j += crossStep) {
          final x = i * gridSize;
          final y = j * gridSize;
          canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
        }
      }
    }

    // 4. Sweeping Holographic Scanline
    if (showScanline && size.height > 0) {
      final scanY = scanProgress * size.height;
      final scanPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            primaryColor.withValues(alpha: 0.025),
            primaryColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 60));

      canvas.drawRect(Rect.fromLTWH(0, scanY - 30, size.width, 60), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showScanline != showScanline ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
