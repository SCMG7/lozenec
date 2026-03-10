import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../guests/domain/entities/guest_list_item.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../../guests/domain/repositories/guest_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────

abstract class ReservationFormEvent extends Equatable {
  const ReservationFormEvent();

  @override
  List<Object?> get props => [];
}

class InitForm extends ReservationFormEvent {
  final String? reservationId;
  final String? preselectedDate;

  const InitForm({this.reservationId, this.preselectedDate});

  @override
  List<Object?> get props => [reservationId, preselectedDate];
}

class SelectGuest extends ReservationFormEvent {
  final GuestListItem guest;

  const SelectGuest(this.guest);

  @override
  List<Object?> get props => [guest];
}

class ClearGuest extends ReservationFormEvent {
  const ClearGuest();
}

class SetCheckIn extends ReservationFormEvent {
  final DateTime date;

  const SetCheckIn(this.date);

  @override
  List<Object?> get props => [date];
}

class SetCheckOut extends ReservationFormEvent {
  final DateTime date;

  const SetCheckOut(this.date);

  @override
  List<Object?> get props => [date];
}

class SetNights extends ReservationFormEvent {
  final int nights;

  const SetNights(this.nights);

  @override
  List<Object?> get props => [nights];
}

class SetPricePerNight extends ReservationFormEvent {
  final int priceInCents;

  const SetPricePerNight(this.priceInCents);

  @override
  List<Object?> get props => [priceInCents];
}

class SetTotalPrice extends ReservationFormEvent {
  final int priceInCents;

  const SetTotalPrice(this.priceInCents);

  @override
  List<Object?> get props => [priceInCents];
}

class SetDeposit extends ReservationFormEvent {
  final int depositInCents;

  const SetDeposit(this.depositInCents);

  @override
  List<Object?> get props => [depositInCents];
}

class SetDepositReceived extends ReservationFormEvent {
  final bool received;

  const SetDepositReceived(this.received);

  @override
  List<Object?> get props => [received];
}

class SetStatus extends ReservationFormEvent {
  final String status;

  const SetStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SetPaymentStatus extends ReservationFormEvent {
  final String paymentStatus;

  const SetPaymentStatus(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class SetAmountPaid extends ReservationFormEvent {
  final int amountInCents;

  const SetAmountPaid(this.amountInCents);

  @override
  List<Object?> get props => [amountInCents];
}

class SetNotes extends ReservationFormEvent {
  final String notes;

  const SetNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SetDateMode extends ReservationFormEvent {
  final bool useNightsMode;

  const SetDateMode(this.useNightsMode);

  @override
  List<Object?> get props => [useNightsMode];
}

class SetPricingMode extends ReservationFormEvent {
  final bool usePerNightMode;

  const SetPricingMode(this.usePerNightMode);

  @override
  List<Object?> get props => [usePerNightMode];
}

class SearchGuests extends ReservationFormEvent {
  final String query;

  const SearchGuests(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearGuestSearch extends ReservationFormEvent {
  const ClearGuestSearch();
}

class CheckConflictResult extends ReservationFormEvent {
  final bool hasConflict;

  const CheckConflictResult(this.hasConflict);

  @override
  List<Object?> get props => [hasConflict];
}

class GuestSearchResult extends ReservationFormEvent {
  final List<GuestListItem> guests;

  const GuestSearchResult(this.guests);

  @override
  List<Object?> get props => [guests];
}

class Submit extends ReservationFormEvent {
  const Submit();
}

class DeleteReservation extends ReservationFormEvent {
  const DeleteReservation();
}

// ── State ───────────────────────────────────────────────────────────────

class ReservationFormState extends Equatable {
  final bool isEditMode;
  final String? reservationId;
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final bool hasConflict;
  final bool saveSuccess;
  final bool deleteSuccess;
  final String? serverError;
  final Map<String, String> fieldErrors;

  // Guest
  final GuestListItem? selectedGuest;
  final List<GuestListItem> guestSearchResults;
  final bool isSearchingGuests;

  // Dates
  final bool useNightsMode;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int nights;

  // Pricing
  final bool usePerNightMode;
  final int pricePerNight;
  final int totalPrice;
  final int depositAmount;
  final bool depositReceived;

  // Status
  final String status;
  final String paymentStatus;
  final int amountPaid;

  // Notes
  final String notes;

  const ReservationFormState({
    this.isEditMode = false,
    this.reservationId,
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.hasConflict = false,
    this.saveSuccess = false,
    this.deleteSuccess = false,
    this.serverError,
    this.fieldErrors = const {},
    this.selectedGuest,
    this.guestSearchResults = const [],
    this.isSearchingGuests = false,
    this.useNightsMode = true,
    this.checkInDate,
    this.checkOutDate,
    this.nights = 1,
    this.usePerNightMode = true,
    this.pricePerNight = 0,
    this.totalPrice = 0,
    this.depositAmount = 0,
    this.depositReceived = false,
    this.status = 'confirmed',
    this.paymentStatus = 'unpaid',
    this.amountPaid = 0,
    this.notes = '',
  });

  ReservationFormState copyWith({
    bool? isEditMode,
    String? reservationId,
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    bool? hasConflict,
    bool? saveSuccess,
    bool? deleteSuccess,
    String? serverError,
    bool clearServerError = false,
    Map<String, String>? fieldErrors,
    GuestListItem? selectedGuest,
    bool clearGuest = false,
    List<GuestListItem>? guestSearchResults,
    bool? isSearchingGuests,
    bool? useNightsMode,
    DateTime? checkInDate,
    bool clearCheckIn = false,
    DateTime? checkOutDate,
    bool clearCheckOut = false,
    int? nights,
    bool? usePerNightMode,
    int? pricePerNight,
    int? totalPrice,
    int? depositAmount,
    bool? depositReceived,
    String? status,
    String? paymentStatus,
    int? amountPaid,
    String? notes,
  }) {
    return ReservationFormState(
      isEditMode: isEditMode ?? this.isEditMode,
      reservationId: reservationId ?? this.reservationId,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      hasConflict: hasConflict ?? this.hasConflict,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
      serverError: clearServerError ? null : (serverError ?? this.serverError),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      selectedGuest:
          clearGuest ? null : (selectedGuest ?? this.selectedGuest),
      guestSearchResults: guestSearchResults ?? this.guestSearchResults,
      isSearchingGuests: isSearchingGuests ?? this.isSearchingGuests,
      useNightsMode: useNightsMode ?? this.useNightsMode,
      checkInDate:
          clearCheckIn ? null : (checkInDate ?? this.checkInDate),
      checkOutDate:
          clearCheckOut ? null : (checkOutDate ?? this.checkOutDate),
      nights: nights ?? this.nights,
      usePerNightMode: usePerNightMode ?? this.usePerNightMode,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      totalPrice: totalPrice ?? this.totalPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      depositReceived: depositReceived ?? this.depositReceived,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        isEditMode,
        reservationId,
        isLoading,
        isSaving,
        isDeleting,
        hasConflict,
        saveSuccess,
        deleteSuccess,
        serverError,
        fieldErrors,
        selectedGuest,
        guestSearchResults,
        isSearchingGuests,
        useNightsMode,
        checkInDate,
        checkOutDate,
        nights,
        usePerNightMode,
        pricePerNight,
        totalPrice,
        depositAmount,
        depositReceived,
        status,
        paymentStatus,
        amountPaid,
        notes,
      ];
}

// ── BLoC ────────────────────────────────────────────────────────────────

class ReservationFormBloc
    extends Bloc<ReservationFormEvent, ReservationFormState> {
  final ReservationRepository reservationRepository;
  final GuestRepository guestRepository;

  Timer? _searchDebounce;
  Timer? _conflictDebounce;

  ReservationFormBloc({
    required this.reservationRepository,
    required this.guestRepository,
  }) : super(const ReservationFormState()) {
    on<InitForm>(_onInitForm);
    on<SelectGuest>(_onSelectGuest);
    on<ClearGuest>(_onClearGuest);
    on<SetCheckIn>(_onSetCheckIn);
    on<SetCheckOut>(_onSetCheckOut);
    on<SetNights>(_onSetNights);
    on<SetPricePerNight>(_onSetPricePerNight);
    on<SetTotalPrice>(_onSetTotalPrice);
    on<SetDeposit>(_onSetDeposit);
    on<SetDepositReceived>(_onSetDepositReceived);
    on<SetStatus>(_onSetStatus);
    on<SetPaymentStatus>(_onSetPaymentStatus);
    on<SetAmountPaid>(_onSetAmountPaid);
    on<SetNotes>(_onSetNotes);
    on<SetDateMode>(_onSetDateMode);
    on<SetPricingMode>(_onSetPricingMode);
    on<SearchGuests>(_onSearchGuests);
    on<ClearGuestSearch>(_onClearGuestSearch);
    on<CheckConflictResult>(_onCheckConflictResult);
    on<GuestSearchResult>(_onGuestSearchResult);
    on<Submit>(_onSubmit);
    on<DeleteReservation>(_onDeleteReservation);
  }

  // ── Event Handlers ────────────────────────────────────────────────

  Future<void> _onInitForm(
      InitForm event, Emitter<ReservationFormState> emit) async {
    if (event.reservationId != null) {
      emit(state.copyWith(
        isLoading: true,
        isEditMode: true,
        reservationId: event.reservationId,
      ));
      try {
        final reservation =
            await reservationRepository.getReservation(event.reservationId!);

        GuestListItem? guestItem;
        if (reservation.guestId.isNotEmpty) {
          try {
            final guestDetail =
                await guestRepository.getGuest(reservation.guestId);
            guestItem = GuestListItem(
              id: guestDetail.id,
              firstName: guestDetail.firstName,
              lastName: guestDetail.lastName,
              phone: guestDetail.phone,
              email: guestDetail.email,
              totalStays: guestDetail.totalStays,
              hasUpcoming: false,
            );
          } catch (_) {
            if (reservation.guestName != null) {
              final parts = reservation.guestName!.split(' ');
              guestItem = GuestListItem(
                id: reservation.guestId,
                firstName: parts.first,
                lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
                phone: reservation.guestPhone,
                email: reservation.guestEmail,
                totalStays: 0,
                hasUpcoming: false,
              );
            }
          }
        }

        final checkIn = DateTime.tryParse(reservation.checkInDate);
        final checkOut = DateTime.tryParse(reservation.checkOutDate);

        emit(state.copyWith(
          isLoading: false,
          isEditMode: true,
          reservationId: reservation.id,
          selectedGuest: guestItem,
          checkInDate: checkIn,
          checkOutDate: checkOut,
          nights: reservation.numNights,
          pricePerNight: reservation.pricePerNight,
          totalPrice: reservation.totalPrice,
          depositAmount: reservation.depositAmount,
          depositReceived: reservation.depositReceived,
          status: reservation.status,
          paymentStatus: reservation.paymentStatus,
          amountPaid: reservation.amountPaid,
          notes: reservation.notes ?? '',
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, serverError: e.toString()));
      }
    } else {
      DateTime? preselectedCheckIn;
      if (event.preselectedDate != null) {
        preselectedCheckIn = DateTime.tryParse(event.preselectedDate!);
      }
      if (preselectedCheckIn != null) {
        emit(state.copyWith(
          isEditMode: false,
          checkInDate: preselectedCheckIn,
          checkOutDate: preselectedCheckIn.add(const Duration(days: 1)),
        ));
      }
    }
  }

  void _onSelectGuest(SelectGuest event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(
      selectedGuest: event.guest,
      guestSearchResults: const [],
      fieldErrors: Map.from(state.fieldErrors)..remove('guest'),
    ));
  }

  void _onClearGuest(ClearGuest event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(clearGuest: true));
  }

  void _onSetCheckIn(SetCheckIn event, Emitter<ReservationFormState> emit) {
    DateTime? checkOut = state.checkOutDate;
    int nights = state.nights;

    if (state.useNightsMode) {
      checkOut = event.date.add(Duration(days: nights));
    } else if (checkOut != null && !checkOut.isAfter(event.date)) {
      checkOut = event.date.add(const Duration(days: 1));
      nights = 1;
    } else if (checkOut != null) {
      nights = checkOut.difference(event.date).inDays;
      if (nights < 1) nights = 1;
    }

    final updatedErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('checkIn');

    emit(state.copyWith(
      checkInDate: event.date,
      checkOutDate: checkOut,
      nights: nights,
      totalPrice: state.usePerNightMode
          ? state.pricePerNight * nights
          : state.totalPrice,
      fieldErrors: updatedErrors,
      hasConflict: false,
    ));

    _debouncedConflictCheck();
  }

  void _onSetCheckOut(SetCheckOut event, Emitter<ReservationFormState> emit) {
    if (state.checkInDate == null) return;

    int nights = event.date.difference(state.checkInDate!).inDays;
    if (nights < 1) nights = 1;

    emit(state.copyWith(
      checkOutDate: event.date,
      nights: nights,
      totalPrice: state.usePerNightMode
          ? state.pricePerNight * nights
          : state.totalPrice,
      hasConflict: false,
    ));

    _debouncedConflictCheck();
  }

  void _onSetNights(SetNights event, Emitter<ReservationFormState> emit) {
    final nights = event.nights < 1 ? 1 : event.nights;
    DateTime? checkOut;

    if (state.checkInDate != null) {
      checkOut = state.checkInDate!.add(Duration(days: nights));
    }

    emit(state.copyWith(
      nights: nights,
      checkOutDate: checkOut,
      totalPrice: state.usePerNightMode
          ? state.pricePerNight * nights
          : state.totalPrice,
      hasConflict: false,
    ));

    _debouncedConflictCheck();
  }

  void _onSetPricePerNight(
      SetPricePerNight event, Emitter<ReservationFormState> emit) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('price');

    emit(state.copyWith(
      pricePerNight: event.priceInCents,
      totalPrice: state.usePerNightMode
          ? event.priceInCents * state.nights
          : state.totalPrice,
      fieldErrors: updatedErrors,
    ));
  }

  void _onSetTotalPrice(
      SetTotalPrice event, Emitter<ReservationFormState> emit) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('price');

    emit(state.copyWith(
      totalPrice: event.priceInCents,
      pricePerNight: state.nights > 0
          ? (event.priceInCents / state.nights).round()
          : event.priceInCents,
      fieldErrors: updatedErrors,
    ));
  }

  void _onSetDeposit(SetDeposit event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(depositAmount: event.depositInCents));
  }

  void _onSetDepositReceived(
      SetDepositReceived event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(depositReceived: event.received));
  }

  void _onSetStatus(SetStatus event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(status: event.status));
  }

  void _onSetPaymentStatus(
      SetPaymentStatus event, Emitter<ReservationFormState> emit) {
    int amountPaid = state.amountPaid;
    if (event.paymentStatus == 'paid') {
      amountPaid = state.totalPrice;
    } else if (event.paymentStatus == 'unpaid') {
      amountPaid = 0;
    }
    emit(state.copyWith(
      paymentStatus: event.paymentStatus,
      amountPaid: amountPaid,
    ));
  }

  void _onSetAmountPaid(
      SetAmountPaid event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(amountPaid: event.amountInCents));
  }

  void _onSetNotes(SetNotes event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onSetDateMode(SetDateMode event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(useNightsMode: event.useNightsMode));
  }

  void _onSetPricingMode(
      SetPricingMode event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(usePerNightMode: event.usePerNightMode));
  }

  Future<void> _onSearchGuests(
      SearchGuests event, Emitter<ReservationFormState> emit) async {
    if (event.query.length < 2) {
      emit(state.copyWith(
        guestSearchResults: const [],
        isSearchingGuests: false,
      ));
      return;
    }

    emit(state.copyWith(isSearchingGuests: true));

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final guests = await guestRepository.searchGuests(event.query);
        if (!isClosed) {
          add(GuestSearchResult(guests));
        }
      } catch (_) {
        if (!isClosed) {
          add(const GuestSearchResult([]));
        }
      }
    });
  }

  void _onGuestSearchResult(
      GuestSearchResult event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(
      guestSearchResults: event.guests,
      isSearchingGuests: false,
    ));
  }

  void _onClearGuestSearch(
      ClearGuestSearch event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(
      guestSearchResults: const [],
      isSearchingGuests: false,
    ));
  }

  void _onCheckConflictResult(
      CheckConflictResult event, Emitter<ReservationFormState> emit) {
    emit(state.copyWith(hasConflict: event.hasConflict));
  }

  Future<void> _onSubmit(
      Submit event, Emitter<ReservationFormState> emit) async {
    final errors = <String, String>{};
    if (state.selectedGuest == null) {
      errors['guest'] = 'guest_required';
    }
    if (state.checkInDate == null) {
      errors['checkIn'] = 'date_required';
    }
    if (state.totalPrice <= 0 && state.pricePerNight <= 0) {
      errors['price'] = 'price_required';
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    emit(state.copyWith(
      isSaving: true,
      clearServerError: true,
      fieldErrors: const {},
    ));

    try {
      final checkInIso =
          state.checkInDate!.toIso8601String().split('T').first;
      final checkOutDate = state.checkOutDate ??
          state.checkInDate!.add(Duration(days: state.nights));
      final checkOutIso = checkOutDate.toIso8601String().split('T').first;

      final data = <String, dynamic>{
        'guest_id': state.selectedGuest!.id,
        'check_in_date': checkInIso,
        'check_out_date': checkOutIso,
        'num_nights': state.nights,
        'price_per_night': state.pricePerNight,
        'total_price': state.totalPrice,
        'deposit_amount': state.depositAmount,
        'deposit_received': state.depositReceived,
        'status': state.status,
        'payment_status': state.paymentStatus,
        'amount_paid': state.amountPaid,
        'notes': state.notes.isNotEmpty ? state.notes : null,
      };

      if (state.isEditMode && state.reservationId != null) {
        await reservationRepository.updateReservation(
            state.reservationId!, data);
      } else {
        await reservationRepository.createReservation(data);
      }

      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('409') ||
          errorMsg.toLowerCase().contains('conflict')) {
        emit(state.copyWith(
          isSaving: false,
          hasConflict: true,
          serverError: errorMsg,
        ));
      } else {
        emit(state.copyWith(isSaving: false, serverError: errorMsg));
      }
    }
  }

  Future<void> _onDeleteReservation(
      DeleteReservation event, Emitter<ReservationFormState> emit) async {
    if (state.reservationId == null) return;

    emit(state.copyWith(isDeleting: true, clearServerError: true));

    try {
      await reservationRepository.deleteReservation(state.reservationId!);
      emit(state.copyWith(isDeleting: false, deleteSuccess: true));
    } catch (e) {
      emit(state.copyWith(isDeleting: false, serverError: e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  void _debouncedConflictCheck() {
    _conflictDebounce?.cancel();
    _conflictDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (state.checkInDate == null) return;

      final checkInIso =
          state.checkInDate!.toIso8601String().split('T').first;
      final checkOutDate = state.checkOutDate ??
          state.checkInDate!.add(Duration(days: state.nights));
      final checkOutIso = checkOutDate.toIso8601String().split('T').first;

      try {
        final hasConflict = await reservationRepository.checkConflict(
          checkInDate: checkInIso,
          checkOutDate: checkOutIso,
          excludeId: state.reservationId,
        );
        if (!isClosed) {
          add(CheckConflictResult(hasConflict));
        }
      } catch (_) {
        // Silently ignore conflict check errors
      }
    });
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _conflictDebounce?.cancel();
    return super.close();
  }
}
