// lib/src/core/widgets/hover_card.dart
import 'package:flutter/material.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? normalColor;
  final Duration animationDuration;

  const HoverCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
    this.hoverColor,
    this.normalColor,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final defaultNormalColor = Theme.of(context).cardColor;
    final defaultHoverColor = defaultNormalColor.withOpacity(0.8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          decoration: BoxDecoration(
            color: _isHovering
                ? (widget.hoverColor ?? defaultHoverColor)
                : (widget.normalColor ?? defaultNormalColor),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
            border: Border.all(
              color: _isHovering ? AppColors.primary : AppColors.borderColor,
              width: _isHovering ? 1.5 : 0.5,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
