import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
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

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationsBloc>()
                  .add(const RefreshNotifications());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationListTile(
                  notification: notification,
                  onTap: () {
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
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
