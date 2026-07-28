import 'package:equatable/equatable.dart';

import '../../domain/entities/article_entity.dart';

enum ArticlesStatus { initial, loading, success, failure }

class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<ArticleEntity> articles;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final String? errorMessage;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.query = '',
    this.errorMessage,
  });

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<ArticleEntity>? articles,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    isLoadingMore,
    hasMore,
    query,
    errorMessage,
  ];
}
