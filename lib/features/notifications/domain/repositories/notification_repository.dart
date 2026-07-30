import '../entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Stream<List<NotificationEntity>>
  watchNotifications();

  Future<List<NotificationEntity>>
  getNotifications({
    bool unreadOnly = false,
  });

  Future<void> saveNotification({
    required NotificationEntity notification,
  });

  Future<void> markAsRead({
    required String id,
  });

  Future<void> markAllAsRead();

  Future<void> deleteNotification({
    required String id,
  });

  Future<void> clearNotifications();
}