import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/use_cases/get_article_by_id_use_case.dart';
import 'article_details_page.dart';

class ArticleNotificationPage extends StatefulWidget {
  final int articleId;

  const ArticleNotificationPage({super.key, required this.articleId});

  @override
  State<ArticleNotificationPage> createState() {
    return _ArticleNotificationPageState();
  }
}

class _ArticleNotificationPageState extends State<ArticleNotificationPage> {
  late Future<ArticleEntity> _articleFuture;

  @override
  void initState() {
    super.initState();

    _loadArticle();
  }

  void _loadArticle() {
    _articleFuture = locator<GetArticleByIdUseCase>()(id: widget.articleId);
  }

  void _retry() {
    setState(_loadArticle);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ArticleEntity>(
      future: _articleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData) {
          return ArticleDetailsPage(article: snapshot.data!);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Article')),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unable to open article',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getErrorMessage(snapshot.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getErrorMessage(Object? error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'The article is unavailable. Check your connection and try again.';
  }
}
