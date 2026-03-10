import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/app_notification.dart';

class NotificationListTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'check_in_reminder':
        return Icons.login;
      case 'check_out_reminder':
        return Icons.logout;
      case 'unpaid_reminder':
        return Icons.payment;
      case 'status_change':
        return Icons.swap_horiz;
      case 'general':
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'check_in_reminder':
        return AppColors.checkIn;
      case 'check_out_reminder':
        return AppColors.checkOut;
      case 'unpaid_reminder':
        return AppColors.unpaid;
      case 'status_change':
        return AppColors.primary;
      case 'general':
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);
    final timestamp = timeago.format(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: notification.isRead
                        ? AppTextStyles.titleMedium
                        : AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
