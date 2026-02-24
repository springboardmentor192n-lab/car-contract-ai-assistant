import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'responsive_layout.dart';
import '../navigation/sidebar.dart';
import '../navigation/mobile_nav.dart';
import '../../providers/app_state_provider.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: _MobileLayout(
        body: body,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      tablet: _DesktopLayout(
        body: body,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        isTablet: true,
      ),
      desktop: _DesktopLayout(
        body: body,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}

class _DesktopLayout extends ConsumerWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isTablet;

  const _DesktopLayout({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            isTablet: isTablet,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                // Top bar can go here if needed
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const _MobileLayout({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofinance Guardian'),
      ),
      drawer: MobileDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      body: body,
      bottomNavigationBar: MobileBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
