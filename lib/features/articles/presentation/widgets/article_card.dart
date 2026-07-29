import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/article_entity.dart';

class ArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;
  final bool isFavorite;
  final bool isProcessing;
  final VoidCallback onFavoriteToggle;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.isFavorite,
    required this.isProcessing,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'article-image-${article.id}',
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Container(
                    height: 190,
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    height: 190,
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (article.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          article.tags.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                              backgroundColor: colorScheme.primaryContainer,
                            );
                          }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ArticleInfo(
                        icon: Icons.visibility_outlined,
                        value: '${article.views}',
                      ),
                      const SizedBox(width: 18),
                      _ArticleInfo(
                        icon: Icons.thumb_up_alt_outlined,
                        value: '${article.likes}',
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: isProcessing
                            ? null
                            : onFavoriteToggle,
                        icon: isProcessing
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? colorScheme.tertiary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),

                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleInfo extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ArticleInfo({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}
