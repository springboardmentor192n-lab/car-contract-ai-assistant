// lib/src/core/widgets/section_card.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path
import 'package:guardian_app/src/core/theme/app_text_styles.dart'; // Corrected import path

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing; // Optional widget for actions or extra info
  final EdgeInsetsGeometry padding;

  const SectionCard({
    Key? key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(20.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Use padding around this widget instead
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge,
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const Divider(height: 30, color: AppColors.borderColor),
            child,
          ],
        ),
      ),
    );
  }
}
