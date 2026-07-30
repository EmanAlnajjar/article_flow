import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final int? articleId;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    required this.isRead,
    this.articleId,
  });

  bool get opensArticle {
    return type == 'article' && articleId != null && articleId! > 0;
  }

  @override
  List<Object?> get props {
    return [id, title, body, type, articleId, receivedAt, isRead];
  }
}
