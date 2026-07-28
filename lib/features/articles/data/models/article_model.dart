import 'package:hive/hive.dart';

import '../../../../core/constants/article_images.dart';
import '../../domain/entities/article_entity.dart';

part 'article_model.g.dart';

@HiveType(typeId: 0)
class ArticleModel extends ArticleEntity {
  @override
  @HiveField(0)
  final int id;

  @override
  @HiveField(1)
  final String title;

  @override
  @HiveField(2)
  final String body;

  @override
  @HiveField(3)
  final String imageUrl;

  @override
  @HiveField(4)
  final List<String> tags;

  @override
  @HiveField(5)
  final int views;

  @override
  @HiveField(6)
  final int likes;

  @override
  @HiveField(7)
  final int dislikes;

  @override
  @HiveField(8)
  final int userId;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.tags,
    required this.views,
    required this.likes,
    required this.dislikes,
    required this.userId,
  }) : super(
         id: id,
         title: title,
         body: body,
         imageUrl: imageUrl,
         tags: tags,
         views: views,
         likes: likes,
         dislikes: dislikes,
         userId: userId,
       );

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'];
    final id = json['id'] as int? ?? 0;

    return ArticleModel(
      id: id,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? ArticleImages.getForArticle(id),
      tags: _parseTags(json['tags']),
      views: json['views'] as int? ?? 0,
      likes: reactions is Map ? reactions['likes'] as int? ?? 0 : 0,
      dislikes: reactions is Map ? reactions['dislikes'] as int? ?? 0 : 0,
      userId: json['userId'] as int? ?? 0,
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      body: article.body,
      imageUrl: article.imageUrl,
      tags: article.tags,
      views: article.views,
      likes: article.likes,
      dislikes: article.dislikes,
      userId: article.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'tags': tags,
      'views': views,
      'reactions': {'likes': likes, 'dislikes': dislikes},
      'userId': userId,
    };
  }

  static List<String> _parseTags(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.whereType<String>().toList();
  }
}
