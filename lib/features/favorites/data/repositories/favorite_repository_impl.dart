import '../../../articles/data/models/article_model.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../data_sources/favorite_local_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource;

  const FavoriteRepositoryImpl({
    required FavoriteLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  List<ArticleEntity> getFavorites() {
    return _localDataSource.getFavorites();
  }

  @override
  bool isFavorite(int articleId) {
    return _localDataSource.isFavorite(articleId);
  }

  @override
  Future<bool> toggleFavorite(ArticleEntity article) async {
    final favorite = _localDataSource.isFavorite(article.id);

    if (favorite) {
      await _localDataSource.removeFavorite(article.id);

      return false;
    }

    final articleModel = ArticleModel.fromEntity(article);

    await _localDataSource.addFavorite(articleModel);

    return true;
  }

  @override
  Future<void> clearFavorites() {
    return _localDataSource.clearFavorites();
  }
}
