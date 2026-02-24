// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/config.dart';

enum HttpMethod { get, post, put, delete }

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

class ApiService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> _request({
    required HttpMethod method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    int retryCount = AppConfig.retryCount,
  }) async {
    final String cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    Uri uri = Uri.parse('$cleanBaseUrl$cleanEndpoint');
    http.Response? response;
    int currentRetry = 0;

    // Default headers
    headers ??= {};
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';

    while (currentRetry <= retryCount) {
      try {
        switch (method) {
          case HttpMethod.get:
            response = await http.get(uri, headers: headers).timeout(AppConfig.timeoutDuration);
            break;
          case HttpMethod.post:
            response = await http.post(
              uri,
              headers: headers,
              body: data != null ? json.encode(data) : null,
            ).timeout(AppConfig.timeoutDuration);
            break;
          case HttpMethod.put:
            response = await http.put(
              uri,
              headers: headers,
              body: data != null ? json.encode(data) : null,
            ).timeout(AppConfig.timeoutDuration);
            break;
          case HttpMethod.delete:
            response = await http.delete(uri, headers: headers).timeout(AppConfig.timeoutDuration);
            break;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isNotEmpty) {
            return json.decode(response.body) as Map<String, dynamic>;
          }
          return {}; // Return empty map for successful requests with no body
        } else {
          // Attempt to parse error message from response body
          String errorMessage = 'An unexpected error occurred.';
          try {
            if (response.body.isNotEmpty) {
              final errorBody = json.decode(response.body);
              errorMessage = errorBody['detail'] as String? ?? errorMessage;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to parse error body: $e');
            }
          }
          throw ApiException(errorMessage, statusCode: response.statusCode);
        }
      } on http.ClientException catch (e) {
        if (kDebugMode) {
          print('HTTP Client Error: $e');
        }
        if (currentRetry < retryCount) {
          await Future.delayed(AppConfig.retryDelay);
          currentRetry++;
          continue;
        }
        throw ApiException('Network error or connection failed: ${e.message}');
      } on Exception catch (e) {
        if (kDebugMode) {
          print('API Request Error: $e');
        }
        if (currentRetry < retryCount) {
          await Future.delayed(AppConfig.retryDelay);
          currentRetry++;
          continue;
        }
        throw ApiException('Failed to connect to the server: ${e.toString()}');
      }
    }
    throw ApiException('Request failed after $retryCount retries.');
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    return _request(method: HttpMethod.get, endpoint: endpoint, headers: headers);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    return _request(method: HttpMethod.post, endpoint: endpoint, data: data, headers: headers);
  }
  // You can add put and delete methods as well if needed.
}