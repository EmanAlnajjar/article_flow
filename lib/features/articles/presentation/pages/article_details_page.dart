import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/article_entity.dart';

class ArticleDetailsPage extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            actions: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  final favorite = state.isFavorite(article.id);
                  final processing = state.isProcessing(article.id);

                  return IconButton.filledTonal(
                    tooltip: favorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: processing
                        ? null
                        : () {
                      context
                          .read<FavoritesCubit>()
                          .toggleFavorite(article);
                    },
                    icon: processing
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite
                          ? Theme.of(context)
                          .colorScheme
                          .tertiary
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'article-image-${article.id}',
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined, size: 64),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _DetailsInfo(
                        icon: Icons.visibility_outlined,
                        label: '${article.views} views',
                      ),
                      const SizedBox(width: 20),
                      _DetailsInfo(
                        icon: Icons.thumb_up_alt_outlined,
                        label: '${article.likes} likes',
                      ),
                      const SizedBox(width: 20),
                      _DetailsInfo(
                        icon: Icons.thumb_down_alt_outlined,
                        label: '${article.dislikes}',
                      ),
                    ],
                  ),
                  if (article.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          article.tags.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              side: BorderSide.none,
                              backgroundColor: colorScheme.primaryContainer,
                            );
                          }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 20),
                  Text(
                    'About this article',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailsInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
