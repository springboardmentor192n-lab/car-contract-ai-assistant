// lib/src/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path

class AppTextStyles {
  static const String fontFamily = 'Inter'; // Example, use a custom font or default

  static TextStyle displayLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle displayMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle displaySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle headlineLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static TextStyle headlineMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static TextStyle headlineSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static TextStyle titleLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static TextStyle titleMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
  static TextStyle titleSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
  static TextStyle labelMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
}
