// lib/widgets/dashboard/activity_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';

/// Displays a single activity item with icons and colors based on its type and status.
class ActivityListItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityListItem({
    Key? key,
    required this.activity,
    required this.onTap,
  }) : super(key: key);

  // Helper to get styling based on activity type and status
  ({IconData icon, Color color}) _getStyling() {
    switch (activity.type) {
      case ActivityType.vinLookup:
        return (icon: Icons.pin_outlined, color: Colors.blue);
      case ActivityType.contractUpload:
        if (activity.status.toLowerCase().contains('risk detected')) {
          return (icon: Icons.gavel_rounded, color: Colors.redAccent);
        }
        return (icon: Icons.upload_file_outlined, color: Colors.green);
      case ActivityType.negotiation:
        return (icon: Icons.support_agent_outlined, color: Colors.purple);
      default:
        return (icon: Icons.history, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styling = _getStyling();
    final formattedTime = DateFormat('hh:mm a').format(activity.timestamp);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: styling.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                styling.icon,
                color: styling.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    activity.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: styling.color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
