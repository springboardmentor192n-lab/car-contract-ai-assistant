// lib/providers/api_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// Provider for ApiService, ensuring a single instance across the app.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});