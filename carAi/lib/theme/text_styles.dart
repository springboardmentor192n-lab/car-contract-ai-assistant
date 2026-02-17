import 'package:flutter/material.dart';

import 'colors.dart';

class AppTextStyles {
  static TextStyle get xs => const TextStyle(
    fontSize: 12,
    color: AppColors.mutedForeground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get sm => const TextStyle(
    fontSize: 14,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get base => const TextStyle(
    fontSize: 16,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get lg => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get xl => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get xxl => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
  
  static TextStyle get xxxl => const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
    fontFamily: 'Inter',
  );
}
