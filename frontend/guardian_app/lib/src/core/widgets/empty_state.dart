// lib/src/core/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path
import 'package:guardian_app/src/core/theme/app_text_styles.dart'; // Corrected import path

class EmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData? icon;
  final Widget? actionButton;

  const EmptyState({
    Key? key,
    required this.message,
    this.subMessage,
    this.icon,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: AppColors.subtleTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            message,
            style: AppTextStyles.headlineSmall?.copyWith(color: AppColors.subtleTextColor),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              subMessage!,
              style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.subtleTextColor),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionButton != null) ...[
            const SizedBox(height: 24),
            actionButton!,
          ],
        ],
      ),
    );
  }
}
