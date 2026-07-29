import 'package:equatable/equatable.dart';

import '../../../articles/domain/entities/article_entity.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<ArticleEntity> favorites;
  final Set<int> processingArticleIds;
  final bool isClearing;
  final String? errorMessage;
  final String? actionMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.processingArticleIds = const {},
    this.isClearing = false,
    this.errorMessage,
    this.actionMessage,
  });

  bool isFavorite(int articleId) {
    return favorites.any((article) => article.id == articleId);
  }

  bool isProcessing(int articleId) {
    return processingArticleIds.contains(articleId);
  }

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ArticleEntity>? favorites,
    Set<int>? processingArticleIds,
    bool? isClearing,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      processingArticleIds: processingArticleIds ?? this.processingArticleIds,
      isClearing: isClearing ?? this.isClearing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    favorites,
    processingArticleIds,
    isClearing,
    errorMessage,
    actionMessage,
  ];
}
