part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

class RefreshNotifications extends NotificationsEvent {
  const RefreshNotifications();
}

class MarkAsRead extends NotificationsEvent {
  final String id;

  const MarkAsRead({required this.id});

  @override
  List<Object?> get props => [id];
}

class MarkAllAsRead extends NotificationsEvent {
  const MarkAllAsRead();
}
