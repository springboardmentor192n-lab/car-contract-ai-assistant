// lib/src/core/widgets/status_chip.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path
import 'package:guardian_app/src/core/theme/app_text_styles.dart'; // Corrected import path

enum StatusType { info, success, warning, error, primary }

class StatusChip extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;

  const StatusChip({
    Key? key,
    required this.text,
    this.type = StatusType.info,
    this.icon,
  }) : super(key: key);

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case StatusType.info:
        return AppColors.primary.withOpacity(0.1);
      case StatusType.success:
        return AppColors.success.withOpacity(0.1);
      case StatusType.warning:
        return AppColors.warning.withOpacity(0.1);
      case StatusType.error:
        return AppColors.error.withOpacity(0.1);
      case StatusType.primary:
        return AppColors.primary.withOpacity(0.2);
    }
  }

  Color _getForegroundColor(BuildContext context) {
    switch (type) {
      case StatusType.info:
      case StatusType.primary:
        return AppColors.primary;
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = _getForegroundColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foregroundColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall?.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
