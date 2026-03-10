import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/calendar_reservation.dart';
import '../../domain/entities/month_summary.dart';
import '../../domain/repositories/calendar_repository.dart';

// Events
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonth extends CalendarEvent {
  final DateTime month;

  const LoadMonth({required this.month});

  @override
  List<Object?> get props => [month];
}

class NextMonth extends CalendarEvent {
  const NextMonth();
}

class PreviousMonth extends CalendarEvent {
  const PreviousMonth();
}

class GoToToday extends CalendarEvent {
  const GoToToday();
}

// States
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  final DateTime? currentMonth;

  const CalendarLoading({this.currentMonth});

  @override
  List<Object?> get props => [currentMonth];
}

class CalendarLoaded extends CalendarState {
  final List<CalendarReservation> reservations;
  final MonthSummary summary;
  final DateTime currentMonth;

  const CalendarLoaded({
    required this.reservations,
    required this.summary,
    required this.currentMonth,
  });

  @override
  List<Object?> get props => [reservations, summary, currentMonth];
}

class CalendarError extends CalendarState {
  final String message;
  final DateTime? currentMonth;

  const CalendarError({required this.message, this.currentMonth});

  @override
  List<Object?> get props => [message, currentMonth];
}

// Bloc
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository calendarRepository;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  CalendarBloc({required this.calendarRepository})
      : super(const CalendarInitial()) {
    on<LoadMonth>(_onLoadMonth);
    on<NextMonth>(_onNextMonth);
    on<PreviousMonth>(_onPreviousMonth);
    on<GoToToday>(_onGoToToday);
  }

  String _formatYearMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _onLoadMonth(
    LoadMonth event,
    Emitter<CalendarState> emit,
  ) async {
    _currentMonth = DateTime(event.month.year, event.month.month);
    emit(CalendarLoading(currentMonth: _currentMonth));
    try {
      final data = await calendarRepository
          .getCalendarMonth(_formatYearMonth(_currentMonth));
      emit(CalendarLoaded(
        reservations: data.reservations,
        summary: data.summary,
        currentMonth: _currentMonth,
      ));
    } catch (e) {
      emit(CalendarError(
          message: e.toString(), currentMonth: _currentMonth));
    }
  }

  Future<void> _onNextMonth(
    NextMonth event,
    Emitter<CalendarState> emit,
  ) async {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    add(LoadMonth(month: next));
  }

  Future<void> _onPreviousMonth(
    PreviousMonth event,
    Emitter<CalendarState> emit,
  ) async {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    add(LoadMonth(month: prev));
  }

  Future<void> _onGoToToday(
    GoToToday event,
    Emitter<CalendarState> emit,
  ) async {
    final now = DateTime.now();
    add(LoadMonth(month: DateTime(now.year, now.month)));
  }
}
