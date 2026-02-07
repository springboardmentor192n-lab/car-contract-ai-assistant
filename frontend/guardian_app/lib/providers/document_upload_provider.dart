// lib/providers/document_upload_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/document_upload_service.dart';
import '../providers/api_providers.dart';
import 'dart:typed_data';

/// A StateNotifier to manage document upload and analysis operations.
class DocumentUploadNotifier extends StateNotifier<AsyncValue<DocumentAnalysisResult?>> {
  final DocumentUploadService _uploadService;

  DocumentUploadNotifier(this._uploadService) : super(const AsyncValue.data(null));

  Future<void> uploadDocument({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _uploadService.uploadDocument(
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

/// Provider for DocumentUploadService.
final documentUploadServiceProvider = Provider<DocumentUploadService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DocumentUploadService(apiService);
});

/// StateNotifierProvider for managing document upload and analysis state.
final documentUploadProvider = StateNotifierProvider<DocumentUploadNotifier, AsyncValue<DocumentAnalysisResult?>>((ref) {
  final uploadService = ref.watch(documentUploadServiceProvider);
  return DocumentUploadNotifier(uploadService);
});