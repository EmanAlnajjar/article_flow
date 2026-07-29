import '../../../articles/domain/entities/article_entity.dart';

abstract interface class FavoriteRepository {
  List<ArticleEntity> getFavorites();

  bool isFavorite(int articleId);

  Future<bool> toggleFavorite(ArticleEntity article);

  Future<void> clearFavorites();
}
