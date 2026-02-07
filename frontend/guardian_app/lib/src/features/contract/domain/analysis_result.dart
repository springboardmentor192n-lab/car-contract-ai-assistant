import 'package:flutter/material.dart';

@immutable
class AnalysisResult {
  final String id;
  final String contractName;
  final double apr;
  final int loanTerm;
  final double monthlyPayment;
  final int mileageLimit;
  final List<String> redFlags;
  final double fairnessScore;

  const AnalysisResult({
    required this.id,
    required this.contractName,
    required this.apr,
    required this.loanTerm,
    required this.monthlyPayment,
    required this.mileageLimit,
    required this.redFlags,
    required this.fairnessScore,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      contractName: json['contractName'] as String,
      apr: (json['apr'] as num).toDouble(),
      loanTerm: json['loanTerm'] as int,
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      mileageLimit: json['mileageLimit'] as int,
      redFlags: List<String>.from(json['redFlags'] as List),
      fairnessScore: (json['fairnessScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractName': contractName,
      'apr': apr,
      'loanTerm': loanTerm,
      'monthlyPayment': monthlyPayment,
      'mileageLimit': mileageLimit,
      'redFlags': redFlags,
      'fairnessScore': fairnessScore,
    };
  }
}