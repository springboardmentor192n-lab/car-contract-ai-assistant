import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF3B82F6);  // Blue
  static const primaryDark = Color(0xFF2563EB);
  static const accent = Color(0xFF10B981);  // Green
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  
  // Backgrounds
  static const background = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF9FAFB);
  static const blue50 = Color(0xFFEFF6FF);
  static const green50 = Color(0xFFF0FDF4);
  static const amber50 = Color(0xFFFFFBEB);
  static const red50 = Color(0xFFFEF2F2);
  static const purple50 = Color(0xFFFAF5FF);
  
  // Text
  static const foreground = Color(0xFF111827);
  static const mutedForeground = Color(0xFF6B7280);
  
  // Borders
  static const border = Color(0xFFE5E7EB);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
