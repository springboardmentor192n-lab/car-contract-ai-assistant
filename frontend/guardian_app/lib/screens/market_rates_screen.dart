import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/market_data_provider.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/market/market_line_chart.dart';
import '../widgets/market/emi_calculator_form.dart';
import '../widgets/market/market_insight_panel.dart';
import '../widgets/responsive/responsive_layout.dart';

class MarketRatesScreen extends ConsumerWidget {
  const MarketRatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: const _MobileMarketLayout(),
      desktop: const _DesktopMarketLayout(),
    );
  }
}

class _DesktopMarketLayout extends ConsumerWidget {
  const _DesktopMarketLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(marketDataProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Trends',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: marketDataAsync.when(
                        data: (data) => MarketLineChart(
                          title: 'Interest Rate Benchmark (30 Days)',
                          data: data,
                        ),
                        loading: () => const _ChartSkeleton(),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  EmiCalculatorForm(),
                  SizedBox(height: 24),
                  MarketInsightPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMarketLayout extends ConsumerWidget {
  const _MobileMarketLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(marketDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Trends',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: marketDataAsync.when(
                  data: (data) => MarketLineChart(
                    title: 'Interest Rates (30 Days)',
                    data: data,
                  ),
                  loading: () => const _ChartSkeleton(),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const EmiCalculatorForm(),
          const SizedBox(height: 24),
          const MarketInsightPanel(),
        ],
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 150, height: 24),
        const SizedBox(height: 16),
        Expanded(
          child: SkeletonLoader(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
