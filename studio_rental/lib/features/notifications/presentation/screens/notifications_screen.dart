import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/notification_list_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

  /// Groups notifications into "Today", "Yesterday", "This Week", "Earlier"
  Map<String, List<AppNotification>> _groupByDate(
    List<AppNotification> notifications,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<AppNotification>> groups = {};

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String groupKey;
      if (date == today || date.isAfter(today)) {
        groupKey = l10n.notifications_today;
      } else if (date == yesterday) {
        groupKey = l10n.notifications_yesterday;
      } else if (date.isAfter(weekAgo)) {
        groupKey = l10n.notifications_this_week;
      } else {
        groupKey = l10n.notifications_earlier;
      }

      groups.putIfAbsent(groupKey, () => []);
      groups[groupKey]!.add(notification);
    }

    return groups;
  }

  void _onNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      context
          .read<NotificationsBloc>()
          .add(MarkAsRead(id: notification.id));
    }
    if (notification.reservationId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.reservationDetail,
        arguments: notification.reservationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications_title),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(const MarkAllAsRead()),
                  child: Text(
                    l10n.notifications_mark_all_read,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.notifications.isEmpty) {
            return ErrorStateWidget(
              message: state.error == 'network_error'
                  ? l10n.error_network
                  : l10n.error_generic,
              buttonText: l10n.button_retry,
              onRetry: () => context
                  .read<NotificationsBloc>()
                  .add(const LoadNotifications()),
            );
          }

          if (state.notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none,
              message: l10n.notifications_empty,
            );
          }

          final groups = _groupByDate(state.notifications, l10n);

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationsBloc>()
                  .add(const RefreshNotifications());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: groups.entries.fold<int>(
                0,
                (sum, entry) => sum + 1 + entry.value.length,
              ),
              itemBuilder: (context, index) {
                int currentIndex = 0;
                for (final entry in groups.entries) {
                  if (index == currentIndex) {
                    return _SectionHeader(title: entry.key);
                  }
                  currentIndex++;
                  if (index < currentIndex + entry.value.length) {
                    final notification =
                        entry.value[index - currentIndex];
                    return NotificationListTile(
                      notification: notification,
                      onTap: () => _onNotificationTap(notification),
                    );
                  }
                  currentIndex += entry.value.length;
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
