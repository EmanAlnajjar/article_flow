// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';

import '../../domain/entities/notification_entity.dart';

part 'app_notification_model.g.dart';

@HiveType(typeId: 1)
class AppNotificationModel extends NotificationEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String title;

  @override
  @HiveField(2)
  final String body;

  @override
  @HiveField(3)
  final String type;

  @override
  @HiveField(4)
  final int? articleId;

  @override
  @HiveField(5)
  final DateTime receivedAt;

  @override
  @HiveField(6)
  final bool isRead;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    required this.isRead,
    this.articleId,
  }) : super(
         id: id,
         title: title,
         body: body,
         type: type,
         articleId: articleId,
         receivedAt: receivedAt,
         isRead: isRead,
       );

  factory AppNotificationModel.fromEntity(NotificationEntity notification) {
    return AppNotificationModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      articleId: notification.articleId,
      receivedAt: notification.receivedAt,
      isRead: notification.isRead,
    );
  }

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    int? articleId,
    DateTime? receivedAt,
    bool? isRead,
    bool clearArticleId = false,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      articleId: clearArticleId ? null : articleId ?? this.articleId,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
