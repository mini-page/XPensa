import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Centralised [ThemeData] factory for XPensa.
///
/// Use [AppTheme.light] and [AppTheme.dark] instead of building
/// [ThemeData] inline in `main.dart`. This enables global UI updates
/// from a single file and simplifies dark / light theme toggling.
class AppTheme {
  AppTheme._();

  /// Light theme.
  static ThemeData light() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF3F7FC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.danger,
        surface: Colors.white,
      ),
      useMaterial3: true,
      textTheme: _textTheme(AppColors.textDark),
    );
  }

  /// Dark theme.
  static ThemeData dark() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF0E1626),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlueLight,
        brightness: Brightness.dark,
        primary: AppColors.primaryBlueLight,
        secondary: const Color(0xFFFF6C89),
        surface: const Color(0xFF182234),
      ),
      useMaterial3: true,
      textTheme: _textTheme(Colors.white),
    );
  }

  static TextTheme _textTheme(Color defaultColor) {
    return TextTheme(
      headlineLarge: AppTextStyles.sectionHeading.copyWith(color: defaultColor),
      headlineMedium:
          AppTextStyles.sectionHeading.copyWith(color: defaultColor, fontSize: 18),
      titleMedium: AppTextStyles.bodyStrong.copyWith(color: defaultColor),
      bodyMedium: AppTextStyles.bodyMuted,
      labelSmall: AppTextStyles.eyebrowOnDark,
    );
  }
}
