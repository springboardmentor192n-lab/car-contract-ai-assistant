// lib/src/core/layouts/main_saas_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart'; // Corrected import path
import 'package:guardian_app/src/core/theme/app_text_styles.dart'; // Corrected import path

// This layout defines the overall structure of most SaaS screens:
// A fixed left sidebar and an expandable main content area.
class MainSaaSLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget mainContent;
  final String title;

  const MainSaaSLayout({
    Key? key,
    required this.leftPanel,
    required this.mainContent,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.headlineSmall),
        // You can add global actions or user info here
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              // context.go('/settings'); // Example navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              // context.go('/profile'); // Example navigation
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Panel (Fixed Width)
          Material(
            color: AppColors.sidebarBackground,
            elevation: 4,
            child: SizedBox(
              width: 300, // Fixed width for the left panel
              child: leftPanel,
            ),
          ),
          // Main Content Area (Takes remaining space)
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }
}
