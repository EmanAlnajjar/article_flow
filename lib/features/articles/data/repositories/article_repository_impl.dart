import 'dart:async';

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

      await _cacheSafely(
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

      await _cacheSafely(
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

  Future<void> _cacheSafely({
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
      // A cache failure must not hide successful remote data.
    }
  }
}
