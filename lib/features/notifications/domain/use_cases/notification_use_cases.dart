import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class WatchNotificationsUseCase {
  final NotificationRepository _repository;

  const WatchNotificationsUseCase(
      this._repository,
      );

  Stream<List<NotificationEntity>> call() {
    return _repository.watchNotifications();
  }
}

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(
      this._repository,
      );

  Future<List<NotificationEntity>> call({
    bool unreadOnly = false,
  }) {
    return _repository.getNotifications(
      unreadOnly: unreadOnly,
    );
  }
}

class SaveNotificationUseCase {
  final NotificationRepository _repository;

  const SaveNotificationUseCase(
      this._repository,
      );

  Future<void> call({
    required NotificationEntity notification,
  }) {
    return _repository.saveNotification(
      notification: notification,
    );
  }
}

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(
      this._repository,
      );

  Future<void> call({
    required String id,
  }) {
    return _repository.markAsRead(
      id: id,
    );
  }
}

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsReadUseCase(
      this._repository,
      );

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}

class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  const DeleteNotificationUseCase(
      this._repository,
      );

  Future<void> call({
    required String id,
  }) {
    return _repository.deleteNotification(
      id: id,
    );
  }
}

class ClearNotificationsUseCase {
  final NotificationRepository _repository;

  const ClearNotificationsUseCase(
      this._repository,
      );

  Future<void> call() {
    return _repository.clearNotifications();
  }
}