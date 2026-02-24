import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/contract_analysis_document_provider.dart';
import '../widgets/contract_analysis/document_analysis/contract_document_uploader.dart';
import '../widgets/contract_analysis/document_analysis/contract_analysis_results_display.dart';
import '../widgets/responsive/responsive_layout.dart';

class ContractAnalysisScreen extends ConsumerWidget {
  const ContractAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: const _ContractAnalysisContent(padding: 16.0),
      desktop: const _ContractAnalysisContent(padding: 48.0),
    );
  }
}

class _ContractAnalysisContent extends ConsumerWidget {
  final double padding;

  const _ContractAnalysisContent({Key? key, required this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(contractAnalysisDocumentProvider);
    final filter = GoRouterState.of(context).uri.queryParameters['filter'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Contract Analysis',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your agreement for AI-powered risk assessment.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              analysisState.when(
                data: (result) {
                  if (result == null) {
                    return const ContractDocumentUploader();
                  }
                  return ContractAnalysisResultsDisplay(result: result);
                },
                loading: () => const ContractDocumentUploader(), // Ideally show loading state inside
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error analyzing document',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ref.refresh(contractAnalysisDocumentProvider); // Or similar reset
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              if (filter == 'high_risk')
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Displaying contracts filtered for high risk.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.redAccent,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
