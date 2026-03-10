import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String? reservationId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? scheduledAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.reservationId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.scheduledAt,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? reservationId,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? scheduledAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reservationId: reservationId ?? this.reservationId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        reservationId,
        type,
        title,
        body,
        isRead,
        scheduledAt,
        createdAt,
      ];
}
