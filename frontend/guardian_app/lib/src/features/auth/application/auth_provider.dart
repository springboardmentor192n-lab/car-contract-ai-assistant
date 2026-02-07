import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/domain/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier() : super(AuthStatus.unknown);

  Future<void> login(String email, String password) async {
    // In a real app, you would make an API call to authenticate the user
    // For this example, we will just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
    state = AuthStatus.authenticated;
  }

  Future<void> signup(String name, String email, String password) async {
    // In a real app, you would make an API call to create a new user
    // For this example, we will just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    state = AuthStatus.unauthenticated;
  }
}