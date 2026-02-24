// lib/core/config.dart
import 'package:flutter/foundation.dart';

/// Configuration for the application, including API endpoints.
class AppConfig {
  static const String baseUrl = kReleaseMode
      ? 'https://car-contract-ai-assistant.onrender.com'
      : 'http://localhost:8000';
  static const Duration timeoutDuration = Duration(seconds: 120);
  static const int retryCount = 1;
  static const Duration retryDelay = Duration(seconds: 2);
}