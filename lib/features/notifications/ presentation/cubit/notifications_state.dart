import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

enum NotificationsStatus {
  initial,
  loading,
  success,
  failure,
}

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final bool isProcessing;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  List<NotificationEntity>
  get unreadNotifications {
    return notifications.where((notification) {
      return !notification.isRead;
    }).toList(growable: false);
  }

  int get unreadCount {
    return unreadNotifications.length;
  }

  bool get hasUnreadNotifications {
    return unreadCount > 0;
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications:
      notifications ?? this.notifications,
      isProcessing:
      isProcessing ?? this.isProcessing,
      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      notifications,
      isProcessing,
      errorMessage,
    ];
  }
}