// lib/models/activity.dart

enum ActivityType { contractUpload, vinLookup, negotiation, unknown }

/// Represents a single activity item in the recent activity feed.
class Activity {
  final String id;
  final String title;
  final ActivityType type;
  final String status; // e.g., 'Completed', 'Processing', 'Risk Detected'
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _activityTypeFromString(json['type'] as String?),
      status: json['status'] as String? ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static ActivityType _activityTypeFromString(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'contract_upload':
        return ActivityType.contractUpload;
      case 'vin_lookup':
        return ActivityType.vinLookup;
      case 'negotiation':
        return ActivityType.negotiation;
      default:
        return ActivityType.unknown;
    }
  }
}
