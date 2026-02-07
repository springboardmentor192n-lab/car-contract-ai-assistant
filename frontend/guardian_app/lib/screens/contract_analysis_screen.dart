// lib/screens/contract_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import
import '../providers/contract_analysis_document_provider.dart';
import '../widgets/contract_analysis/document_analysis/contract_document_uploader.dart';
import '../widgets/contract_analysis/document_analysis/contract_analysis_results_display.dart';

/// A screen dedicated to uploading and analyzing contract documents.
/// It features a file uploader and displays structured analysis results.
class ContractAnalysisScreen extends ConsumerWidget {
  const ContractAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(contractAnalysisDocumentProvider);
    final filter = GoRouterState.of(context).uri.queryParameters['filter']; // Read filter from query params

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Contract Document Analysis',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your car loan or lease agreement for an AI-powered risk assessment and summary.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              analysisState.when(
                data: (result) {
                  if (result == null) {
                    return ContractDocumentUploader();
                  }
                  return ContractAnalysisResultsDisplay(result: result);
                },
                loading: () => const ContractDocumentUploader(), // Show uploader with loading indicator
                error: (err, stack) => Column(
                  children: [
                    Text('Error: $err', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(contractAnalysisDocumentProvider.notifier).clearResult(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              if (filter == 'high_risk') // Example of showing filter content
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    'Displaying contracts filtered for high risk.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}