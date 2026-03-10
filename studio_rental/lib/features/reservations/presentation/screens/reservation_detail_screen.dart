import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/status_badge.dart';
import 'package:studio_rental/core/di/service_locator.dart';
import 'package:studio_rental/l10n/app_localizations.dart';

import '../../domain/entities/reservation.dart';
import '../bloc/reservation_detail_bloc.dart';

class ReservationDetailScreen extends StatefulWidget {
  final String reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  late final ReservationDetailBloc _bloc;

  final _currencyFormat = NumberFormat.currency(
    locale: 'bg_BG',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _bloc = sl<ReservationDetailBloc>();
    _bloc.add(LoadReservationDetail(widget.reservationId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ReservationDetailBloc, ReservationDetailState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.reservation_detail_title),
              actions: [
                if (state is ReservationDetailLoaded) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _navigateToEdit(
                        context, state.reservation.id),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(context, value, state, l10n),
                    itemBuilder: (context) => [
                      if (state.reservation.paymentStatus != 'paid')
                        PopupMenuItem(
                          value: 'mark_paid',
                          child: Row(
                            children: [
                              const Icon(Icons.payment,
                                  size: 20, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text(l10n.reservation_detail_mark_paid),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(
                              l10n.reservation_detail_delete,
                              style:
                                  const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            body: _buildBody(context, state, l10n),
          );
        },
      ),
    );
  }

  void _handleStateChanges(
      BuildContext context, ReservationDetailState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ReservationDetailLoaded) {
      if (state.markedPaidSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reservation_detail_marked_paid),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (state.deleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.edit_reservation_deleted),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
      if (state.error != null && !state.isMarkingPaid && !state.isDeleting) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error_generic),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleMenuAction(BuildContext context, String action,
      ReservationDetailLoaded state, AppLocalizations l10n) {
    switch (action) {
      case 'mark_paid':
        _bloc.add(const MarkAsPaid());
        break;
      case 'delete':
        _showDeleteConfirmation(context, l10n);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.edit_reservation_delete_confirm_title),
        content: Text(l10n.edit_reservation_delete_confirm_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.edit_reservation_delete_confirm_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _bloc.add(const DeleteReservationDetail());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.edit_reservation_delete_confirm_delete),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context, String id) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.editReservation,
      arguments: id,
    );
    if (result == true && mounted) {
      _bloc.add(LoadReservationDetail(widget.reservationId));
    }
  }

  Widget _buildBody(BuildContext context, ReservationDetailState state,
      AppLocalizations l10n) {
    if (state is ReservationDetailLoading) {
      return const LoadingIndicator();
    }

    if (state is ReservationDetailError) {
      return ErrorStateWidget(
        message: l10n.reservation_detail_error_load,
        buttonText: l10n.action_retry,
        onRetry: () =>
            _bloc.add(LoadReservationDetail(widget.reservationId)),
      );
    }

    if (state is ReservationDetailLoaded) {
      return _buildContent(context, state.reservation, state, l10n);
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, Reservation reservation,
      ReservationDetailLoaded state, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(LoadReservationDetail(widget.reservationId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGuestSection(context, reservation, l10n),
          const SizedBox(height: 20),
          _buildDatesSection(context, reservation, l10n),
          const SizedBox(height: 20),
          _buildFinancialSection(context, reservation, l10n),
          const SizedBox(height: 20),
          if (reservation.notes != null &&
              reservation.notes!.isNotEmpty) ...[
            _buildNotesSection(context, reservation, l10n),
            const SizedBox(height: 20),
          ],
          if (reservation.activityLog != null &&
              reservation.activityLog!.isNotEmpty)
            _buildActivityLogSection(context, reservation, l10n),
          const SizedBox(height: 24),
          _buildActionButtons(context, reservation, state, l10n),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Guest Section ─────────────────────────────────────────────────

  Widget _buildGuestSection(
      BuildContext context, Reservation reservation, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _getInitials(reservation.guestName ?? ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.guestName ?? '',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusBadgeForReservation(
                              reservation.status, l10n),
                          const SizedBox(width: 8),
                          _buildPaymentBadge(
                              reservation.paymentStatus, l10n),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reservation.guestPhone != null ||
                reservation.guestEmail != null) ...[
              const Divider(height: 24),
              if (reservation.guestPhone != null)
                _buildContactRow(
                  icon: Icons.phone_outlined,
                  text: reservation.guestPhone!,
                  onTap: () => _launchUrl('tel:${reservation.guestPhone}'),
                ),
              if (reservation.guestEmail != null) ...[
                const SizedBox(height: 8),
                _buildContactRow(
                  icon: Icons.email_outlined,
                  text: reservation.guestEmail!,
                  onTap: () =>
                      _launchUrl('mailto:${reservation.guestEmail}'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dates Section ─────────────────────────────────────────────────

  Widget _buildDatesSection(
      BuildContext context, Reservation reservation, AppLocalizations l10n) {
    final checkIn = DateTime.tryParse(reservation.checkInDate);
    final checkOut = DateTime.tryParse(reservation.checkOutDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reservation_detail_dates,
                style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            _buildDetailRow(
              l10n.reservation_detail_check_in,
              checkIn != null ? _formatDate(checkIn) : reservation.checkInDate,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              l10n.reservation_detail_check_out,
              checkOut != null
                  ? _formatDate(checkOut)
                  : reservation.checkOutDate,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              l10n.reservation_detail_nights,
              '${reservation.numNights}',
            ),
          ],
        ),
      ),
    );
  }

  // ── Financial Section ─────────────────────────────────────────────

  Widget _buildFinancialSection(
      BuildContext context, Reservation reservation, AppLocalizations l10n) {
    final remaining = reservation.amountRemaining;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reservation_detail_financial,
                style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            _buildDetailRow(
              l10n.reservation_detail_price_per_night,
              '${_formatCents(reservation.pricePerNight)} BGN',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              l10n.reservation_detail_total_price,
              '${_formatCents(reservation.totalPrice)} BGN',
              valueStyle: AppTextStyles.titleMedium,
            ),
            if (reservation.depositAmount > 0) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                l10n.reservation_detail_deposit,
                '${_formatCents(reservation.depositAmount)} BGN'
                '${reservation.depositReceived ? ' \u2713' : ''}',
                valueStyle: AppTextStyles.bodyMedium.copyWith(
                  color: reservation.depositReceived
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
            const Divider(height: 24),
            _buildDetailRow(
              l10n.reservation_detail_amount_paid,
              '${_formatCents(reservation.amountPaid)} BGN',
              valueStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              l10n.reservation_detail_amount_remaining,
              '${_formatCents(remaining)} BGN',
              valueStyle: AppTextStyles.titleMedium.copyWith(
                color: remaining > 0 ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notes Section ─────────────────────────────────────────────────

  Widget _buildNotesSection(
      BuildContext context, Reservation reservation, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reservation_detail_notes,
                style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              reservation.notes ?? l10n.reservation_detail_no_notes,
              style: AppTextStyles.bodyMedium.copyWith(
                color: reservation.notes != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Activity Log Section ──────────────────────────────────────────

  Widget _buildActivityLogSection(
      BuildContext context, Reservation reservation, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reservation_detail_activity,
                style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            ...reservation.activityLog!.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(entry.createdAt.toLocal()),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, Reservation reservation,
      ReservationDetailLoaded state, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEdit(context, reservation.id),
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.reservation_detail_edit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (reservation.paymentStatus != 'paid') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: state.isMarkingPaid
                  ? null
                  : () => _bloc.add(const MarkAsPaid()),
              icon: state.isMarkingPaid
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payment),
              label: Text(l10n.reservation_detail_mark_paid),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: state.isDeleting
                ? null
                : () => _showDeleteConfirmation(context, l10n),
            icon: state.isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(l10n.reservation_detail_delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        )),
        Text(value, style: valueStyle ?? AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildStatusBadgeForReservation(
      String status, AppLocalizations l10n) {
    switch (status) {
      case 'confirmed':
        return StatusBadge.confirmed(l10n.status_confirmed);
      case 'pending':
        return StatusBadge.pending(l10n.status_pending);
      case 'cancelled':
        return StatusBadge.cancelled(l10n.status_cancelled);
      default:
        return StatusBadge(
          label: status,
          backgroundColor: AppColors.textSecondary,
        );
    }
  }

  Widget _buildPaymentBadge(String paymentStatus, AppLocalizations l10n) {
    switch (paymentStatus) {
      case 'paid':
        return StatusBadge.paid(l10n.payment_paid);
      case 'partially_paid':
        return StatusBadge.partiallyPaid(l10n.payment_partially_paid);
      case 'unpaid':
        return StatusBadge.unpaid(l10n.payment_unpaid);
      default:
        return StatusBadge(
          label: paymentStatus,
          backgroundColor: AppColors.textSecondary,
        );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _formatCents(int cents) {
    return _currencyFormat.format(cents / 100);
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
