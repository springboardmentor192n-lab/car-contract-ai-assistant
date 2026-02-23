// lib/core/config.dart
/// Configuration for the application, including API endpoints.
class AppConfig {
  static const String baseUrl = 'https://car-contract-ai-assistant.onrender.com';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int retryCount = 1; // Reducing retries to avoid compounding timeout
  static const Duration retryDelay = Duration(seconds: 2);
}