import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_local_data_source.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;

  const NotificationRepositoryImpl({
    required NotificationLocalDataSource
    localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Stream<List<NotificationEntity>>
  watchNotifications() {
    return _localDataSource
        .watchNotifications()
        .map((notifications) {
      return List<NotificationEntity>.unmodifiable(
        notifications,
      );
    });
  }

  @override
  Future<List<NotificationEntity>>
  getNotifications({
    bool unreadOnly = false,
  }) async {
    final notifications =
    await _localDataSource.getNotifications(
      unreadOnly: unreadOnly,
    );

    return List<NotificationEntity>.unmodifiable(
      notifications,
    );
  }

  @override
  Future<void> saveNotification({
    required NotificationEntity notification,
  }) {
    return _localDataSource.saveNotification(
      notification:
      AppNotificationModel.fromEntity(
        notification,
      ),
    );
  }

  @override
  Future<void> markAsRead({
    required String id,
  }) {
    return _localDataSource.markAsRead(
      id: id,
    );
  }

  @override
  Future<void> markAllAsRead() {
    return _localDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification({
    required String id,
  }) {
    return _localDataSource.deleteNotification(
      id: id,
    );
  }

  @override
  Future<void> clearNotifications() {
    return _localDataSource.clearNotifications();
  }
}