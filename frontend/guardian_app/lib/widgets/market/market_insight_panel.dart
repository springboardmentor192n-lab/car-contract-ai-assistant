// lib/widgets/market/market_insight_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/emi_calculator_provider.dart';

/// A panel that provides a simple text-based insight and recommendation
/// based on the user's EMI calculation compared to the market.
class MarketInsightPanel extends ConsumerWidget {
  const MarketInsightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emiResult = ref.watch(emiCalculatorProvider);

    if (emiResult.emi <= 0) {
      return const SizedBox.shrink(); // Don't show if no calculation is done
    }

    String insightTitle;
    String insightText;
    Color titleColor;

    if (emiResult.comparisonMessage.contains('Better')) {
      insightTitle = 'This is a Good Rate!';
      titleColor = Colors.green;
      insightText = 'Your interest rate is better than the current market average. This looks like a competitive loan offer.';
    } else if (emiResult.comparisonMessage.contains('Higher')) {
      insightTitle = 'This Loan is Expensive';
      titleColor = Colors.redAccent;
      final suggestedRate = (emiResult.marketAverageRate - 0.5).toStringAsFixed(2);
      insightText =
          'Your interest rate is significantly higher than the market average. You should consider negotiating for a better rate, potentially around $suggestedRate% or lower, or exploring other lenders.';
    } else {
      insightTitle = 'Rate is Average';
      titleColor = Colors.orangeAccent;
      insightText =
          'Your interest rate is on par with the market average. It is a fair deal, but not exceptional. You might still find better offers with a little more research.';
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Insight',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Text(
              insightTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              insightText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
