// lib/widgets/contract_analysis/contract_input_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/contract_analysis_provider.dart';

/// A form widget for users to input various contract details for analysis.
class ContractInputForm extends ConsumerStatefulWidget {
  const ContractInputForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ContractInputForm> createState() => _ContractInputFormState();
}

class _ContractInputFormState extends ConsumerState<ContractInputForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanAmountController = TextEditingController(text: '100000');
  final TextEditingController _interestRateController = TextEditingController(text: '9.5');
  final TextEditingController _tenureController = TextEditingController(text: '60');
  final TextEditingController _processingFeesController = TextEditingController(text: '1000');
  final TextEditingController _penaltyClausesController = TextEditingController(text: '2% prepayment penalty, 5% late fee');

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    _processingFeesController.dispose();
    _penaltyClausesController.dispose();
    super.dispose();
  }

  void _analyzeContract() {
    if (_formKey.currentState!.validate()) {
      final loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
      final interestRate = double.tryParse(_interestRateController.text) ?? 0.0;
      final tenureMonths = int.tryParse(_tenureController.text) ?? 0;
      final processingFees = double.tryParse(_processingFeesController.text) ?? 0.0;
      final penaltyClauses = _penaltyClausesController.text;

      ref.read(contractAnalysisProvider.notifier).analyzeContract(
            loanAmount: loanAmount,
            interestRate: interestRate,
            tenureMonths: tenureMonths,
            processingFees: processingFees,
            penaltyClauses: penaltyClauses,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _loanAmountController,
            labelText: 'Loan Amount (\$)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter loan amount';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _interestRateController,
            labelText: 'Annual Interest Rate (%)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter interest rate';
              }
              if (double.tryParse(value) == null || double.parse(value) < 0) {
                return 'Please enter a valid non-negative number';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _tenureController,
            labelText: 'Tenure (Months)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter tenure';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid positive integer';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _processingFeesController,
            labelText: 'Processing Fees (\$)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter processing fees';
              }
              if (double.tryParse(value) == null || double.parse(value) < 0) {
                return 'Please enter a valid non-negative number';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _penaltyClausesController,
            labelText: 'Penalty Clauses (e.g., late fees, prepayment penalty)',
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _analyzeContract,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyze Contract'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true, // Make the field slightly more compact
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
