import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_strings.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/status_badge.dart';
import '../../domain/entities/reservation_summary.dart';

class ReservationListItem extends StatelessWidget {
  final ReservationSummary reservation;
  final String currency;
  final VoidCallback? onTap;

  const ReservationListItem({
    super.key,
    required this.reservation,
    this.currency = 'BGN',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM', Localizations.localeOf(context).languageCode);
    final currencySymbol = AppStrings.currencySymbols[currency] ?? currency;
    final formattedPrice = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(reservation.totalPrice / 100);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.guestName,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(reservation.checkInDate.toLocal())} - ${dateFormat.format(reservation.checkOutDate.toLocal())}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reservation.numNights} ${reservation.numNights == 1 ? l10n.bottom_sheet_nights(1).replaceAll('1 ', '') : l10n.bottom_sheet_nights(reservation.numNights).replaceAll('${reservation.numNights} ', '')}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedPrice,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 6),
                _buildStatusBadge(l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StatusBadge _buildStatusBadge(AppLocalizations l10n) {
    switch (reservation.status.toLowerCase()) {
      case 'confirmed':
        return StatusBadge.confirmed(l10n.status_confirmed);
      case 'pending':
        return StatusBadge.pending(l10n.status_pending);
      case 'cancelled':
        return StatusBadge.cancelled(l10n.status_cancelled);
      default:
        return StatusBadge.pending(reservation.status);
    }
  }
}
