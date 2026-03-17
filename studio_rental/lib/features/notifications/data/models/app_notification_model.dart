import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.userId,
    super.reservationId,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    super.scheduledAt,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    // Extract reservationId from the nested data JSON blob if present
    String? reservationId;
    if (json['data'] is Map<String, dynamic>) {
      reservationId =
          (json['data'] as Map<String, dynamic>)['reservationId'] as String?;
    }
    reservationId ??= json['reservation_id'] as String? ??
        json['reservationId'] as String?;

    return AppNotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ??
          json['userId'] as String? ??
          '',
      reservationId: reservationId,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ??
          json['isRead'] as bool? ??
          false,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : json['scheduledAt'] != null
              ? DateTime.parse(json['scheduledAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reservationId': reservationId,
      'type': type,
      'title': title,
      'body': body,
      'isRead': isRead,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
