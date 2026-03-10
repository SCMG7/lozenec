import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/core/widgets/status_badge.dart';
import '../../domain/entities/guest_detail.dart';
import '../../domain/entities/guest_reservation.dart';
import '../bloc/guest_detail_bloc.dart';
import '../widgets/guest_avatar.dart';

class GuestDetailScreen extends StatefulWidget {
  final String guestId;

  const GuestDetailScreen({super.key, required this.guestId});

  @override
  State<GuestDetailScreen> createState() => _GuestDetailScreenState();
}

class _GuestDetailScreenState extends State<GuestDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<GuestDetailBloc>()
        .add(LoadGuestDetail(id: widget.guestId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<GuestDetailBloc, GuestDetailState>(
      listener: (context, state) {
        if (state is GuestDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.guest_detail_deleted)),
          );
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is GuestDetailLoaded
                  ? state.detail.fullName
                  : l10n.guest_list_title,
            ),
            actions: [
              if (state is GuestDetailLoaded)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.guest_detail_edit,
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.editGuest,
                      arguments: widget.guestId,
                    );
                    if (result == true && mounted) {
                      context.read<GuestDetailBloc>().add(
                            LoadGuestDetail(id: widget.guestId),
                          );
                    }
                  },
                ),
            ],
          ),
          body: _buildBody(context, state, l10n),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, GuestDetailState state, AppLocalizations l10n) {
    if (state is GuestDetailLoading) {
      return const LoadingIndicator();
    }

    if (state is GuestDetailError) {
      return ErrorStateWidget(
        message: l10n.guest_detail_error_load,
        buttonText: l10n.action_retry,
        onRetry: () {
          context
              .read<GuestDetailBloc>()
              .add(LoadGuestDetail(id: widget.guestId));
        },
      );
    }

    if (state is GuestDetailLoaded) {
      return _buildDetailContent(context, state.detail, l10n);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailContent(
      BuildContext context, GuestDetail detail, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(detail),
          const SizedBox(height: 24),
          _buildContactSection(context, detail, l10n),
          const SizedBox(height: 24),
          _buildStatsRow(detail, l10n),
          const SizedBox(height: 24),
          _buildNotesSection(detail, l10n),
          const SizedBox(height: 24),
          _buildReservationHistory(context, detail, l10n),
          const SizedBox(height: 32),
          _buildDeleteButton(context, l10n),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(GuestDetail detail) {
    return Center(
      child: Column(
        children: [
          GuestAvatar(initials: detail.initials, size: 80),
          const SizedBox(height: 12),
          Text(
            detail.fullName,
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context, GuestDetail detail, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactRow(
              icon: Icons.phone,
              label: l10n.guest_detail_phone,
              value: detail.phone,
              fallback: l10n.guest_detail_not_provided,
              onTap: detail.phone != null && detail.phone!.isNotEmpty
                  ? () => launchUrl(Uri.parse('tel:${detail.phone}'))
                  : null,
            ),
            const Divider(height: 24),
            _buildContactRow(
              icon: Icons.email,
              label: l10n.guest_detail_email,
              value: detail.email,
              fallback: l10n.guest_detail_not_provided,
              onTap: detail.email != null && detail.email!.isNotEmpty
                  ? () => launchUrl(Uri.parse('mailto:${detail.email}'))
                  : null,
            ),
            const Divider(height: 24),
            _buildContactRow(
              icon: Icons.flag,
              label: l10n.guest_detail_nationality,
              value: detail.nationality,
              fallback: l10n.guest_detail_not_provided,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String? value,
    required String fallback,
    VoidCallback? onTap,
  }) {
    final displayValue = (value != null && value.isNotEmpty) ? value : fallback;
    final isPlaceholder = value == null || value.isEmpty;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isPlaceholder
                        ? AppColors.textSecondary
                        : (onTap != null
                            ? AppColors.primary
                            : AppColors.textPrimary),
                    decoration: onTap != null && !isPlaceholder
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null && !isPlaceholder)
            Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatsRow(GuestDetail detail, AppLocalizations l10n) {
    final revenueDisplay = (detail.totalRevenue / 100).toStringAsFixed(2);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: l10n.guest_detail_total_stays,
            value: detail.totalStays.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: l10n.guest_detail_total_nights,
            value: detail.totalNights.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: l10n.guest_detail_total_revenue,
            value: revenueDisplay,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(GuestDetail detail, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.guest_detail_notes, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              detail.notes != null && detail.notes!.isNotEmpty
                  ? detail.notes!
                  : l10n.guest_detail_no_notes,
              style: AppTextStyles.bodyMedium.copyWith(
                color: detail.notes != null && detail.notes!.isNotEmpty
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationHistory(
      BuildContext context, GuestDetail detail, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.guest_detail_reservations,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 8),
        if (detail.reservations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                l10n.guest_detail_no_reservations,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...detail.reservations
              .map((r) => _buildReservationTile(context, r, l10n)),
      ],
    );
  }

  Widget _buildReservationTile(
      BuildContext context, GuestReservation reservation, AppLocalizations l10n) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final priceDisplay = (reservation.totalPrice / 100).toStringAsFixed(2);

    StatusBadge badge;
    switch (reservation.status.toLowerCase()) {
      case 'confirmed':
        badge = StatusBadge.confirmed(l10n.status_confirmed);
      case 'pending':
        badge = StatusBadge.pending(l10n.status_pending);
      case 'cancelled':
        badge = StatusBadge.cancelled(l10n.status_cancelled);
      default:
        badge = StatusBadge(
          label: reservation.status,
          backgroundColor: AppColors.textSecondary,
        );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.reservationDetail,
            arguments: reservation.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateFormat.format(reservation.checkInDate)} – ${dateFormat.format(reservation.checkOutDate)}',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.numNights} ${l10n.bottom_sheet_nights(reservation.numNights)} · $priceDisplay',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              badge,
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteConfirmation(context, l10n),
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        label: Text(
          l10n.guest_detail_delete,
          style: const TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.guest_detail_delete_confirm_title),
        content: Text(l10n.guest_detail_delete_confirm_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.guest_detail_delete_confirm_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GuestDetailBloc>().add(const DeleteGuest());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.guest_detail_delete_confirm_delete),
          ),
        ],
      ),
    );
  }
}
