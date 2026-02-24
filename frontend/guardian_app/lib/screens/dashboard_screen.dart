import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_stats_provider.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/dashboard/feature_card.dart';
import '../widgets/dashboard/recent_activity_panel.dart';
import '../widgets/responsive/responsive_layout.dart';
import '../core/constants/breakpoints.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: const _MobileDashboard(),
      desktop: const _DesktopDashboard(),
    );
  }
}

class _DesktopDashboard extends ConsumerWidget {
  const _DesktopDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  statsAsync.when(
                    data: (stats) => _buildStatsGrid(context, stats, crossAxisCount: 2),
                    loading: () => _buildStatsLoading(crossAxisCount: 2),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100, // Constrain height
              child: const RecentActivityPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileDashboard extends ConsumerWidget {
  const _MobileDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildStatsGrid(context, stats, crossAxisCount: 1),
            loading: () => _buildStatsLoading(crossAxisCount: 1),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            height: 400,
            child: RecentActivityPanel(),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatsGrid(BuildContext context, dynamic stats, {required int crossAxisCount}) {
  return GridView.count(
    crossAxisCount: crossAxisCount,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.5,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    children: [
      FeatureCard(
        title: 'Contracts Analyzed',
        value: stats.totalContractsAnalyzed.toString(),
        icon: Icons.assignment_turned_in_outlined,
      ),
      FeatureCard(
        title: 'High-Risk Contracts',
        value: stats.highRiskContractsCount.toString(),
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.redAccent,
        onTap: () => context.go('/contract_analysis?filter=high_risk'),
      ),
      FeatureCard(
        title: 'Avg. Savings',
        value: '\$${stats.averageSavingsIdentified.toStringAsFixed(0)}',
        icon: Icons.savings_outlined,
        iconColor: Colors.green,
      ),
      FeatureCard(
        title: 'VIN Lookups',
        value: stats.recentVinLookups.toString(),
        icon: Icons.pin_outlined,
        onTap: () => context.go('/vin-lookup'),
      ),
      FeatureCard(
        title: 'Analyze New',
        value: 'Upload',
        icon: Icons.upload_file,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/contract_analysis'),
      ),
    ],
  );
}

Widget _buildStatsLoading({required int crossAxisCount}) {
  return GridView.count(
    crossAxisCount: crossAxisCount,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.5,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    children: List.generate(4, (index) => const _StatCardSkeleton()),
  );
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
            SkeletonLoader(width: 100, height: 20),
            SkeletonLoader(width: 60, height: 32),
          ],
        ),
      ),
    );
  }
}
