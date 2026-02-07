// lib/widgets/market/market_line_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/market_data.dart';

/// Displays a line chart of market data using fl_chart.
/// Includes tooltips, grid lines, and responsive labels.
class MarketLineChart extends StatelessWidget {
  final List<MarketDataPoint> data;
  final String title;

  const MarketLineChart({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No market data available.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    // Determine min/max x and y values for the chart
    final double minX = data.first.date.millisecondsSinceEpoch.toDouble();
    final double maxX = data.last.date.millisecondsSinceEpoch.toDouble();
    final double minY = data.map((point) => point.value).reduce((a, b) => a < b ? a : b);
    final double maxY = data.map((point) => point.value).reduce((a, b) => a > b ? a : b);

    List<FlSpot> spots = data
        .map((point) => FlSpot(point.date.millisecondsSinceEpoch.toDouble(), point.value))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 6),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: (maxY - minY) / 5 > 1 ? (maxY - minY) / 5 : 1, // Dynamic interval
                  verticalInterval: (maxX - minX) / 5 > 1 ? (maxX - minX) / 5 : 1, // Dynamic interval
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        // Format based on the density of data points
                        String format;
                        if (data.length > 30) {
                          format = 'MMM dd'; // For denser data
                        } else {
                          format = 'MMM dd HH:mm'; // For less dense data
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat(format).format(dateTime),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY - minY) / 5 > 1 ? (maxY - minY) / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
                minX: minX,
                maxX: maxX,
                minY: minY - (maxY - minY) * 0.1, // Add some padding below min Y
                maxY: maxY + (maxY - minY) * 0.1, // Add some padding above max Y
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(

                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final flSpot = touchedSpot;
                        final dateTime = DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt());
                        return LineTooltipItem(
                          '${DateFormat('MMM dd, HH:mm').format(dateTime)}\n',
                          TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: flSpot.y.toStringAsFixed(2),
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}