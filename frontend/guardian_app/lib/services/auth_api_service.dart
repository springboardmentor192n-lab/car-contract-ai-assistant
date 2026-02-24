// frontend/guardian_app/lib/services/auth_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian_app/models/user.dart';
import 'package:guardian_app/models/token.dart';

class AuthApiService {
  // Replace with your FastAPI backend URL
  static const String _baseUrl = 'https://car-contract-ai-assistant.onrender.com'; 

  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Token> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Example of an authenticated request
  Future<User> getMe(String accessToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  }
}
