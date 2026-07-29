import 'package:hive/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../articles/data/models/article_model.dart';
import 'favorite_local_data_source.dart';

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  final Box<ArticleModel> _favoritesBox;

  const FavoriteLocalDataSourceImpl({required Box<ArticleModel> favoritesBox})
    : _favoritesBox = favoritesBox;

  @override
  List<ArticleModel> getFavorites() {
    try {
      return _favoritesBox.values.toList().reversed.toList();
    } catch (_) {
      throw const CacheException(message: 'Failed to load favorite articles.');
    }
  }

  @override
  bool isFavorite(int articleId) {
    try {
      return _favoritesBox.containsKey(articleId);
    } catch (_) {
      throw const CacheException(message: 'Failed to check favorite status.');
    }
  }

  @override
  Future<void> addFavorite(ArticleModel article) async {
    try {
      await _favoritesBox.put(article.id, article);
    } catch (_) {
      throw const CacheException(
        message: 'Failed to add the article to favorites.',
      );
    }
  }

  @override
  Future<void> removeFavorite(int articleId) async {
    try {
      await _favoritesBox.delete(articleId);
    } catch (_) {
      throw const CacheException(
        message: 'Failed to remove the article from favorites.',
      );
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await _favoritesBox.clear();
    } catch (_) {
      throw const CacheException(message: 'Failed to clear favorites.');
    }
  }
}
