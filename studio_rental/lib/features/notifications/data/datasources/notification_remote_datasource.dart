import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import '../models/app_notification_model.dart';

class NotificationRemoteDatasource {
  final ApiClient apiClient;

  NotificationRemoteDatasource({required this.apiClient});

  Future<List<AppNotificationModel>> getNotifications({int page = 1}) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await apiClient.dio.get(
      ApiEndpoints.notificationsUnreadCount,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['count'] as num).toInt();
  }

  Future<void> markAsRead(String id) async {
    await apiClient.dio.put(ApiEndpoints.notificationMarkRead(id));
  }

  Future<void> markAllAsRead() async {
    await apiClient.dio.put(ApiEndpoints.notificationsMarkAllRead);
  }
}
