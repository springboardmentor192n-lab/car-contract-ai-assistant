import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/core/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});