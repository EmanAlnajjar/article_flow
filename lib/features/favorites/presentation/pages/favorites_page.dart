import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../articles/presentation/widgets/article_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            buildWhen: (previous, current) {
              return previous.favorites.length !=
                  current.favorites.length ||
                  previous.isClearing != current.isClearing;
            },
            builder: (context, state) {
              if (state.favorites.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear favorites',
                onPressed: state.isClearing
                    ? null
                    : () => _confirmClear(context),
                icon: state.isClearing
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.delete_sweep_outlined,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<FavoritesCubit, FavoritesState>(
          listenWhen: (previous, current) {
            return previous.errorMessage !=
                current.errorMessage ||
                previous.actionMessage !=
                    current.actionMessage;
          },
          listener: (context, state) {
            final message =
                state.errorMessage ?? state.actionMessage;

            if (message == null) {
              return;
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
          },
          builder: (context, state) {
            if (state.status == FavoritesStatus.initial ||
                state.status == FavoritesStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.status == FavoritesStatus.failure &&
                state.favorites.isEmpty) {
              return _FavoritesErrorView(
                message: state.errorMessage ??
                    'Failed to load favorites.',
                onRetry: () {
                  context
                      .read<FavoritesCubit>()
                      .loadFavorites();
                },
              );
            }

            if (state.favorites.isEmpty) {
              return const _EmptyFavoritesView();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                28,
              ),
              itemCount: state.favorites.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                final article = state.favorites[index];

                return ArticleCard(
                  article: article,
                  isFavorite: true,
                  isProcessing:
                  state.isProcessing(article.id),
                  onFavoriteToggle: () {
                    context
                        .read<FavoritesCubit>()
                        .toggleFavorite(article);
                  },
                  onTap: () {
                    context.pushNamed(
                      AppRouter.articleDetailsName,
                      extra: article,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_sweep_outlined,
          ),
          title: const Text('Clear favorites?'),
          content: const Text(
            'All saved articles will be removed from your favorites.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context
          .read<FavoritesCubit>()
          .clearFavorites();
    }
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 54,
                color: colors.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Articles you save will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.go(AppRouter.articlesPath);
              },
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore articles'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FavoritesErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}