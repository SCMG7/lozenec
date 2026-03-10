import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    return await remoteDatasource.getNotifications(page: page);
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDatasource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(String id) async {
    await remoteDatasource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDatasource.markAllAsRead();
  }
}
