// lib/services/chatbot_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contract_analysis_provider.dart';
import '../providers/emi_calculator_provider.dart';

/// Represents a message in the chatbot conversation.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

/// A service to handle chatbot logic, including generating context-aware responses.
class ChatbotService {
  final Ref ref; // Change from Reader to Ref

  ChatbotService(this.ref); // Update constructor

  final Map<String, String> _knowledgeBase = {
    'emi': """EMI stands for Equated Monthly Installment. It's a fixed payment amount made by a borrower to a lender at a specified date each calendar month. EMIs are used to pay off both interest and principal each month, so that over a specified number of years, the loan is fully paid off.""",
    'penalty': """Penalty clauses in a loan contract specify additional charges if you fail to meet obligations, such as late payments or early repayment (prepayment penalty).""",
    'hidden charges': """Hidden charges are fees not immediately obvious. These can include processing fees, administrative charges, or late payment fees. Always read the fine print.""",
    'lease vs loan': """A loan involves borrowing money to purchase an asset you then own. A lease is a long-term rental; you pay to use the asset but do not own it.""",
    'risk': """The risk level of a contract assesses factors like high interest rates, excessive fees, or harsh penalties. 'High' risk could lead to significant financial burden.""",
    'vin': 'A VIN (Vehicle Identification Number) is a unique 17-character code used to identify individual motor vehicles.',
    'hello': 'Hello! How can I help you understand your auto finance today?',
    'help': 'You can ask me to explain terms like "EMI", "risk level", "lease vs loan", or ask about your current calculation results.',
  };

  // Simulate AI processing delay
  Future<String> getResponse(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final lowerCaseMessage = userMessage.toLowerCase().trim();

    // Check for context-specific keywords
    if (lowerCaseMessage.contains('my emi') || lowerCaseMessage.contains('my calculation')) {
      final emiResult = ref.read(emiCalculatorProvider); // Use ref.read
      if (emiResult.emi > 0) {
        return "Based on your last calculation, your monthly EMI is \$${emiResult.emi.toStringAsFixed(2)} for a loan of \$${emiResult.loanAmount.toStringAsFixed(0)} at ${emiResult.annualInterestRate}% for ${emiResult.tenureMonths} months. The total interest will be \$${emiResult.totalInterest.toStringAsFixed(2)}.";
      } else {
        return "I don't have a recent EMI calculation for you. Please use the EMI Calculator on the Market Rates screen first.";
      }
    }

    if (lowerCaseMessage.contains('my contract') || lowerCaseMessage.contains('my risk')) {
      final contractResult = ref.read(contractAnalysisProvider); // Use ref.read
      if (contractResult.loanAmount > 0) {
        return "Your last contract analysis showed a risk level of '${contractResult.riskLevel}'. The total payable amount was estimated at \$${contractResult.estimatedTotalPayable.toStringAsFixed(2)}. The main reason for the risk assessment was: ${contractResult.unfairTerms.join(', ')}.";
      } else {
        return "I haven't analyzed any contract details for you yet. Please use the Contract Analysis tool.";
      }
    }

    // Try to find a direct match in the knowledge base
    for (var entry in _knowledgeBase.entries) {
      if (lowerCaseMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default response if no match
    return "I'm sorry, I don't have information on that. You can ask me about 'EMI', 'risk', 'penalties', or about 'my emi' if you've done a calculation.";
  }
}