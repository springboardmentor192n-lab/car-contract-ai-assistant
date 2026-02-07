// lib/core/config.dart
/// Configuration for the application, including API endpoints.
class AppConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const int retryCount = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}