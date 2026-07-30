import 'dart:async';

import '../../domain/entities/article_entity.dart';
import '../../domain/entities/article_page_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../data_sources/article_local_data_source.dart';
import '../data_sources/article_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remoteDataSource;
  final ArticleLocalDataSource _localDataSource;

  const ArticleRepositoryImpl({
    required ArticleRemoteDataSource remoteDataSource,
    required ArticleLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<ArticlePageEntity> getArticles({
    required int limit,
    required int skip,
  }) async {
    try {
      final remotePage = await _remoteDataSource.getArticles(
        limit: limit,
        skip: skip,
      );

      await _cacheArticlesSafely(
        articles: remotePage.articles.map(ArticleModel.fromEntity).toList(),
        total: remotePage.total,
        replace: skip == 0,
      );

      return remotePage;
    } catch (error, stackTrace) {
      if (_localDataSource.hasCachedArticles) {
        return _localDataSource.getCachedArticles(limit: limit, skip: skip);
      }

      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<ArticleEntity> getArticleById({required int id}) async {
    try {
      final remoteArticle = await _remoteDataSource.getArticleById(id: id);

      await _cacheArticleSafely(ArticleModel.fromEntity(remoteArticle));

      return remoteArticle;
    } catch (error, stackTrace) {
      final cachedArticle = await _getCachedArticleSafely(id);

      if (cachedArticle != null) {
        return cachedArticle;
      }

      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<ArticlePageEntity> searchArticles({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return getArticles(limit: limit, skip: skip);
    }

    try {
      final remotePage = await _remoteDataSource.searchArticles(
        query: normalizedQuery,
        limit: limit,
        skip: skip,
      );

      await _cacheArticlesSafely(
        articles: remotePage.articles.map(ArticleModel.fromEntity).toList(),
        total: remotePage.total,
        replace: false,
      );

      return remotePage;
    } catch (error, stackTrace) {
      if (_localDataSource.hasCachedArticles) {
        return _localDataSource.searchCachedArticles(
          query: normalizedQuery,
          limit: limit,
          skip: skip,
        );
      }

      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<ArticleModel?> _getCachedArticleSafely(int id) async {
    try {
      return await _localDataSource.getCachedArticleById(id: id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheArticleSafely(ArticleModel article) async {
    try {
      await _localDataSource.cacheArticle(article: article);
    } catch (_) {
      // Cache errors must not hide remote data.
    }
  }

  Future<void> _cacheArticlesSafely({
    required List<ArticleModel> articles,
    required int total,
    required bool replace,
  }) async {
    try {
      await _localDataSource.cacheArticles(
        articles: articles,
        total: total,
        replace: replace,
      );
    } catch (_) {
      // Cache errors must not hide remote data.
    }
  }
}
