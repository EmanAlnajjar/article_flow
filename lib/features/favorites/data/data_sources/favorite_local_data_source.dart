import '../../../articles/data/models/article_model.dart';

abstract interface class FavoriteLocalDataSource {
  List<ArticleModel> getFavorites();

  bool isFavorite(int articleId);

  Future<void> addFavorite(ArticleModel article);

  Future<void> removeFavorite(int articleId);

  Future<void> clearFavorites();
}
