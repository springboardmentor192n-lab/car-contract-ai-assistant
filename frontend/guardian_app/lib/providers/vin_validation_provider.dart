// lib/providers/vin_validation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/vin_validation_service.dart';
import '../providers/api_providers.dart'; // Add this import

/// A StateNotifier to manage VIN validation operations and their state.
class VinValidationNotifier extends StateNotifier<AsyncValue<VinValidationResult?>> {
  final VinValidationService _vinService;

  VinValidationNotifier(this._vinService) : super(const AsyncValue.data(null));

  Future<void> validateVin(String vin) async {
    state = const AsyncValue.loading();
    try {
      final result = await _vinService.validateVin(vin);
      state = AsyncValue.data(result);
    } on ApiException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  void clearValidationResult() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for VinValidationService.
final vinValidationServiceProvider = Provider<VinValidationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VinValidationService(apiService);
});

/// StateNotifierProvider for managing VIN validation state.
final vinValidationProvider = StateNotifierProvider<VinValidationNotifier, AsyncValue<VinValidationResult?>>((ref) {
  final vinService = ref.watch(vinValidationServiceProvider);
  return VinValidationNotifier(vinService);
});
