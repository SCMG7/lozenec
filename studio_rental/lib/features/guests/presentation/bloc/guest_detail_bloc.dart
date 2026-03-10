import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/guest_detail.dart';
import '../../domain/repositories/guest_repository.dart';

// --- Events ---

abstract class GuestDetailEvent extends Equatable {
  const GuestDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGuestDetail extends GuestDetailEvent {
  final String id;

  const LoadGuestDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteGuest extends GuestDetailEvent {
  const DeleteGuest();
}

// --- States ---

abstract class GuestDetailState extends Equatable {
  const GuestDetailState();

  @override
  List<Object?> get props => [];
}

class GuestDetailInitial extends GuestDetailState {
  const GuestDetailInitial();
}

class GuestDetailLoading extends GuestDetailState {
  const GuestDetailLoading();
}

class GuestDetailLoaded extends GuestDetailState {
  final GuestDetail detail;

  const GuestDetailLoaded({required this.detail});

  @override
  List<Object?> get props => [detail];
}

class GuestDetailError extends GuestDetailState {
  final String message;

  const GuestDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GuestDeleted extends GuestDetailState {
  const GuestDeleted();
}

// --- BLoC ---

class GuestDetailBloc extends Bloc<GuestDetailEvent, GuestDetailState> {
  final GuestRepository guestRepository;
  String? _guestId;

  GuestDetailBloc({required this.guestRepository})
      : super(const GuestDetailInitial()) {
    on<LoadGuestDetail>(_onLoadGuestDetail);
    on<DeleteGuest>(_onDeleteGuest);
  }

  Future<void> _onLoadGuestDetail(
      LoadGuestDetail event, Emitter<GuestDetailState> emit) async {
    _guestId = event.id;
    emit(const GuestDetailLoading());
    try {
      final detail = await guestRepository.getGuest(event.id);
      emit(GuestDetailLoaded(detail: detail));
    } on DioException catch (e) {
      emit(GuestDetailError(message: _extractErrorMessage(e)));
    } catch (_) {
      emit(const GuestDetailError(message: 'network_error'));
    }
  }

  Future<void> _onDeleteGuest(
      DeleteGuest event, Emitter<GuestDetailState> emit) async {
    if (_guestId == null) return;
    emit(const GuestDetailLoading());
    try {
      await guestRepository.deleteGuest(_guestId!);
      emit(const GuestDeleted());
    } on DioException catch (e) {
      final currentState = state;
      if (currentState is GuestDetailLoaded) {
        emit(GuestDetailError(message: _extractErrorMessage(e)));
      } else {
        emit(GuestDetailError(message: _extractErrorMessage(e)));
      }
    } catch (_) {
      emit(const GuestDetailError(message: 'network_error'));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'network_error';
    }
    return 'unknown_error';
  }
}
