import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/data/api/auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  return AuthRepository(authApiService);
});

class AuthRepository {
  final AuthApiService _authApiService;

  AuthRepository(this._authApiService);

  Future<void> login(String username, String password) async {
    try {
      final response = await _authApiService.login(username, password);
      // TODO: Handle successful login, e.g., save token
    } catch (e) {
      // TODO: Handle error
      rethrow;
    }
  }

  Future<void> signup(String username, String email, String password) async {
    try {
      final response = await _authApiService.signup(username, email, password);
      // TODO: Handle successful signup
    } catch (e) {
      // TODO: Handle error
      rethrow;
    }
  }
}