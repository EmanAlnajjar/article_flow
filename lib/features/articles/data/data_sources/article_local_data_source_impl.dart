import 'package:hive/hive.dart';

import '../../../../core/database/hive_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/article_model.dart';
import '../models/article_page_model.dart';
import 'article_local_data_source.dart';

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  final Box<ArticleModel> _articlesBox;
  final Box<dynamic> _metadataBox;

  const ArticleLocalDataSourceImpl({
    required Box<ArticleModel> articlesBox,
    required Box<dynamic> metadataBox,
  }) : _articlesBox = articlesBox,
       _metadataBox = metadataBox;

  @override
  bool get hasCachedArticles {
    return _articlesBox.isNotEmpty;
  }

  @override
  DateTime? get lastUpdate {
    final value = _metadataBox.get(HiveService.lastUpdateKey);

    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  @override
  Future<void> cacheArticles({
    required List<ArticleModel> articles,
    required int total,
    required bool replace,
  }) async {
    try {
      final articlesMap = <int, ArticleModel>{
        for (final article in articles) article.id: article,
      };

      await _articlesBox.putAll(articlesMap);

      if (replace) {
        final newArticleIds = articlesMap.keys.toSet();

        final staleKeys =
            _articlesBox.keys.where((key) {
              return key is! int || !newArticleIds.contains(key);
            }).toList();

        if (staleKeys.isNotEmpty) {
          await _articlesBox.deleteAll(staleKeys);
        }
      }

      await _metadataBox.put(HiveService.cachedTotalKey, total);

      await _saveLastUpdate();
    } catch (_) {
      throw const CacheException(message: 'Failed to cache articles.');
    }
  }

  @override
  Future<void> cacheArticle({required ArticleModel article}) async {
    try {
      await _articlesBox.put(article.id, article);

      await _saveLastUpdate();
    } catch (_) {
      throw const CacheException(message: 'Failed to cache the article.');
    }
  }

  @override
  Future<ArticlePageModel> getCachedArticles({
    required int limit,
    required int skip,
  }) async {
    try {
      final articles = _getSortedArticles();

      return _createPage(articles: articles, limit: limit, skip: skip);
    } catch (_) {
      throw const CacheException(message: 'Failed to read cached articles.');
    }
  }

  @override
  Future<ArticleModel?> getCachedArticleById({required int id}) async {
    try {
      return _articlesBox.get(id);
    } catch (_) {
      throw const CacheException(message: 'Failed to read the cached article.');
    }
  }

  @override
  Future<ArticlePageModel> searchCachedArticles({
    required String query,
    required int limit,
    required int skip,
  }) async {
    try {
      final normalizedQuery = query.trim().toLowerCase();

      if (normalizedQuery.isEmpty) {
        return getCachedArticles(limit: limit, skip: skip);
      }

      final filteredArticles =
          _getSortedArticles().where((article) {
            final title = article.title.toLowerCase();
            final body = article.body.toLowerCase();

            final matchesTag = article.tags.any((tag) {
              return tag.toLowerCase().contains(normalizedQuery);
            });

            return title.contains(normalizedQuery) ||
                body.contains(normalizedQuery) ||
                matchesTag;
          }).toList();

      return _createPage(articles: filteredArticles, limit: limit, skip: skip);
    } catch (exception) {
      if (exception is CacheException) {
        rethrow;
      }

      throw const CacheException(message: 'Failed to search cached articles.');
    }
  }

  Future<void> _saveLastUpdate() {
    return _metadataBox.put(
      HiveService.lastUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  List<ArticleModel> _getSortedArticles() {
    final articles = _articlesBox.values.toList();

    articles.sort((first, second) {
      return first.id.compareTo(second.id);
    });

    return articles;
  }

  ArticlePageModel _createPage({
    required List<ArticleModel> articles,
    required int limit,
    required int skip,
  }) {
    final safeSkip = skip.clamp(0, articles.length).toInt();

    final pageArticles = articles.skip(safeSkip).take(limit).toList();

    return ArticlePageModel(
      articles: pageArticles,
      total: articles.length,
      skip: safeSkip,
      limit: limit,
    );
  }
}
