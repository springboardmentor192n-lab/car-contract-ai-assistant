// lib/src/features/dashboard/presentation/components/recent_activity_feed.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/src/core/theme/app_colors.dart';
import 'package:guardian_app/src/core/theme/app_text_styles.dart';
import 'package:guardian_app/src/core/widgets/section_card.dart';
import 'package:guardian_app/src/core/widgets/status_chip.dart';
import 'package:guardian_app/src/features/dashboard/presentation/screens/dashboard_screen.dart'; // Import for recentActivityProvider

// --- NEW COMPONENT: RecentActivityFeed ---
class RecentActivityFeed extends ConsumerWidget {
  const RecentActivityFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentActivityAsync = ref.watch(recentActivityProvider);

    return SectionCard(
      title: 'Recent Activity',
      trailing: TextButton(onPressed: () {}, child: Text('View All', style: AppTextStyles.labelMedium)),
      padding: const EdgeInsets.all(20),
      child: recentActivityAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const SizedBox(
              height: 150, // Give some height for empty state
              child: Center(
                child: Text(
                  'No recent activity. Get started with an analysis!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Column(
            children: activities.map((activity) {
              StatusType statusType;
              IconData statusIcon;
              switch (activity['status']) {
                case 'Completed':
                  statusType = StatusType.success;
                  statusIcon = Icons.check_circle_outline;
                  break;
                case 'Analyzing...':
                  statusType = StatusType.primary;
                  statusIcon = Icons.cached;
                  break;
                case 'Pending':
                  statusType = StatusType.warning;
                  statusIcon = Icons.watch_later_outlined;
                  break;
                default:
                  statusType = StatusType.info;
                  statusIcon = Icons.info_outline;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(statusIcon, color: AppColors.primary),
                  title: Text(activity['title'], style: AppTextStyles.titleSmall),
                  subtitle: Text(
                    '${activity['status']} - ${activity['timestamp'].toLocal().toString().substring(0, 16)}',
                    style: AppTextStyles.bodySmall?.copyWith(color: AppColors.subtleTextColor),
                  ),
                  trailing: StatusChip(text: activity['status'], type: statusType),
                  onTap: () {
                    if (activity['route'] != null) {
                      GoRouter.of(context).go(activity['route']);
                    }
                  },
                  tileColor: AppColors.cardBackground,
                  hoverColor: AppColors.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => SizedBox(
          height: 150,
          child: Center(child: Text('Error loading activity: $err', style: AppTextStyles.bodySmall?.copyWith(color: AppColors.error))),
        ),
      ),
    );
  }
}
