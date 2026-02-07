
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/domain/user_token.dart';
import 'package:guardian_app/services/api_service.dart';
import 'package:guardian_app/models/vehicle_details.dart';

final vinLookupProvider = StateNotifierProvider<VINLookupNotifier, AsyncValue<VehicleDetails?>>((ref) {
  return VINLookupNotifier(ref);
});

class VINLookupNotifier extends StateNotifier<AsyncValue<VehicleDetails?>> {
  VINLookupNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> lookupVIN(String vin) async {
    state = const AsyncValue.loading();
    try {
      final authToken = ref.read(userTokenProvider);
      if (authToken == null) {
        throw Exception('User is not authenticated.');
      }
      final vehicleDetails = await ApiService.getVehicleDetails(vin, authToken);
      state = AsyncValue.data(vehicleDetails);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
