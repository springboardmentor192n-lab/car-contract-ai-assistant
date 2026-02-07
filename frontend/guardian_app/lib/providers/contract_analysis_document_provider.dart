// lib/providers/contract_analysis_document_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/contract_analysis_service.dart';
import '../providers/api_providers.dart';
import 'dart:typed_data';

/// A StateNotifier to manage contract document analysis operations and their state.
class ContractAnalysisDocumentNotifier extends StateNotifier<AsyncValue<DocumentContractAnalysisResult?>> {
  final ContractAnalysisService _analysisService;

  ContractAnalysisDocumentNotifier(this._analysisService) : super(const AsyncValue.data(null));

  Future<void> analyzeDocument({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _analysisService.analyzeContract(
        fileName: fileName,
        fileBytes: fileBytes,
      );
      state = AsyncValue.data(result);
    } on ApiException catch (e, stack) {
      state = AsyncValue.error(e.message, stack);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for ContractAnalysisService.
final contractAnalysisServiceProvider = Provider<ContractAnalysisService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ContractAnalysisService(apiService);
});

/// StateNotifierProvider for managing contract document analysis state.
final contractAnalysisDocumentProvider = StateNotifierProvider<ContractAnalysisDocumentNotifier, AsyncValue<DocumentContractAnalysisResult?>>((ref) {
  final analysisService = ref.watch(contractAnalysisServiceProvider);
  return ContractAnalysisDocumentNotifier(analysisService);
});
