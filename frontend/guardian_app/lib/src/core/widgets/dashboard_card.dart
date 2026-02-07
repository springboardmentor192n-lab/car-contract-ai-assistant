// lib/src/core/widgets/dashboard_card.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path
import 'package:guardian_app/src/core/theme/app_text_styles.dart'; // Corrected import path

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isPrimary; // To make a card visually prominent

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  _DashboardCardState createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Determine card background and border based on primary status and hover
    Color cardColor = widget.isPrimary ? AppColors.primary.withOpacity(0.15) : AppColors.cardBackground;
    Color borderColor = widget.isPrimary
        ? AppColors.primary
        : _isHovering
            ? AppColors.primary.withOpacity(0.5)
            : AppColors.borderColor;
    double elevation = _isHovering ? 8.0 : 2.0;
    double scale = _isHovering ? 1.02 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // Cursor change on hover
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale( // Subtle animation for scale on hover
          scale: scale,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer( // Smooth animation for color, border, elevation
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: borderColor, width: _isHovering ? 1.5 : 0.5),
              boxShadow: [
                BoxShadow(
                  color: (widget.isPrimary ? AppColors.primary : AppColors.onSurface).withOpacity(elevation * 0.02),
                  blurRadius: elevation * 0.5,
                  spreadRadius: elevation * 0.1,
                ),
              ],
            ),
            child: FocusableActionDetector( // Ensures keyboard focusability and visual feedback
              onShowFocusHighlight: (value) {
                if (value) setState(() => _isHovering = true);
                else setState(() => _isHovering = false);
              },
              onShowHoverHighlight: (value) {
                // Already handled by MouseRegion, but useful for consistency
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: widget.isPrimary ? 48 : 40, // Larger icon for primary action
                      color: widget.isPrimary ? AppColors.primary : AppColors.secondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.title,
                      style: widget.isPrimary
                          ? AppTextStyles.headlineSmall?.copyWith(color: AppColors.primary)
                          : AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.subtleTextColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
