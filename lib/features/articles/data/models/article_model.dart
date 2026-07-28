import '../../../../core/constants/article_images.dart';
import '../../domain/entities/article_entity.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.body,
    required super.imageUrl,
    required super.tags,
    required super.views,
    required super.likes,
    required super.dislikes,
    required super.userId,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'];
    final id = json['id'] as int? ?? 0;

    return ArticleModel(
      id: id,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: ArticleImages.getForArticle(id),
      tags: _parseTags(json['tags']),
      views: json['views'] as int? ?? 0,
      likes: reactions is Map<String, dynamic>
          ? reactions['likes'] as int? ?? 0
          : 0,
      dislikes: reactions is Map<String, dynamic>
          ? reactions['dislikes'] as int? ?? 0
          : 0,
      userId: json['userId'] as int? ?? 0,
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
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'userId': userId,
    };
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags is! List) {
      return [];
    }

    return tags.whereType<String>().toList();
  }
}