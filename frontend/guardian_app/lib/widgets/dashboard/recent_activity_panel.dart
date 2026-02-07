// lib/widgets/dashboard/recent_activity_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/activity.dart';
import '../../providers/websocket_providers.dart';
import '../../services/websocket_service.dart'; // Add this import
import '../common/skeleton_loader.dart';
import 'activity_list_item.dart';

/// Displays a real-time list of recent activities, powered by WebSockets.
/// Includes loading, empty, error, and connection status indicators.
class RecentActivityPanel extends ConsumerWidget {
  const RecentActivityPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Activity>> activityListAsync = ref.watch(activityListStreamProvider);
    final AsyncValue<WebSocketStatus> wsStatusAsync = ref.watch(webSocketStatusStreamProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // WebSocket Connection Status Indicator
            Align(
              alignment: Alignment.centerRight,
              child: _buildWebSocketStatusIndicator(context, wsStatusAsync),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activityListAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ActivityListItem(
                        activity: activity,
                        onTap: () {
                          context.go('/activity_detail/${activity.id}');
                        },
                      );
                    },
                  );
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(context, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSocketStatusIndicator(BuildContext context, AsyncValue<WebSocketStatus> wsStatusAsync) {
    return wsStatusAsync.when(
      data: (status) {
        Color color = Colors.grey; // Default initialization
        String text = 'Unknown'; // Default initialization
        IconData icon = Icons.help_outline; // Default initialization

        switch (status) {
          case WebSocketStatus.connected:
            color = Colors.green;
            text = 'Connected';
            icon = Icons.check_circle;
            break;
          case WebSocketStatus.connecting:
            color = Colors.orange;
            text = 'Connecting...';
            icon = Icons.hourglass_empty;
            break;
          case WebSocketStatus.disconnected:
            color = Colors.red;
            text = 'Disconnected';
            icon = Icons.close;
            break;
          case WebSocketStatus.error:
            color = Colors.redAccent;
            text = 'Error';
            icon = Icons.warning;
            break;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(), // Or a subtle loading indicator
      error: (e, s) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Text(
            'WS Error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5, // Show 5 skeleton loaders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SkeletonLoader(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 4),
                    SkeletonLoader(width: 100, height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SkeletonLoader(width: 60, height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No recent activity yet.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load activities.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Optionally re-connect WebSocket or retry API call
              // ref.refresh(activityListStreamProvider); // This would trigger a re-listen/re-connect
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}