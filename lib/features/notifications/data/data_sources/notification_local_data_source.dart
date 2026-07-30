import '../models/app_notification_model.dart';

abstract interface class NotificationLocalDataSource {
  Stream<List<AppNotificationModel>>
  watchNotifications();

  Future<List<AppNotificationModel>>
  getNotifications({
    bool unreadOnly = false,
  });

  Future<void> saveNotification({
    required AppNotificationModel notification,
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