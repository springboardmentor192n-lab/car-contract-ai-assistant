// lib/src/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for Riverpod usage
import 'package:guardian_app/src/core/layouts/main_saas_layout.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart';
import 'package:guardian_app/src/core/theme/app_text_styles.dart';
import 'package:guardian_app/src/core/widgets/dashboard_card.dart';
import 'package:guardian_app/src/core/widgets/section_card.dart'; // Added SectionCard
import 'package:guardian_app/src/core/widgets/status_chip.dart'; // Added StatusChip
import 'package:guardian_app/src/features/dashboard/presentation/components/dashboard_header.dart'; // NEW
import 'package:guardian_app/src/features/dashboard/presentation/components/recent_activity_feed.dart'; // NEW

// Dummy provider for recent activity (replace with actual data provider)
final recentActivityProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Simulate live updates
  return Stream.periodic(const Duration(seconds: 5), (count) {
    return [
      {
        'type': 'contract',
        'title': 'Lease Agreement Q4 2025',
        'status': count % 3 == 0 ? 'Analyzing...' : 'Completed',
        'route': '/contract-analysis',
        'timestamp': DateTime.now().subtract(Duration(minutes: count * 5)),
      },
      {
        'type': 'vin',
        'title': 'VIN Lookup: ABCDE12345FGHIJ',
        'status': 'Completed',
        'route': '/vin-lookup',
        'timestamp': DateTime.now().subtract(Duration(hours: 1)),
      },
      {
        'type': 'market',
        'title': 'Market Rates Report',
        'status': 'Pending',
        'route': '/market-rates',
        'timestamp': DateTime.now().subtract(Duration(hours: 3)),
      },
    ];
  });
});


class DashboardScreen extends ConsumerWidget { // Changed to ConsumerWidget for Riverpod
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    // final recentActivityAsync = ref.watch(recentActivityProvider); // Moved into RecentActivityFeed

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.headlineSmall), // Simpler title
        actions: [
          Tooltip(
            message: 'Access your profile settings',
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () { /* context.go('/profile'); */ },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dashboard Header (Welcome & Quick Start) ---
            DashboardHeader(
              onQuickStart: () => context.go('/contract-analysis'),
            ),
            const SizedBox(height: 48),

            // --- Main Content Area: Feature Cards + Recent Activity ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2, // Take more space for feature cards
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Features',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double cardWidth = 350;
                          final int crossAxisCount = (constraints.maxWidth / cardWidth).floor();
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                              crossAxisSpacing: 24.0,
                              mainAxisSpacing: 24.0,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return DashboardCard(
                                    icon: Icons.description_outlined,
                                    title: 'Analyze Contract',
                                    description: 'Upload and get AI-driven insights on lease and loan agreements.',
                                    onTap: () => context.go('/contract-analysis'),
                                    isPrimary: true,
                                  );
                                case 1:
                                  return DashboardCard(
                                    icon: Icons.directions_car_outlined,
                                    title: 'Check Vehicle Value',
                                    description: 'Determine fair market value and historical price trends for any vehicle.',
                                    onTap: () => context.go('/vin-lookup'),
                                  );
                                case 2:
                                  return DashboardCard(
                                    icon: Icons.forum_outlined,
                                    title: 'Negotiation Helper',
                                    description: 'Receive data-backed recommendations to strengthen your negotiation position.',
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Negotiation Helper Coming Soon!')),
                                      );
                                    },
                                  );
                                case 3:
                                  return DashboardCard(
                                    icon: Icons.show_chart_outlined,
                                    title: 'Market Rates',
                                    description: 'Explore current and historical market rates for loans, leases, and vehicles.',
                                    onTap: () => context.go('/market-rates'),
                                  );
                                default:
                                  return const SizedBox.shrink();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32), // Spacing between feature cards and activity feed
                Expanded(
                  flex: 1, // Smaller column for activity feed
                  child: RecentActivityFeed(), // NEW
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}