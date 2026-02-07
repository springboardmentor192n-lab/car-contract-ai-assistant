// lib/src/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6200EE); // A deep purple for primary actions
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF03DAC6); // A teal accent
  static const Color onSecondary = Colors.black;
  static const Color surface = Color(0xFF121212); // Dark background for most elements
  static const Color background = Color(0xFF0A0A0A); // Even darker background for overall app
  static const Color onSurface = Color(0xFFE0E0E0); // Light text on dark surfaces
  static const Color onError = Colors.white;
  static const Color error = Color(0xFFCF6679); // A soft red for errors
  static const Color success = Color(0xFF66BB6A); // Green for success
  static const Color warning = Color(0xFFFFC107); // Amber for warnings

  // Specific UI element colors
  static const Color sidebarBackground = Color(0xFF1F1F1F);
  static const Color cardBackground = Color(0xFF282828);
  static const Color borderColor = Color(0xFF333333);
  static const Color subtleTextColor = Color(0xFFAAAAAA);
}
