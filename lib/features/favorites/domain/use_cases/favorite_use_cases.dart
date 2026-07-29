import '../../../articles/domain/entities/article_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository _repository;

  const GetFavoritesUseCase(this._repository);

  List<ArticleEntity> call() {
    return _repository.getFavorites();
  }
}

class IsFavoriteUseCase {
  final FavoriteRepository _repository;

  const IsFavoriteUseCase(this._repository);

  bool call(int articleId) {
    return _repository.isFavorite(articleId);
  }
}

class ToggleFavoriteUseCase {
  final FavoriteRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<bool> call(ArticleEntity article) {
    return _repository.toggleFavorite(article);
  }
}

class ClearFavoritesUseCase {
  final FavoriteRepository _repository;

  const ClearFavoritesUseCase(this._repository);

  Future<void> call() {
    return _repository.clearFavorites();
  }
}
