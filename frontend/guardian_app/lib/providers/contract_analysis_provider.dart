// lib/providers/contract_analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// Represents the output of a contract analysis.
class ContractAnalysisResult {
  final double loanAmount;
  final double interestRate; // Annual percentage
  final int tenureMonths;
  final double processingFees;
  final String penaltyClauses;
  final String riskLevel;
  final List<String> unfairTerms;
  final double estimatedTotalPayable;
  final String clearExplanation;

  ContractAnalysisResult({
    required this.loanAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.processingFees,
    required this.penaltyClauses,
    required this.riskLevel,
    required this.unfairTerms,
    required this.estimatedTotalPayable,
    required this.clearExplanation,
  });

  // Factory constructor for loading from JSON or default values if needed
  factory ContractAnalysisResult.empty() {
    return ContractAnalysisResult(
      loanAmount: 0.0,
      interestRate: 0.0,
      tenureMonths: 0,
      processingFees: 0.0,
      penaltyClauses: '',
      riskLevel: 'N/A',
      unfairTerms: [],
      estimatedTotalPayable: 0.0,
      clearExplanation: 'Please enter contract details to get an analysis.',
    );
  }
}

/// A Riverpod StateNotifier for performing contract analysis.
class ContractAnalysisNotifier extends StateNotifier<ContractAnalysisResult> {
  ContractAnalysisNotifier() : super(ContractAnalysisResult.empty());

  void analyzeContract({
    required double loanAmount,
    required double interestRate, // Annual percentage
    required int tenureMonths,
    required double processingFees,
    required String penaltyClauses,
  }) {
    if (loanAmount <= 0 || interestRate < 0 || tenureMonths <= 0) {
      state = ContractAnalysisResult(
        loanAmount: loanAmount,
        interestRate: interestRate,
        tenureMonths: tenureMonths,
        processingFees: processingFees,
        penaltyClauses: penaltyClauses,
        riskLevel: 'N/A',
        unfairTerms: [],
        estimatedTotalPayable: 0.0,
        clearExplanation: 'Please enter valid positive values for Loan Amount, Interest Rate, and Tenure.',
      );
      return;
    }

    // Convert annual interest rate to monthly rate
    final double monthlyInterestRate = (interestRate / 100) / 12;

    // Calculate EMI using the formula: P * r * (1 + r)^n / ((1 + r)^n - 1)
    // where P = Principal, r = monthly interest rate, n = tenure in months
    double emi;
    if (monthlyInterestRate > 0) {
      emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, tenureMonths)) /
          (pow(1 + monthlyInterestRate, tenureMonths) - 1);
    } else {
      emi = loanAmount / tenureMonths; // If interest rate is 0
    }

    final double totalInterest = (emi * tenureMonths) - loanAmount;
    final double estimatedTotalPayable = loanAmount + totalInterest + processingFees;

    String riskLevel = 'Low';
    List<String> unfairTerms = [];
    String explanation = 'Based on the provided details:';

    if (interestRate > 15.0) { // Example threshold for high interest
      riskLevel = 'High';
      unfairTerms.add('High interest rate (${interestRate.toStringAsFixed(2)}%) compared to market averages.');
      explanation += """
- The interest rate seems quite high, which will significantly increase your total payable amount.""";
    } else if (interestRate > 10.0) {
      riskLevel = 'Medium';
      explanation += """
- The interest rate is moderate; ensure you are comfortable with the total cost.""";
    } else {
      explanation += """
- The interest rate is competitive, indicating a potentially good deal.""";
    }

    if (processingFees > (loanAmount * 0.02)) { // Example: >2% of loan amount
      riskLevel = 'High';
      unfairTerms.add('Excessive processing fees (${processingFees.toStringAsFixed(2)}).');
      explanation += """
- The processing fees are unusually high. Always clarify what these fees cover.""";
    } else if (processingFees > (loanAmount * 0.01)) {
      riskLevel = 'Medium';
      explanation += """
- Processing fees are standard. Make sure there are no hidden charges.""";
    }

    if (penaltyClauses.isNotEmpty) {
      // Simple heuristic for now, a real system would parse these
      if (penaltyClauses.toLowerCase().contains('high prepayment penalty') ||
          penaltyClauses.toLowerCase().contains('unreasonable late fee')) {
        riskLevel = 'High';
        unfairTerms.add('Potentially harsh penalty clauses. Review carefully.');
        explanation += """
- The penalty clauses seem strict. Understand the implications of late payments or early repayments.""";
      } else if (penaltyClauses.toLowerCase().contains('prepayment penalty')) {
        riskLevel = riskLevel == 'Low' ? 'Medium' : riskLevel; // Elevate if not already high
        unfairTerms.add('Prepayment penalty might apply. Check terms.');
        explanation += """
- Be aware of prepayment penalties if you plan to close the loan early.""";
      }
    }

    explanation += """

**EMI (Equated Monthly Installment):** \$${emi.toStringAsFixed(2)}""";
    explanation += """
**Total Interest Payable:** \$${totalInterest.toStringAsFixed(2)}""";
    explanation += """
**Estimated Total Payable (Loan + Interest + Fees):** \$${estimatedTotalPayable.toStringAsFixed(2)}""";

    if (unfairTerms.isEmpty && riskLevel == 'Low') {
      explanation += """

Overall, the contract appears to have fair terms.""";
    } else {
      explanation += """

Consider reviewing the highlighted terms carefully or seeking expert advice.""";
    }


    state = ContractAnalysisResult(
      loanAmount: loanAmount,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      processingFees: processingFees,
      penaltyClauses: penaltyClauses,
      riskLevel: riskLevel,
      unfairTerms: unfairTerms,
      estimatedTotalPayable: estimatedTotalPayable,
      clearExplanation: explanation,
    );
  }
}

final contractAnalysisProvider = StateNotifierProvider<ContractAnalysisNotifier, ContractAnalysisResult>((ref) {
  return ContractAnalysisNotifier();
});
