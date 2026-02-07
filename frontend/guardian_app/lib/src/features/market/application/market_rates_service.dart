
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/domain/user_token.dart';
import 'package:guardian_app/services/api_service.dart';
import 'package:guardian_app/models/market_rates_response.dart';

final marketRatesProvider = StateNotifierProvider<MarketRatesNotifier, AsyncValue<MarketRatesResponse?>>((ref) {
  return MarketRatesNotifier(ref);
});

class MarketRatesNotifier extends StateNotifier<AsyncValue<MarketRatesResponse?>> {
  MarketRatesNotifier(this.ref) : super(const AsyncValue.data(null)) {
    fetchMarketRates();
  }

  final Ref ref;

  Future<void> fetchMarketRates() async {
    state = const AsyncValue.loading();
    try {
      final authToken = ref.read(userTokenProvider);
      if (authToken == null) {
        throw Exception('User is not authenticated.');
      }
      final marketRates = await ApiService.getMarketRates(authToken);
      state = AsyncValue.data(marketRates);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
