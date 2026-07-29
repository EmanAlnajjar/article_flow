import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ network/network_info.dart';
import '../../../../core/errors/app_exception.dart';

import '../../domain/entities/article_entity.dart';
import '../../domain/entities/article_page_entity.dart';
import '../../domain/use_cases/article_params.dart';
import '../../domain/use_cases/get_articles_use_case.dart';
import '../../domain/use_cases/search_articles_use_case.dart';
import 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final SearchArticlesUseCase _searchArticlesUseCase;
  final NetworkInfo _networkInfo;

  static const int _pageSize = 10;

  Timer? _searchDebounce;
  StreamSubscription<bool>? _connectionSubscription;

  int _requestId = 0;

  ArticlesCubit({
    required GetArticlesUseCase getArticlesUseCase,
    required SearchArticlesUseCase searchArticlesUseCase,
    required NetworkInfo networkInfo,
  }) : _getArticlesUseCase = getArticlesUseCase,
       _searchArticlesUseCase = searchArticlesUseCase,
       _networkInfo = networkInfo,
       super(const ArticlesState()) {
    unawaited(_monitorConnection());
  }

  Future<void> loadArticles() {
    return _loadFirstPage(query: '');
  }

  void searchArticles(String value) {
    final query = value.trim();

    _searchDebounce?.cancel();

    emit(state.copyWith(query: query, clearError: true));

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_loadFirstPage(query: query));
    });
  }

  Future<void> _loadFirstPage({required String query}) async {
    final currentRequestId = ++_requestId;

    emit(
      state.copyWith(
        status: ArticlesStatus.loading,
        articles: const [],
        isLoadingMore: false,
        hasMore: true,
        query: query,
        clearError: true,
      ),
    );

    try {
      final page = await _requestPage(query: query, skip: 0);

      if (currentRequestId != _requestId || isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ArticlesStatus.success,
          articles: page.articles,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (exception) {
      if (currentRequestId != _requestId || isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ArticlesStatus.failure,
          articles: const [],
          isLoadingMore: false,
          errorMessage: _getErrorMessage(exception),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.status != ArticlesStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final currentRequestId = _requestId;
    final currentQuery = state.query;
    final currentArticles = state.articles;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final page = await _requestPage(
        query: currentQuery,
        skip: currentArticles.length,
      );

      if (currentRequestId != _requestId || isClosed) {
        return;
      }

      final updatedArticles = _removeDuplicates([
        ...currentArticles,
        ...page.articles,
      ]);

      emit(
        state.copyWith(
          articles: updatedArticles,
          isLoadingMore: false,
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
    } catch (exception) {
      if (currentRequestId != _requestId || isClosed) {
        return;
      }

      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: _getErrorMessage(exception),
        ),
      );
    }
  }

  Future<ArticlePageEntity> _requestPage({
    required String query,
    required int skip,
  }) {
    if (query.isEmpty) {
      return _getArticlesUseCase(
        PaginationParams(limit: _pageSize, skip: skip),
      );
    }

    return _searchArticlesUseCase(
      SearchArticlesParams(query: query, limit: _pageSize, skip: skip),
    );
  }

  Future<void> _monitorConnection() async {
    _connectionSubscription = _networkInfo.onStatusChange.listen(
      _handleConnectionChange,
    );

    final connected = await _networkInfo.isConnected;

    if (isClosed) {
      return;
    }

    emit(state.copyWith(isOffline: !connected));
  }

  void _handleConnectionChange(bool connected) {
    if (isClosed) {
      return;
    }

    final wasOffline = state.isOffline;
    final currentQuery = state.query;

    emit(state.copyWith(isOffline: !connected));

    if (connected && wasOffline) {
      unawaited(_loadFirstPage(query: currentQuery));
    }
  }

  List<ArticleEntity> _removeDuplicates(List<ArticleEntity> articles) {
    final uniqueArticles = <int, ArticleEntity>{};

    for (final article in articles) {
      uniqueArticles[article.id] = article;
    }

    return uniqueArticles.values.toList();
  }

  String _getErrorMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }

    if (exception is FormatException) {
      return exception.message;
    }

    return 'Something went wrong. Please try again.';
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await _connectionSubscription?.cancel();

    return super.close();
  }
}
