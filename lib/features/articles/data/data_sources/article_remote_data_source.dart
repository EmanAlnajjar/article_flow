import '../models/article_model.dart';
import '../models/article_page_model.dart';

abstract interface class ArticleRemoteDataSource {
  Future<ArticlePageModel> getArticles({required int limit, required int skip});

  Future<ArticleModel> getArticleById({required int id});

  Future<ArticlePageModel> searchArticles({
    required String query,
    required int limit,
    required int skip,
  });
}
