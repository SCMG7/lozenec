import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository notificationRepository;

  NotificationsBloc({required this.notificationRepository})
      : super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final notifications = await notificationRepository.getNotifications();
      final unreadCount = await notificationRepository.getUnreadCount();
      emit(state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isLoading: false, error: message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final notifications = await notificationRepository.getNotifications();
      final unreadCount = await notificationRepository.getUnreadCount();
      emit(state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        error: null,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(error: message));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await notificationRepository.markAsRead(event.id);
      final updatedList = state.notifications.map((n) {
        if (n.id == event.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final newUnread = updatedList.where((n) => !n.isRead).length;
      emit(state.copyWith(
        notifications: updatedList,
        unreadCount: newUnread,
      ));
    } catch (_) {
      // Silently fail on mark-as-read; will sync on next refresh
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await notificationRepository.markAllAsRead();
      final updatedList = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(state.copyWith(
        notifications: updatedList,
        unreadCount: 0,
      ));
    } catch (_) {
      // Silently fail; will sync on next refresh
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
