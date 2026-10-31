import 'package:flutter/material.dart';

/// Design tokens derived strictly from docs/design.md.
/// Warm editorial canvas with calibrated sRGB optical accents.
class AppColors {
  AppColors._();

  // Canvas & Surfaces
  static const Color canvas = Color(0xFFFFFDF6);
  static const Color surfaceElevated = Color(0xFFF8F3E8);
  static const Color surfaceSubtle = Color(0xFFF5EFE6);
  static const Color surfaceBorder = Color(0xFFE8DEC9);
  static const Color surfaceBorderSubtle = Color(0xFFF0E9DC);

  // Inks & Typography
  static const Color textMain = Color(0xFF1C1917);
  static const Color textMuted = Color(0xFF57534E);
  static const Color textFaint = Color(0xFF8F887C);

  // Brand & Primaries
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryHighlight = Color(0xFF3B82F6);

  // Status & Gamut
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Overlays
  static const Color scrim = Color(0x731C1917); // rgba(28, 25, 23, 0.45)
  static const Color imagePlaceholder = Color(0xFFEBE4D5);
}
