import 'package:dio/dio.dart';

import '../../features/articles/data/data_sources/article_local_data_source.dart';
import '../../features/articles/data/data_sources/article_local_data_source_impl.dart';
import '../../features/articles/data/data_sources/article_remote_data_source.dart';
import '../../features/articles/data/data_sources/article_remote_data_source_impl.dart';
import '../../features/articles/data/repositories/article_repository_impl.dart';
import '../../features/articles/domain/repositories/article_repository.dart';
import '../../features/articles/domain/use_cases/get_articles_use_case.dart';
import '../../features/articles/domain/use_cases/search_articles_use_case.dart';
import '../../features/articles/presentation/cubit/articles_cubit.dart';
import '../api/api_client.dart';
import '../database/hive_service.dart';

class AppDependencies {
  final Dio dio;
  final ApiClient apiClient;

  final ArticleRemoteDataSource remoteDataSource;
  final ArticleLocalDataSource localDataSource;
  final ArticleRepository articleRepository;

  final GetArticlesUseCase getArticlesUseCase;
  final SearchArticlesUseCase searchArticlesUseCase;

  AppDependencies._({
    required this.dio,
    required this.apiClient,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.articleRepository,
    required this.getArticlesUseCase,
    required this.searchArticlesUseCase,
  });

  factory AppDependencies.create() {
    final dio = Dio();

    final apiClient = ApiClient(dio);

    final remoteDataSource = ArticleRemoteDataSourceImpl(apiClient: apiClient);

    final localDataSource = ArticleLocalDataSourceImpl(
      articlesBox: HiveService.articlesBox,
      metadataBox: HiveService.cacheMetadataBox,
    );

    final articleRepository = ArticleRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    final getArticlesUseCase = GetArticlesUseCase(articleRepository);

    final searchArticlesUseCase = SearchArticlesUseCase(articleRepository);

    return AppDependencies._(
      dio: dio,
      apiClient: apiClient,
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
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
