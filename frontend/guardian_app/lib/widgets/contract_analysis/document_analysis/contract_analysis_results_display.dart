// lib/widgets/contract_analysis/document_analysis/contract_analysis_results_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../services/contract_analysis_service.dart';
import '../../../providers/contract_analysis_document_provider.dart';

/// A widget to display structured results of a contract document analysis with enhanced UI.
class ContractAnalysisResultsDisplay extends ConsumerWidget {
  final DocumentContractAnalysisResult result;

  const ContractAnalysisResultsDisplay({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine risk styling
    final (riskColor, riskExplanation) = _getRiskStylingAndExplanation(result.riskLevel);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Info and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis for: ${result.fileName}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}', // Mock date
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref.read(contractAnalysisDocumentProvider.notifier).clearResult(),
                  tooltip: 'Analyze another document',
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1), // Visual separation

            // 1. Risk Level Presentation (Prominent Badge)
            _buildRiskBadge(context, result.riskLevel, riskColor, riskExplanation),
            const SizedBox(height: 24),

            // 3a. Detected Contract Clauses (Factual Findings)
            Text(
              'Detected Contract Clauses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16, thickness: 0.5),
            _buildResultList(context, 'Hidden Fees Detected', result.hiddenFees, Icons.money_off_csred_outlined),
            _buildResultList(context, 'Unfair Clauses', result.unfairClauses, Icons.gavel_outlined),
            _buildResultList(context, 'Penalties & Early Termination Risks', result.penalties, Icons.receipt_long),
            const SizedBox(height: 24),

            // 2. Contract Health Checklist
            Text(
              'Contract Health Check',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16, thickness: 0.5),
            _buildContractHealthChecklist(context, result),
            const SizedBox(height: 24),

            // 3b. AI Assessment (Plain-English Interpretation)
            Text(
              'AI Assessment & Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16, thickness: 0.5),
            _buildResultSummary(context, result.summary),
            const SizedBox(height: 24),

            // 4. Recommended Actions Section
            Text(
              'Recommended Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16, thickness: 0.5),
            _buildRecommendedActions(context, result.riskLevel),
            const SizedBox(height: 24),

            // 7. Optional UI Enhancements
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: null, // Disabled for now
                icon: const Icon(Icons.download),
                label: const Text('Download Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, String) _getRiskStylingAndExplanation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return (Colors.redAccent, "Significant risks and potentially unfair terms detected. Urgent review recommended.");
      case 'medium':
        return (Colors.orangeAccent, "Some clauses require attention. Review carefully before proceeding.");
      default: // Low
        return (Colors.green, "No major risks or unusual clauses detected. Appears to be a standard agreement.");
    }
  }

  Widget _buildRiskBadge(BuildContext context, String riskLevel, Color color, String explanation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, color: color, size: 30),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                'RISK LEVEL: ${riskLevel.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 42.0), // Align with icon + text
          child: Text(
            explanation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildContractHealthChecklist(BuildContext context, DocumentContractAnalysisResult result) {
    bool hasHiddenFees = result.hiddenFees.isNotEmpty;
    String penaltiesStatus = result.penalties.any((p) => p.toLowerCase().contains('high') || p.toLowerCase().contains('excessive')) ? 'High' : (result.penalties.isNotEmpty ? 'Standard' : 'None');
    bool hasUnfairClauses = result.unfairClauses.isNotEmpty;
    String interestPaymentRisks = 'Normal'; // Simple mock for now
    if (result.riskLevel.toLowerCase() == 'high' && (hasHiddenFees || hasUnfairClauses)) {
      interestPaymentRisks = 'Elevated';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHealthChecklistItem(context, 'Hidden Fees Detected', hasHiddenFees ? 'Yes' : 'No', hasHiddenFees ? Colors.red : Colors.green),
        _buildHealthChecklistItem(context, 'Early Termination Penalties', penaltiesStatus, penaltiesStatus == 'High' ? Colors.red : (penaltiesStatus == 'Standard' ? Colors.orange : Colors.green)),
        _buildHealthChecklistItem(context, 'Unfair Clauses', hasUnfairClauses ? 'Review Needed' : 'None Found', hasUnfairClauses ? Colors.red : Colors.green),
        _buildHealthChecklistItem(context, 'Interest or Payment Risks', interestPaymentRisks, interestPaymentRisks == 'Elevated' ? Colors.red : Colors.green),
      ],
    );
  }

  Widget _buildHealthChecklistItem(BuildContext context, String label, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(status == 'Yes' || status == 'High' || status == 'Review Needed' || status == 'Elevated' ? Icons.cancel_outlined : Icons.check_circle_outline, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(status, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultList(BuildContext context, String title, List<String> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((item) => ListTile(
                leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                title: Text(item),
                dense: true,
                contentPadding: EdgeInsets.zero, // Remove default padding
              )),
        ],
      ),
    );
  }

  Widget _buildResultSummary(BuildContext context, String summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The title is already handled by the 'AI Assessment & Summary' section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(BuildContext context, String riskLevel) {
    List<String> actions = [];
    switch (riskLevel.toLowerCase()) {
      case 'high':
        actions = [
          'Consult with a legal expert or financial advisor immediately.',
          'Do NOT sign this contract without further professional review.',
          'Explore alternative loan offers from different lenders.'
        ];
        break;
      case 'medium':
        actions = [
          'Carefully review all highlighted clauses and clarify terms with the lender.',
          'Consider negotiating specific terms or seek a second opinion.',
          'Ensure you fully understand the implications of penalties before committing.'
        ];
        break;
      default: // Low
        actions = [
          'Read the entire contract thoroughly for any details not covered by the analysis.',
          'Confirm all terms and conditions match your understanding.',
          'Keep a copy of the signed agreement for your records.'
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map((action) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}