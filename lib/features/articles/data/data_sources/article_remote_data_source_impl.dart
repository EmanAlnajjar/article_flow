import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/article_page_model.dart';
import 'article_remote_data_source.dart';

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final ApiClient _apiClient;

  const ArticleRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ArticlePageModel> getArticles({
    required int limit,
    required int skip,
  }) {
    return _fetchArticlePage(
      endpoint: ApiEndpoints.posts,
      queryParameters: {'limit': limit, 'skip': skip},
    );
  }

  @override
  Future<ArticlePageModel> searchArticles({
    required String query,
    required int limit,
    required int skip,
  }) {
    return _fetchArticlePage(
      endpoint: ApiEndpoints.searchPosts,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
  }

  Future<ArticlePageModel> _fetchArticlePage({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
  }) async {
    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParameters,
    );

    if (response is! Map) {
      throw const FormatException('Invalid server response format.');
    }

    final json = Map<String, dynamic>.from(response);

    return ArticlePageModel.fromJson(json);
  }
}
