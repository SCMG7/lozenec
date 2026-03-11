import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_strings.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/core/di/service_locator.dart';
import 'package:studio_rental/l10n/app_localizations.dart';

import '../../../guests/domain/entities/guest_list_item.dart';
import '../bloc/reservation_form_bloc.dart';

class EditReservationScreen extends StatefulWidget {
  final String reservationId;

  const EditReservationScreen({super.key, required this.reservationId});

  @override
  State<EditReservationScreen> createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  late final ReservationFormBloc _bloc;
  final _guestSearchController = TextEditingController();
  final _nightsController = TextEditingController();
  final _pricePerNightController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _depositController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _controllersInitialized = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _bloc = sl<ReservationFormBloc>();
    _bloc.add(InitForm(reservationId: widget.reservationId));
  }

  @override
  void dispose() {
    _guestSearchController.dispose();
    _nightsController.dispose();
    _pricePerNightController.dispose();
    _totalPriceController.dispose();
    _depositController.dispose();
    _amountPaidController.dispose();
    _notesController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _initControllers(ReservationFormState state) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    _nightsController.text = state.nights.toString();
    _pricePerNightController.text = _formatCentsForInput(state.pricePerNight);
    _totalPriceController.text = _formatCentsForInput(state.totalPrice);
    _depositController.text = _formatCentsForInput(state.depositAmount);
    _amountPaidController.text = _formatCentsForInput(state.amountPaid);
    _notesController.text = state.notes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ReservationFormBloc, ReservationFormState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (!state.isLoading && state.isEditMode && !_controllersInitialized) {
            _initControllers(state);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.edit_reservation_title),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: state.isDeleting
                      ? null
                      : () => _showDeleteConfirmation(context, l10n),
                ),
              ],
            ),
            body: state.isLoading
                ? const LoadingIndicator()
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildConflictBanner(context, state, l10n),
                        _buildGuestSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildDatesSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildPricingSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildStatusSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildPaymentSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildNotesSection(context, state, l10n),
                        const SizedBox(height: 32),
                        _buildSaveButton(context, state, l10n),
                        const SizedBox(height: 12),
                        _buildDeleteButton(context, state, l10n),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, ReservationFormState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state.saveSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.edit_reservation_success),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
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

    if (state.serverError != null && !state.isSaving && !state.isDeleting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.add_reservation_error_network),
          backgroundColor: AppColors.error,
        ),
      );
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
              _bloc.add(const DeleteReservation());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.edit_reservation_delete_confirm_delete),
          ),
        ],
      ),
    );
  }

  // ── Guest Section ─────────────────────────────────────────────────

  Widget _buildGuestSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_guest_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        if (state.selectedGuest != null) ...[
          _buildSelectedGuestChip(context, state.selectedGuest!, l10n),
        ] else ...[
          TextField(
            controller: _guestSearchController,
            decoration: InputDecoration(
              hintText: l10n.add_reservation_search_guest,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.isSearchingGuests
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _guestSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _guestSearchController.clear();
                            _bloc.add(const ClearGuestSearch());
                          },
                        )
                      : null,
              border: const OutlineInputBorder(),
              errorText: state.fieldErrors.containsKey('guest')
                  ? l10n.add_reservation_error_guest_required
                  : null,
            ),
            onChanged: (value) {
              _bloc.add(SearchGuests(value));
            },
          ),
          if (state.guestSearchResults.isNotEmpty)
            _buildGuestSearchResults(context, state.guestSearchResults),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context)
                  .pushNamed(AppRoutes.addGuest);
              if (result is GuestListItem && mounted) {
                _bloc.add(SelectGuest(result));
                _guestSearchController.clear();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.add_reservation_create_guest),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedGuestChip(
      BuildContext context, GuestListItem guest, AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            guest.initials,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(guest.fullName, style: AppTextStyles.titleLarge),
        subtitle: guest.phone != null ? Text(guest.phone!) : null,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _bloc.add(const ClearGuest());
            _guestSearchController.clear();
          },
        ),
      ),
    );
  }

  Widget _buildGuestSearchResults(
      BuildContext context, List<GuestListItem> guests) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: guests.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final guest = guests[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                guest.initials,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(guest.fullName, style: AppTextStyles.bodyMedium),
            subtitle: guest.phone != null ? Text(guest.phone!) : null,
            onTap: () {
              _bloc.add(SelectGuest(guest));
              _guestSearchController.clear();
            },
          );
        },
      ),
    );
  }

  // ── Conflict Banner ───────────────────────────────────────────────

  Widget _buildConflictBanner(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    if (!state.hasConflict) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.add_reservation_conflict,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dates Section ─────────────────────────────────────────────────

  Widget _buildDatesSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_dates_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        _buildToggleRow(
          label1: l10n.add_reservation_mode_nights,
          label2: l10n.add_reservation_mode_range,
          isFirstSelected: state.useNightsMode,
          onChanged: (val) => _bloc.add(SetDateMode(val)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context: context,
                label: l10n.add_reservation_check_in,
                value: state.checkInDate,
                error: state.fieldErrors['checkIn'] != null
                    ? l10n.add_reservation_error_date_required
                    : null,
                onTap: () => _pickDate(
                  context,
                  initial: state.checkInDate,
                  onPicked: (date) => _bloc.add(SetCheckIn(date)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (state.useNightsMode)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _nightsController,
                  decoration: InputDecoration(
                    labelText: l10n.add_reservation_nights,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final nights = int.tryParse(value) ?? 1;
                    _bloc.add(SetNights(nights));
                  },
                ),
              )
            else
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: l10n.add_reservation_check_out,
                  value: state.checkOutDate,
                  onTap: () => _pickDate(
                    context,
                    initial: state.checkOutDate,
                    firstDate:
                        state.checkInDate?.add(const Duration(days: 1)),
                    onPicked: (date) => _bloc.add(SetCheckOut(date)),
                  ),
                ),
              ),
          ],
        ),
        if (state.checkInDate != null && state.checkOutDate != null) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.add_reservation_check_in}: ${_formatDate(state.checkInDate!)} - '
            '${l10n.add_reservation_check_out}: ${_formatDate(state.checkOutDate!)} '
            '(${state.nights} ${l10n.add_reservation_nights.toLowerCase()})',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }

  // ── Pricing Section ───────────────────────────────────────────────

  Widget _buildPricingSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_pricing_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        _buildToggleRow(
          label1: l10n.add_reservation_mode_per_night,
          label2: l10n.add_reservation_mode_custom_total,
          isFirstSelected: state.usePerNightMode,
          onChanged: (val) => _bloc.add(SetPricingMode(val)),
        ),
        const SizedBox(height: 12),
        if (state.usePerNightMode) ...[
          TextField(
            controller: _pricePerNightController,
            decoration: InputDecoration(
              labelText: l10n.add_reservation_price_per_night,
              border: const OutlineInputBorder(),
              suffixText: AppStrings.currencySymbol,
              errorText: state.fieldErrors.containsKey('price')
                  ? l10n.add_reservation_error_price_positive
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final amount = _parseCurrency(value);
              _bloc.add(SetPricePerNight(amount));
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.add_reservation_total_price}: ${_formatCents(state.totalPrice)} ${AppStrings.currencySymbol}',
            style: AppTextStyles.titleMedium,
          ),
        ] else ...[
          TextField(
            controller: _totalPriceController,
            decoration: InputDecoration(
              labelText: l10n.add_reservation_total_price,
              border: const OutlineInputBorder(),
              suffixText: AppStrings.currencySymbol,
              errorText: state.fieldErrors.containsKey('price')
                  ? l10n.add_reservation_error_price_positive
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final amount = _parseCurrency(value);
              _bloc.add(SetTotalPrice(amount));
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.add_reservation_price_per_night}: ${_formatCents(state.pricePerNight)} ${AppStrings.currencySymbol}',
            style: AppTextStyles.bodySmall,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _depositController,
          decoration: InputDecoration(
            labelText: l10n.add_reservation_deposit,
            border: const OutlineInputBorder(),
            suffixText: AppStrings.currencySymbol,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            final amount = _parseCurrency(value);
            _bloc.add(SetDeposit(amount));
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.add_reservation_deposit_received),
          value: state.depositReceived,
          onChanged: (val) => _bloc.add(SetDepositReceived(val)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // ── Status Section ────────────────────────────────────────────────

  Widget _buildStatusSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_status_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'confirmed',
              label: Text(l10n.status_confirmed),
            ),
            ButtonSegment(
              value: 'pending',
              label: Text(l10n.status_pending),
            ),
            ButtonSegment(
              value: 'cancelled',
              label: Text(l10n.status_cancelled),
            ),
          ],
          selected: {state.status},
          onSelectionChanged: (values) {
            _bloc.add(SetStatus(values.first));
          },
        ),
      ],
    );
  }

  // ── Payment Section ───────────────────────────────────────────────

  Widget _buildPaymentSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_payment_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: state.paymentStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'unpaid',
              child: Text(l10n.payment_unpaid),
            ),
            DropdownMenuItem(
              value: 'partially_paid',
              child: Text(l10n.payment_partially_paid),
            ),
            DropdownMenuItem(
              value: 'paid',
              child: Text(l10n.payment_paid),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _bloc.add(SetPaymentStatus(value));
            }
          },
        ),
        if (state.paymentStatus == 'partially_paid') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _amountPaidController,
            decoration: InputDecoration(
              labelText: l10n.add_reservation_amount_paid,
              border: const OutlineInputBorder(),
              suffixText: AppStrings.currencySymbol,
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final amount = _parseCurrency(value);
              _bloc.add(SetAmountPaid(amount));
            },
          ),
        ],
      ],
    );
  }

  // ── Notes Section ─────────────────────────────────────────────────

  Widget _buildNotesSection(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.add_reservation_notes_section,
            style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: l10n.add_reservation_notes_hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => _bloc.add(SetNotes(value)),
        ),
      ],
    );
  }

  // ── Save Button ───────────────────────────────────────────────────

  Widget _buildSaveButton(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isSaving || state.hasConflict
            ? null
            : () => _bloc.add(const Submit()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(l10n.edit_reservation_save, style: AppTextStyles.button),
      ),
    );
  }

  // ── Delete Button ─────────────────────────────────────────────────

  Widget _buildDeleteButton(
      BuildContext context, ReservationFormState state, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: state.isDeleting
            ? null
            : () => _showDeleteConfirmation(context, l10n),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: state.isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : Text(l10n.edit_reservation_delete),
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────

  Widget _buildToggleRow({
    required String label1,
    required String label2,
    required bool isFirstSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleOption(
            label: label1,
            isSelected: isFirstSelected,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleOption(
            label: label2,
            isSelected: !isFirstSelected,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    DateTime? value,
    String? error,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: error,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null ? _formatDate(value) : '',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Future<void> _pickDate(
    BuildContext context, {
    DateTime? initial,
    DateTime? firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCents(int cents) {
    return _currencyFormat.format(cents / 100);
  }

  String _formatCentsForInput(int cents) {
    if (cents == 0) return '';
    return (cents / 100).toStringAsFixed(2);
  }

  int _parseCurrency(String value) {
    final cleaned = value.replaceAll(',', '.');
    final parsed = double.tryParse(cleaned) ?? 0;
    return (parsed * 100).round();
  }
}
