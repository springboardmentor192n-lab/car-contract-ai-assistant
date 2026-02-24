import 'package:flutter/material.dart';

class MobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const MobileBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.show_chart_outlined),
          selectedIcon: Icon(Icons.show_chart),
          label: 'Market',
        ),
        NavigationDestination(
          icon: Icon(Icons.pin_outlined),
          selectedIcon: Icon(Icons.pin),
          label: 'VIN',
        ),
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: 'Analysis',
        ),
      ],
    );
  }
}

class MobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const MobileDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.security, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Autofinance Guardian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            selected: selectedIndex == 0,
            onTap: () {
              onDestinationSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart_outlined),
            title: const Text('Market Rates'),
            selected: selectedIndex == 1,
            onTap: () {
              onDestinationSelected(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('VIN Lookup'),
            selected: selectedIndex == 2,
            onTap: () {
              onDestinationSelected(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Contract Analysis'),
            selected: selectedIndex == 3,
            onTap: () {
              onDestinationSelected(3);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
