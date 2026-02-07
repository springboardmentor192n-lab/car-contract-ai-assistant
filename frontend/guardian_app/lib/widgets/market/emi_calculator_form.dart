// lib/widgets/market/emi_calculator_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/emi_calculator_provider.dart';

/// A form widget to calculate EMI and display related financial metrics,
/// including a visual comparison to the market average rate.
class EmiCalculatorForm extends ConsumerStatefulWidget {
  const EmiCalculatorForm({Key? key}) : super(key: key);

  @override
  ConsumerState<EmiCalculatorForm> createState() => _EmiCalculatorFormState();
}

class _EmiCalculatorFormState extends ConsumerState<EmiCalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanAmountController = TextEditingController(text: '100000');
  final TextEditingController _interestRateController = TextEditingController(text: '9.5');
  final TextEditingController _tenureController = TextEditingController(text: '60');

  @override
  void initState() {
    super.initState();
    // Trigger initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateEmi();
    });
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEmi() {
    if (_formKey.currentState!.validate()) {
      final loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
      final interestRate = double.tryParse(_interestRateController.text) ?? 0.0;
      final tenureMonths = int.tryParse(_tenureController.text) ?? 0;

      ref.read(emiCalculatorProvider.notifier).calculateEmi(
            loanAmount: loanAmount,
            annualInterestRate: interestRate,
            tenureMonths: tenureMonths,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emiResult = ref.watch(emiCalculatorProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EMI Calculator',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _loanAmountController,
                    labelText: 'Loan Amount (\$)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _interestRateController,
                    labelText: 'Annual Interest Rate (%)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _tenureController,
                    labelText: 'Tenure (Months)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _calculateEmi,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate EMI'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            if (emiResult.emi > 0) ...[
              Text(
                'Calculation Results',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildResultRow(context, 'Monthly EMI:', '\$${emiResult.emi.toStringAsFixed(2)}'),
              _buildResultRow(context, 'Total Interest:', '\$${emiResult.totalInterest.toStringAsFixed(2)}'),
              _buildResultRow(context, 'Total Payable:', '\$${emiResult.totalPayable.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              _buildMarketComparison(context, emiResult),
            ] else
              Center(
                child: Text(
                  'Enter details to calculate EMI.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter a value.';
          if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a positive number.';
          return null;
        },
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMarketComparison(BuildContext context, EmiCalculationResult result) {
    Color comparisonColor;
    IconData comparisonIcon;

    if (result.comparisonMessage.contains('Better')) {
      comparisonColor = Colors.green;
      comparisonIcon = Icons.trending_down;
    } else if (result.comparisonMessage.contains('Higher')) {
      comparisonColor = Colors.redAccent;
      comparisonIcon = Icons.trending_up;
    } else {
      comparisonColor = Colors.orangeAccent;
      comparisonIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: comparisonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(comparisonIcon, color: comparisonColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rate vs Market Average (${result.marketAverageRate.toStringAsFixed(2)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  result.comparisonMessage,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: comparisonColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}