import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/auth/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_state.g.dart';

@Riverpod(keepAlive: true)
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // No-op
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).login(username, password));
  }
}