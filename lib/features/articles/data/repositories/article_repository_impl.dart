import '../../domain/entities/article_page_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../data_sources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remoteDataSource;

  const ArticleRepositoryImpl(this._remoteDataSource);

  @override
  Future<ArticlePageEntity> getArticles({
    required int limit,
    required int skip,
  }) {
    return _remoteDataSource.getArticles(limit: limit, skip: skip);
  }

  @override
  Future<ArticlePageEntity> searchArticles({
    required String query,
    required int limit,
    required int skip,
  }) {
    return _remoteDataSource.searchArticles(
      query: query,
      limit: limit,
      skip: skip,
    );
  }
}
