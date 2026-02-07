import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/core/api/api_service.dart';
import 'package:guardian_app/src/core/api/dio_client.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApiService(dio);
});

class AuthApiService extends ApiService {
  AuthApiService(Dio dio) : super(dio);

  Future<Response> login(String username, String password) {
    return post(
      '/users/token',
      data: FormData.fromMap({
        'username': username,
        'password': password,
      }),
    );
  }

  Future<Response> signup(String username, String email, String password) {
    return post('/users/register', data: {
      'username': username,
      'email': email,
      'password': password
    });
  }
}