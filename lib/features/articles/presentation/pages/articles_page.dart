import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../cubit/articles_cubit.dart';
import '../cubit/articles_state.dart';
import '../widgets/article_card.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    _searchController = TextEditingController();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ArticlesCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('ArticleFlow'), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            const _OfflineBanner(),
            Expanded(
              child: BlocConsumer<ArticlesCubit, ArticlesState>(
                listenWhen: (previous, current) {
                  return previous.errorMessage != current.errorMessage &&
                      current.errorMessage != null &&
                      current.articles.isNotEmpty;
                },
                listener: (context, state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                },
                builder: (context, state) {
                  return switch (state.status) {
                    ArticlesStatus.initial || ArticlesStatus.loading =>
                      const Center(child: CircularProgressIndicator()),
                    ArticlesStatus.failure => _ErrorView(
                      message: state.errorMessage ?? 'Failed to load articles.',
                      onRetry: () {
                        context.read<ArticlesCubit>().loadArticles();
                      },
                    ),
                    ArticlesStatus.success =>
                      state.articles.isEmpty
                          ? const _EmptyView()
                          : RefreshIndicator(
                            onRefresh: () {
                              return context
                                  .read<ArticlesCubit>()
                                  .loadArticles();
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount:
                                  state.articles.length +
                                  (state.isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, __) {
                                return const SizedBox(height: 14);
                              },
                              itemBuilder: (context, index) {
                                if (index == state.articles.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final article = state.articles[index];

                                return ArticleCard(
                                  article: article,
                                  onTap: () {
                                    context.pushNamed(
                                      AppRouter.articleDetailsName,
                                      extra: article,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ArticlesCubit>().searchArticles(value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              _searchController.clear();
              context.read<ArticlesCubit>().searchArticles('');
              FocusScope.of(context).unfocus();
            },
            icon: const Icon(Icons.close_rounded),
          ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ArticlesCubit, ArticlesState, bool>(
      selector: (state) => state.isOffline,
      builder: (context, isOffline) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: isOffline ? 44 : 0,
          color: Theme.of(context)
              .colorScheme
              .tertiaryContainer,
          alignment: Alignment.center,
          child: isOffline
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'You are offline. Showing saved articles.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiaryContainer,
                  ),
                ),
              ),
            ],
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 72),
            SizedBox(height: 18),
            Text('No articles found.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
