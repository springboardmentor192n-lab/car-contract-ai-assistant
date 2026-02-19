
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post('/auth/token', data: {
        'username': email,
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        return null; // No error
      }
      return "Login failed";
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data['detail'] ?? "Login failed";
      }
      return "Network error";
    }
  }

  Future<String?> signup(String email, String password, String fullName) async {
    try {
      final response = await _apiService.dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });

      if (response.statusCode == 200) {
        return null; // Success
      }
      return "Signup failed";
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data['detail'] ?? "Signup failed";
      }
      return "Network error";
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
