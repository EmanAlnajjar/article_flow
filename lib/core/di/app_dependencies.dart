import 'package:dio/dio.dart';

import '../../features/articles/data/data_sources/article_remote_data_source.dart';
import '../../features/articles/data/data_sources/article_remote_data_source_impl.dart';
import '../../features/articles/data/repositories/article_repository_impl.dart';
import '../../features/articles/domain/repositories/article_repository.dart';
import '../../features/articles/domain/use_cases/get_articles_use_case.dart';
import '../../features/articles/domain/use_cases/search_articles_use_case.dart';
import '../../features/articles/presentation/cubit/articles_cubit.dart';
import '../api/api_client.dart';

class AppDependencies {
  final Dio dio;
  final ApiClient apiClient;
  final ArticleRemoteDataSource remoteDataSource;
  final ArticleRepository articleRepository;
  final GetArticlesUseCase getArticlesUseCase;
  final SearchArticlesUseCase searchArticlesUseCase;

  AppDependencies._({
    required this.dio,
    required this.apiClient,
    required this.remoteDataSource,
    required this.articleRepository,
    required this.getArticlesUseCase,
    required this.searchArticlesUseCase,
  });

  factory AppDependencies.create() {
    final dio = Dio();
    final apiClient = ApiClient(dio);

    final remoteDataSource = ArticleRemoteDataSourceImpl(
      apiClient,
    );

    final articleRepository = ArticleRepositoryImpl(
      remoteDataSource,
    );

    final getArticlesUseCase = GetArticlesUseCase(
      articleRepository,
    );

    final searchArticlesUseCase = SearchArticlesUseCase(
      articleRepository,
    );

    return AppDependencies._(
      dio: dio,
      apiClient: apiClient,
      remoteDataSource: remoteDataSource,
      articleRepository: articleRepository,
      getArticlesUseCase: getArticlesUseCase,
      searchArticlesUseCase: searchArticlesUseCase,
    );
  }

  ArticlesCubit createArticlesCubit() {
    return ArticlesCubit(
      getArticlesUseCase: getArticlesUseCase,
      searchArticlesUseCase: searchArticlesUseCase,
    );
  }
}