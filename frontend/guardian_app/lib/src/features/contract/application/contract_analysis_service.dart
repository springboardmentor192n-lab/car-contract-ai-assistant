
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:guardian_app/src/features/auth/domain/user_token.dart';
import 'package:guardian_app/services/api_service.dart';
import 'package:guardian_app/models/analysis_result.dart';

final contractAnalysisProvider = StateNotifierProvider<ContractAnalysisNotifier, AsyncValue<AnalysisResult?>>((ref) {
  return ContractAnalysisNotifier(ref);
});

class ContractAnalysisNotifier extends StateNotifier<AsyncValue<AnalysisResult?>> {
  ContractAnalysisNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> analyzeContract() async {
    state = const AsyncValue.loading();
    try {
      final authToken = ref.read(userTokenProvider);
      if (authToken == null) {
        throw Exception('User is not authenticated.');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;
        if (fileBytes != null) {
          final analysisResult = await ApiService.analyzeContract(fileBytes, fileName, authToken);
          state = AsyncValue.data(analysisResult);
        } else {
          throw Exception('Failed to read file.');
        }
      } else {
        // User canceled the picker
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
