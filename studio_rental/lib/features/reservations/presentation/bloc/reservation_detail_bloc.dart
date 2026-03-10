import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────

abstract class ReservationDetailEvent extends Equatable {
  const ReservationDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadReservationDetail extends ReservationDetailEvent {
  final String id;

  const LoadReservationDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAsPaid extends ReservationDetailEvent {
  const MarkAsPaid();
}

class DeleteReservationDetail extends ReservationDetailEvent {
  const DeleteReservationDetail();
}

// ── States ──────────────────────────────────────────────────────────────

abstract class ReservationDetailState extends Equatable {
  const ReservationDetailState();

  @override
  List<Object?> get props => [];
}

class ReservationDetailInitial extends ReservationDetailState {
  const ReservationDetailInitial();
}

class ReservationDetailLoading extends ReservationDetailState {
  const ReservationDetailLoading();
}

class ReservationDetailLoaded extends ReservationDetailState {
  final Reservation reservation;
  final bool isMarkingPaid;
  final bool isDeleting;
  final bool markedPaidSuccess;
  final bool deleteSuccess;
  final String? error;

  const ReservationDetailLoaded({
    required this.reservation,
    this.isMarkingPaid = false,
    this.isDeleting = false,
    this.markedPaidSuccess = false,
    this.deleteSuccess = false,
    this.error,
  });

  ReservationDetailLoaded copyWith({
    Reservation? reservation,
    bool? isMarkingPaid,
    bool? isDeleting,
    bool? markedPaidSuccess,
    bool? deleteSuccess,
    String? error,
    bool clearError = false,
  }) {
    return ReservationDetailLoaded(
      reservation: reservation ?? this.reservation,
      isMarkingPaid: isMarkingPaid ?? this.isMarkingPaid,
      isDeleting: isDeleting ?? this.isDeleting,
      markedPaidSuccess: markedPaidSuccess ?? this.markedPaidSuccess,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        reservation,
        isMarkingPaid,
        isDeleting,
        markedPaidSuccess,
        deleteSuccess,
        error,
      ];
}

class ReservationDetailError extends ReservationDetailState {
  final String message;

  const ReservationDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────────────────────────────────

class ReservationDetailBloc
    extends Bloc<ReservationDetailEvent, ReservationDetailState> {
  final ReservationRepository reservationRepository;

  ReservationDetailBloc({required this.reservationRepository})
      : super(const ReservationDetailInitial()) {
    on<LoadReservationDetail>(_onLoad);
    on<MarkAsPaid>(_onMarkAsPaid);
    on<DeleteReservationDetail>(_onDelete);
  }

  Future<void> _onLoad(
      LoadReservationDetail event, Emitter<ReservationDetailState> emit) async {
    emit(const ReservationDetailLoading());

    try {
      final reservation =
          await reservationRepository.getReservation(event.id);
      emit(ReservationDetailLoaded(reservation: reservation));
    } catch (e) {
      emit(ReservationDetailError(e.toString()));
    }
  }

  Future<void> _onMarkAsPaid(
      MarkAsPaid event, Emitter<ReservationDetailState> emit) async {
    final currentState = state;
    if (currentState is! ReservationDetailLoaded) return;

    emit(currentState.copyWith(isMarkingPaid: true, clearError: true));

    try {
      final updated =
          await reservationRepository.markAsPaid(currentState.reservation.id);
      emit(currentState.copyWith(
        reservation: updated,
        isMarkingPaid: false,
        markedPaidSuccess: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isMarkingPaid: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteReservationDetail event, Emitter<ReservationDetailState> emit) async {
    final currentState = state;
    if (currentState is! ReservationDetailLoaded) return;

    emit(currentState.copyWith(isDeleting: true, clearError: true));

    try {
      await reservationRepository
          .deleteReservation(currentState.reservation.id);
      emit(currentState.copyWith(
        isDeleting: false,
        deleteSuccess: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isDeleting: false,
        error: e.toString(),
      ));
    }
  }
}
