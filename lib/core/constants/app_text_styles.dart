import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralised text styles used throughout the app.
///
/// Colors for regular text (primary/secondary/hint) are intentionally left
/// null so Flutter's theme engine supplies the correct value in both light
/// and dark mode automatically. Only semantic/brand colors (amounts, etc.)
/// are hardcoded here.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    // color: inherited from theme
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    // color: inherited; use .copyWith(color: ...) at call-site if needed
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ── Semantic / brand colors kept explicit ──────────────────────────────────

  static const TextStyle amountLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle amountPositive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );

  static const TextStyle amountNegative = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
}
