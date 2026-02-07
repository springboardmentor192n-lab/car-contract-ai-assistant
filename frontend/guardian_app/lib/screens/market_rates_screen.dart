// lib/screens/market_rates_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/market_data_provider.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/market/market_line_chart.dart';
import '../widgets/market/emi_calculator_form.dart';
import '../widgets/market/market_insight_panel.dart'; // Add this import

/// The market rates screen of the application.
/// Displays interactive charts for various market data using fl_chart.
class MarketRatesScreen extends ConsumerWidget {
  const MarketRatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(marketDataProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Trends & Rates',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: marketDataAsync.when(
                        data: (data) {
                          return MarketLineChart(
                            title: 'Interest Rate Benchmark (Last 30 Days)',
                            data: data,
                          );
                        },
                        loading: () => _buildLoadingState(),
                        error: (error, stack) => _buildErrorState(context, error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column( // Wrap in a column
              children: const [
                EmiCalculatorForm(),
                SizedBox(height: 24),
                MarketInsightPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: 250, height: 24, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 16),
        Expanded(
          child: SkeletonLoader(width: double.infinity, height: double.infinity, borderRadius: BorderRadius.circular(8)),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load market data.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // This will re-run the future provider
              // For a more explicit refresh, you might use ref.invalidate(marketDataProvider)
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
