import 'package:flutter/material.dart';

/// Ultra-refined Cyber Hacker Dark Palette for DevPad.
/// Deep midnight obsidian glass with harmonious electric cyan & hyper-indigo luminescence.
abstract final class AppColors {
  // Surfaces - Deep, rich obsidian glass tones (Tokyo Night / Linear inspired)
  static const background = Color(0xFF080C15);
  static const surface = Color(0xFF0E1424);
  static const surfaceCard = Color(0xFF121B30);
  static const surfaceHigh = Color(0xFF1A2644);
  static const border = Color(0xFF1F2E4D);
  static const borderBright = Color(0xFF2E436E);

  // Typography - High legibility, crisp slate contrast
  static const text = Color(0xFFF8FAFC);
  static const textMuted = Color(0xFF94A3B8);
  static const textDim = Color(0xFF64748B);

  // Primary Cyber Luminescence - Tasteful, vibrant without harshness
  static const accent = Color(0xFF00D8F6); // Electric Ice Cyan
  static const accentAlt = Color(0xFF818CF8); // Hyper Indigo-Violet
  static const neonGreen = Color(0xFF10B981); // Crisp Matrix Emerald
  static const neonPink = Color(0xFFF43F5E); // Cyber Rose Pink
  static const neonAmber = Color(0xFFF59E0B); // Laser Amber

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFF43F5E);

  // Soft Ambient Glow Shadows
  static const glowCyan = Color(0x3300D8F6);
  static const glowPurple = Color(0x33818CF8);
  static const glowGreen = Color(0x3310B981);

  /// Generates smooth, luxurious ambient neon glow
  static List<BoxShadow> neonGlow({
    Color color = accent,
    double spread = 0,
    double blur = 16,
    double opacity = 0.22,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }
}