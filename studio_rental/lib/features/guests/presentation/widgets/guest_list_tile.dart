import 'package:flutter/material.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import '../../domain/entities/guest_list_item.dart';
import 'guest_avatar.dart';

class GuestListTile extends StatelessWidget {
  final GuestListItem guest;
  final VoidCallback onTap;

  const GuestListTile({
    super.key,
    required this.guest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    String subtitle;
    if (guest.hasUpcoming && guest.lastStayDate != null) {
      subtitle = l10n.guest_list_upcoming_stay(dateFormat.format(guest.lastStayDate!));
    } else if (guest.lastStayDate != null) {
      subtitle = l10n.guest_list_last_stay(dateFormat.format(guest.lastStayDate!));
    } else {
      subtitle = l10n.guest_list_no_stays;
    }

    final staysText = guest.totalStays > 0
        ? l10n.guest_list_stays(guest.totalStays)
        : l10n.guest_list_no_stays;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GuestAvatar(initials: guest.initials),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.fullName,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              staysText,
              style: AppTextStyles.caption,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
