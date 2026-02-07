// lib/src/features/dashboard/presentation/components/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart';
import 'package:guardian_app/src/core/theme/app_text_styles.dart';

// --- NEW COMPONENT: DashboardHeader ---
class DashboardHeader extends StatelessWidget {
  final VoidCallback onQuickStart;

  const DashboardHeader({Key? key, required this.onQuickStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity( // Subtle fade-in for welcome message
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, User!', // Personalize with actual user name
            style: AppTextStyles.displaySmall?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            'Your comprehensive AI-powered toolkit for optimizing auto finance decisions.',
            style: AppTextStyles.bodyLarge?.copyWith(color: AppColors.subtleTextColor),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onQuickStart,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text('Quick Start: Analyze New Contract', style: AppTextStyles.labelLarge),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              textStyle: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
