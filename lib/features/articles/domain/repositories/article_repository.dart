import '../entities/article_entity.dart';
import '../entities/article_page_entity.dart';

abstract interface class ArticleRepository {
  Future<ArticlePageEntity> getArticles({
    required int limit,
    required int skip,
  });

  Future<ArticleEntity> getArticleById({required int id});

  Future<ArticlePageEntity> searchArticles({
    required String query,
    required int limit,
    required int skip,
  });
}
