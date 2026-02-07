// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_stats_provider.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/dashboard/feature_card.dart';
import '../widgets/dashboard/recent_activity_panel.dart';

/// The main dashboard screen of the application.
/// It displays key statistics and a real-time recent activity panel.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Row(
      children: [
        // Main content area for feature cards
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Autofinance Guardian',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 24),
                statsAsync.when(
                  data: (stats) => Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        FeatureCard(
                          title: 'Total Contracts Analyzed',
                          value: stats.totalContractsAnalyzed.toString(),
                          icon: Icons.assignment_turned_in_outlined,
                        ),
                        FeatureCard(
                          title: 'High-Risk Contracts',
                          value: stats.highRiskContractsCount.toString(), // Updated to new stat
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.redAccent,
                          onTap: () => context.go('/contract_analysis?filter=high_risk'), // Clickable
                        ),
                        FeatureCard(
                          title: 'Avg. Savings Identified',
                          value: '\$${stats.averageSavingsIdentified.toStringAsFixed(2)}',
                          icon: Icons.savings_outlined,
                          iconColor: Colors.green,
                        ),
                        FeatureCard(
                          title: 'Recent VIN Lookups',
                          value: stats.recentVinLookups.toString(),
                          icon: Icons.pin_outlined,
                          onTap: () => context.go('/vin-lookup'),
                        ),
                         FeatureCard( // NEW: Contract Analyzer Card
                          title: 'Contract Analyzer',
                          value: 'Upload New',
                          icon: Icons.description, // Changed to a more common icon
                          iconColor: Theme.of(context).colorScheme.secondary,
                          onTap: () => context.go('/contract_analysis'),
                        ),
                      ],
                    ),
                  ),
                  loading: () => _buildStatsLoading(),
                  error: (err, stack) => Text('Error loading stats: $err'),
                ),
              ],
            ),
          ),
        ),
        // Right sidebar for Recent Activity
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: const RecentActivityPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(5, (index) => const _StatCardSkeleton()), // Updated count
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SkeletonLoader(width: 36, height: 36),
            const SizedBox(height: 16),
            SkeletonLoader(width: 150, height: 20),
            SkeletonLoader(width: 80, height: 36),
          ],
        ),
      ),
    );
  }
}
