import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/market/application/market_rates_service.dart';

class MarketRatesScreen extends ConsumerWidget {
  const MarketRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketRatesState = ref.watch(marketRatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Rates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: marketRatesState.when(
          data: (rates) {
            if (rates == null) {
              return const Center(child: Text('No data available.'));
            }
            return Column(
              children: [
                Text(
                  'Latest APR: ${rates.latestApr}%',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Change from previous: ${rates.changeFromPrevious}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(
                        enabled: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= rates.historicalData.length) {
                                return const SizedBox.shrink();
                              }
                              final date = rates.historicalData[index].date;
                              return SideTitleWidget(
                                space: 4,
                                axisSide: meta.axisSide,
                                child: Text(date, style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: rates.historicalData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(x: index, barRods: [
                          BarChartRodData(toY: data.interestRate, width: 22, color: Colors.blue)
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}