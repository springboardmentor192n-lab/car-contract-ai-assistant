// lib/providers/emi_calculator_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// Represents the result of an EMI calculation.
class EmiCalculationResult {
  final double loanAmount;
  final double annualInterestRate;
  final int tenureMonths;
  final double emi;
  final double totalInterest;
  final double totalPayable;
  final double marketAverageRate;
  final String comparisonMessage;

  EmiCalculationResult({
    required this.loanAmount,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.emi,
    required this.totalInterest,
    required this.totalPayable,
    required this.marketAverageRate,
    required this.comparisonMessage,
  });

  factory EmiCalculationResult.empty() {
    return EmiCalculationResult(
      loanAmount: 0.0,
      annualInterestRate: 0.0,
      tenureMonths: 0,
      emi: 0.0,
      totalInterest: 0.0,
      totalPayable: 0.0,
      marketAverageRate: 0.0,
      comparisonMessage: '',
    );
  }
}

/// A Riverpod StateNotifier for performing EMI calculations and comparisons.
class EmiCalculatorNotifier extends StateNotifier<EmiCalculationResult> {
  EmiCalculatorNotifier() : super(EmiCalculationResult.empty());

  void calculateEmi({
    required double loanAmount,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    if (loanAmount <= 0 || annualInterestRate < 0 || tenureMonths <= 0) {
      state = EmiCalculationResult.empty();
      return;
    }

    // Convert annual interest rate to monthly rate
    final double monthlyInterestRate = (annualInterestRate / 100) / 12;

    double emi;
    if (monthlyInterestRate > 0) {
      emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, tenureMonths)) /
          (pow(1 + monthlyInterestRate, tenureMonths) - 1);
    } else {
      emi = loanAmount / tenureMonths; // If interest rate is 0
    }

    final double totalInterest = (emi * tenureMonths) - loanAmount;
    final double totalPayable = loanAmount + totalInterest;

    // Mock market average rate for comparison
    final double marketAverageRate = 8.5 + (Random().nextDouble() * 2 - 1); // Random +/- 1% around 8.5%
    String comparisonMessage;
    if (annualInterestRate < marketAverageRate - 0.5) {
      comparisonMessage = 'Better than market average!';
    } else if (annualInterestRate > marketAverageRate + 0.5) {
      comparisonMessage = 'Higher than market average. Consider negotiating or exploring other options.';
    } else {
      comparisonMessage = 'Competitive with market average.';
    }

    state = EmiCalculationResult(
      loanAmount: loanAmount,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      emi: emi,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      marketAverageRate: marketAverageRate,
      comparisonMessage: comparisonMessage,
    );
  }
}

final emiCalculatorProvider = StateNotifierProvider<EmiCalculatorNotifier, EmiCalculationResult>((ref) {
  return EmiCalculatorNotifier();
});
