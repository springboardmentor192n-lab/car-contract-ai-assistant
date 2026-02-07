// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config.dart';
import '../models/activity.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

/// A service to manage real-time WebSocket communication for the activity feed.
class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<List<Activity>> _activityStreamController = StreamController<List<Activity>>.broadcast();
  final StreamController<WebSocketStatus> _statusStreamController = StreamController<WebSocketStatus>.broadcast();

  Timer? _reconnectTimer;
  Timer? _mockDataTimer; // Timer for mock data simulation
  final Duration _reconnectDelay = const Duration(seconds: 5);

  WebSocketService() {
    _statusStreamController.add(WebSocketStatus.disconnected);
  }

  Stream<List<Activity>> get activityStream => _activityStreamController.stream;
  Stream<WebSocketStatus> get statusStream => _statusStreamController.stream;

  void connect() {
    _statusStreamController.add(WebSocketStatus.connecting);
    // In a real app, this connects to a live WebSocket.
    // For this enhancement, we'll use a mock stream to demonstrate the new activity types.
    _simulateWebSocket();
  }

  void _simulateWebSocket() {
    _statusStreamController.add(WebSocketStatus.connected);

    // Initial mock data
    final mockActivities = [
      Activity(id: '1', title: 'VIN 1HG...', type: ActivityType.vinLookup, status: 'Completed', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      Activity(id: '2', title: 'Contract.pdf', type: ActivityType.contractUpload, status: 'High Risk Detected', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
      Activity(id: '3', title: 'Lease_Agreement.docx', type: ActivityType.contractUpload, status: 'Completed', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
      Activity(id: '4', title: 'VIN WBA...', type: ActivityType.vinLookup, status: 'Completed', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
      Activity(id: '5', title: 'Auto_Loan.pdf', type: ActivityType.contractUpload, status: 'Analysis In Progress', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    ];
    _activityStreamController.add(mockActivities);

    // Simulate receiving new activities periodically
    _mockDataTimer = Timer.periodic(const Duration(seconds: 5), (timer) { // Increased frequency for demo
      final rand = DateTime.now().millisecond % 3;
      Activity newActivity;
      if (rand == 0) {
        newActivity = Activity(id: DateTime.now().millisecondsSinceEpoch.toString(), title: 'VIN XYZ...', type: ActivityType.vinLookup, status: 'Completed', timestamp: DateTime.now());
      } else if (rand == 1) {
        newActivity = Activity(id: DateTime.now().millisecondsSinceEpoch.toString(), title: 'Loan_Offer_${DateTime.now().second}.pdf', type: ActivityType.contractUpload, status: 'Analysis In Progress', timestamp: DateTime.now());
      } else {
        // Simulate an update to an existing activity or a new high risk one
        if (mockActivities.any((act) => act.status == 'Analysis In Progress')) {
          final processingAct = mockActivities.firstWhere((act) => act.status == 'Analysis In Progress');
          mockActivities.remove(processingAct);
          newActivity = Activity(id: processingAct.id, title: processingAct.title, type: ActivityType.contractUpload, status: (DateTime.now().second % 2 == 0 ? 'Completed' : 'High Risk Detected'), timestamp: DateTime.now());
        } else {
          newActivity = Activity(id: DateTime.now().millisecondsSinceEpoch.toString(), title: 'High_Risk_Contract.pdf', type: ActivityType.contractUpload, status: 'High Risk Detected', timestamp: DateTime.now());
        }
      }

      // Ensure duplicates are handled (update existing or add new)
      final index = mockActivities.indexWhere((element) => element.id == newActivity.id);
      if (index != -1) {
        mockActivities[index] = newActivity;
      } else {
        mockActivities.insert(0, newActivity); // Add new to top
      }
      _activityStreamController.add(List.from(mockActivities.take(10))); // Limit to 10 recent activities
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _mockDataTimer?.cancel(); // Cancel the mock data timer
    _channel?.sink.close();
    if (kDebugMode) {
      print('WebSocketService disposed.');
    }
  }

  void disconnect() {
    dispose(); // Call the main dispose logic
  }
}
