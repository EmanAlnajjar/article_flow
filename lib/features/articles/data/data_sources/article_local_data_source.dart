import '../models/article_model.dart';
import '../models/article_page_model.dart';

abstract interface class ArticleLocalDataSource {
  Future<void> cacheArticles({
    required List<ArticleModel> articles,
    required int total,
    required bool replace,
  });

  Future<ArticlePageModel> getCachedArticles({
    required int limit,
    required int skip,
  });

  Future<ArticlePageModel> searchCachedArticles({
    required String query,
    required int limit,
    required int skip,
  });

  bool get hasCachedArticles;

  DateTime? get lastUpdate;
}
