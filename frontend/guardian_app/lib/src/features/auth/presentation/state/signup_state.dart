import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_state.g.dart';

@Riverpod(keepAlive: true)
class SignupController extends _$SignupController {
  @override
  FutureOr<void> build() {
    // No-op
  }

  Future<void> signup(String username, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signup(username, email, password));
  }
}