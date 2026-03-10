import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_strings.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/status_badge.dart';
import '../../domain/entities/calendar_reservation.dart';

class ReservationBottomSheet extends StatelessWidget {
  final CalendarReservation reservation;
  final String currency;

  const ReservationBottomSheet({
    super.key,
    required this.reservation,
    this.currency = 'BGN',
  });

  static Future<void> show({
    required BuildContext context,
    required CalendarReservation reservation,
    String currency = 'BGN',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationBottomSheet(
        reservation: reservation,
        currency: currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('dd MMM yyyy', locale);
    final currencySymbol = AppStrings.currencySymbols[currency] ?? currency;
    final numNights = reservation.numNights;
    final pricePerNight =
        numNights > 0 ? reservation.totalPrice / numNights : 0;
    final pricePerNightFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(pricePerNight / 100);
    final totalFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(reservation.totalPrice / 100);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reservation.guestFirstName,
                      style: AppTextStyles.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(l10n, reservation.status),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.login,
                label: l10n.bottom_sheet_check_in,
                value: dateFormat
                    .format(reservation.checkInDate.toLocal()),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.logout,
                label: l10n.bottom_sheet_check_out,
                value: dateFormat
                    .format(reservation.checkOutDate.toLocal()),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.nights_stay_outlined,
                label: l10n.bottom_sheet_nights(numNights),
                value: '',
              ),
              const Divider(height: 24, color: AppColors.divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pricePerNightFormatted ${l10n.bottom_sheet_price_per_night}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      _buildPaymentBadge(l10n, reservation.paymentStatus),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.bottom_sheet_total,
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        totalFormatted,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.editReservation,
                          arguments: reservation.id,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.bottom_sheet_edit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.reservationDetail,
                          arguments: reservation.id,
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(l10n.bottom_sheet_view_details),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
        if (value.isNotEmpty) ...[
          const Spacer(),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ],
    );
  }

  StatusBadge _buildStatusBadge(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusBadge.confirmed(l10n.status_confirmed);
      case 'pending':
        return StatusBadge.pending(l10n.status_pending);
      case 'cancelled':
        return StatusBadge.cancelled(l10n.status_cancelled);
      default:
        return StatusBadge.pending(status);
    }
  }

  StatusBadge _buildPaymentBadge(
      AppLocalizations l10n, String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return StatusBadge.paid(l10n.payment_paid);
      case 'partially_paid':
        return StatusBadge.partiallyPaid(l10n.payment_partially_paid);
      case 'unpaid':
        return StatusBadge.unpaid(l10n.payment_unpaid);
      default:
        return StatusBadge.unpaid(paymentStatus);
    }
  }
}
