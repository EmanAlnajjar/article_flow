import 'package:equatable/equatable.dart';

import 'article_entity.dart';

class ArticlePageEntity extends Equatable {
  final List<ArticleEntity> articles;
  final int total;
  final int skip;
  final int limit;

  const ArticlePageEntity({
    required this.articles,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + articles.length < total;

  @override
  List<Object?> get props => [articles, total, skip, limit];
}
