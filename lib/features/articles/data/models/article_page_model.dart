import '../../domain/entities/article_page_entity.dart';
import 'article_model.dart';

class ArticlePageModel extends ArticlePageEntity {
  const ArticlePageModel({
    required List<ArticleModel> articles,
    required super.total,
    required super.skip,
    required super.limit,
  }) : super(articles: articles);

  factory ArticlePageModel.fromJson(Map<String, dynamic> json) {
    final postsJson = json['posts'];

    final articles =
        postsJson is List
            ? postsJson
                .whereType<Map<String, dynamic>>()
                .map(ArticleModel.fromJson)
                .toList()
            : <ArticleModel>[];

    return ArticlePageModel(
      articles: articles,
      total: json['total'] as int? ?? articles.length,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? articles.length,
    );
  }
}
