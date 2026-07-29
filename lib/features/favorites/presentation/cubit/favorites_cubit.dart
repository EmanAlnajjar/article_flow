import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../domain/use_cases/favorite_use_cases.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final IsFavoriteUseCase _isFavoriteUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final ClearFavoritesUseCase _clearFavoritesUseCase;

  FavoritesCubit({
    required GetFavoritesUseCase getFavoritesUseCase,
    required IsFavoriteUseCase isFavoriteUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required ClearFavoritesUseCase clearFavoritesUseCase,
  }) : _getFavoritesUseCase = getFavoritesUseCase,
       _isFavoriteUseCase = isFavoriteUseCase,
       _toggleFavoriteUseCase = toggleFavoriteUseCase,
       _clearFavoritesUseCase = clearFavoritesUseCase,
       super(const FavoritesState());

  void loadFavorites() {
    emit(
      state.copyWith(
        status: FavoritesStatus.loading,
        clearError: true,
        clearActionMessage: true,
      ),
    );

    try {
      final favorites = _getFavoritesUseCase();

      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: favorites,
          clearError: true,
        ),
      );
    } catch (exception) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: _getErrorMessage(exception),
        ),
      );
    }
  }

  bool isFavorite(int articleId) {
    return _isFavoriteUseCase(articleId);
  }

  Future<void> toggleFavorite(ArticleEntity article) async {
    if (state.isProcessing(article.id)) {
      return;
    }

    final processingIds = {...state.processingArticleIds, article.id};

    emit(
      state.copyWith(
        processingArticleIds: processingIds,
        clearError: true,
        clearActionMessage: true,
      ),
    );

    try {
      final added = await _toggleFavoriteUseCase(article);

      final favorites = _getFavoritesUseCase();

      final updatedProcessingIds = {...state.processingArticleIds}
        ..remove(article.id);

      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: favorites,
          processingArticleIds: updatedProcessingIds,
          actionMessage:
              added
                  ? 'Article added to favorites.'
                  : 'Article removed from favorites.',
          clearError: true,
        ),
      );
    } catch (exception) {
      final updatedProcessingIds = {...state.processingArticleIds}
        ..remove(article.id);

      emit(
        state.copyWith(
          processingArticleIds: updatedProcessingIds,
          errorMessage: _getErrorMessage(exception),
          clearActionMessage: true,
        ),
      );
    }
  }

  Future<void> clearFavorites() async {
    if (state.isClearing || state.favorites.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        isClearing: true,
        clearError: true,
        clearActionMessage: true,
      ),
    );

    try {
      await _clearFavoritesUseCase();

      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: const [],
          isClearing: false,
          actionMessage: 'All favorites were removed.',
          clearError: true,
        ),
      );
    } catch (exception) {
      emit(
        state.copyWith(
          isClearing: false,
          errorMessage: _getErrorMessage(exception),
        ),
      );
    }
  }

  String _getErrorMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
