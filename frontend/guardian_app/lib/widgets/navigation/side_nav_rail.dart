// lib/widgets/navigation/side_nav_rail.dart
import 'package:flutter/material.dart';

/// A reusable widget for the side navigation rail.
/// It displays navigation destinations and handles selection.
class SideNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNavRail({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.show_chart_outlined),
          selectedIcon: Icon(Icons.show_chart),
          label: Text('Market Rates'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.pin_outlined),
          selectedIcon: Icon(Icons.pin),
          label: Text('VIN Lookup'),
        ),
        NavigationRailDestination( // NEW: Contract Analysis Destination
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: Text('Contract Analysis'),
        ),
      ],
    );
  }
}