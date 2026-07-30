import 'package:hive/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/app_notification_model.dart';
import 'notification_local_data_source.dart';

class NotificationLocalDataSourceImpl
    implements NotificationLocalDataSource {
  final Box<AppNotificationModel> _notificationsBox;

  const NotificationLocalDataSourceImpl({
    required Box<AppNotificationModel>
    notificationsBox,
  }) : _notificationsBox = notificationsBox;

  @override
  Stream<List<AppNotificationModel>>
  watchNotifications() async* {
    yield _getSortedNotifications();

    await for (final _ in _notificationsBox.watch()) {
      yield _getSortedNotifications();
    }
  }

  @override
  Future<List<AppNotificationModel>>
  getNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final notifications =
      _getSortedNotifications();

      if (!unreadOnly) {
        return notifications;
      }

      return notifications.where((notification) {
        return !notification.isRead;
      }).toList();
    } catch (_) {
      throw const CacheException(
        message: 'Failed to read notifications.',
      );
    }
  }

  @override
  Future<void> saveNotification({
    required AppNotificationModel notification,
  }) async {
    try {
      final existingNotification =
      _notificationsBox.get(notification.id);

      if (existingNotification != null) {
        if (notification.isRead &&
            !existingNotification.isRead) {
          await _notificationsBox.put(
            notification.id,
            existingNotification.copyWith(
              isRead: true,
            ),
          );
        }

        return;
      }

      await _notificationsBox.put(
        notification.id,
        notification,
      );
    } catch (_) {
      throw const CacheException(
        message: 'Failed to save the notification.',
      );
    }
  }

  @override
  Future<void> markAsRead({
    required String id,
  }) async {
    try {
      final notification =
      _notificationsBox.get(id);

      if (notification == null ||
          notification.isRead) {
        return;
      }

      await _notificationsBox.put(
        id,
        notification.copyWith(
          isRead: true,
        ),
      );
    } catch (_) {
      throw const CacheException(
        message:
        'Failed to update the notification.',
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications =
      _notificationsBox.values.where(
            (notification) {
          return !notification.isRead;
        },
      );

      final updatedNotifications =
      <String, AppNotificationModel>{
        for (final notification
        in unreadNotifications)
          notification.id: notification.copyWith(
            isRead: true,
          ),
      };

      if (updatedNotifications.isEmpty) {
        return;
      }

      await _notificationsBox.putAll(
        updatedNotifications,
      );
    } catch (_) {
      throw const CacheException(
        message:
        'Failed to mark notifications as read.',
      );
    }
  }

  @override
  Future<void> deleteNotification({
    required String id,
  }) async {
    try {
      await _notificationsBox.delete(id);
    } catch (_) {
      throw const CacheException(
        message:
        'Failed to delete the notification.',
      );
    }
  }

  @override
  Future<void> clearNotifications() async {
    try {
      await _notificationsBox.clear();
    } catch (_) {
      throw const CacheException(
        message:
        'Failed to clear notifications.',
      );
    }
  }

  List<AppNotificationModel>
  _getSortedNotifications() {
    final notifications =
    _notificationsBox.values.toList();

    notifications.sort((first, second) {
      return second.receivedAt.compareTo(
        first.receivedAt,
      );
    });

    return notifications;
  }
}