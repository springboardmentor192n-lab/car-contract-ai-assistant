
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/contract/application/contract_analysis_service.dart';
import 'package:guardian_app/src/shared/widgets/primary_button.dart';

class ContractAnalysisScreen extends ConsumerWidget {
  const ContractAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAnalysisState = ref.watch(contractAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(contractAnalysisProvider.notifier).reset(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              text: 'Upload Contract (PDF)',
              onPressed: () {
                ref.read(contractAnalysisProvider.notifier).analyzeContract();
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: contractAnalysisState.when(
                data: (analysis) {
                  if (analysis == null) {
                    return const Center(
                        child: Text('Analysis results will be shown here.'));
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Risk Level: ${analysis.riskLevel}'),
                          const SizedBox(height: 8),
                          Text('Summary: ${analysis.summary}'),
                        ],
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
