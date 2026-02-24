import 'package:flutter/material.dart';
import '../../core/constants/breakpoints.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= AppBreakpoints.tablet) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        // Calculate item width
        final double itemWidth = (constraints.maxWidth -
                (crossAxisCount - 1) * spacing) /
            crossAxisCount;

        // Use Wrap for simple flow, or GridView for stricter grid
        // Here, we'll implement a custom row-based layout for better control
        // or just use a GridView if items have same height.
        // Let's use GridView for now as it's standard for dashboards.

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.3, // Adjust based on card content
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
