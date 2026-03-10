import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AnalyticsBloc({required this.analyticsRepository})
      : super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await analyticsRepository.getAnalytics(
        period: 'this_month',
      );
      emit(AnalyticsLoaded(data: data, period: 'this_month'));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AnalyticsError(message: message));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await analyticsRepository.getAnalytics(
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AnalyticsLoaded(data: data, period: event.period));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AnalyticsError(message: message));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
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
