// lib/providers/websocket_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import '../models/activity.dart';

/// Provider for WebSocketService, managing its lifecycle.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  // Connect immediately when the service is created
  service.connect();

  // Dispose the service when the provider is no longer needed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// StreamProvider for the list of activities from the WebSocketService.
final activityListStreamProvider = StreamProvider<List<Activity>>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.activityStream;
});

/// StreamProvider for the WebSocket connection status.
final webSocketStatusStreamProvider = StreamProvider<WebSocketStatus>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.statusStream;
});