import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/articles/presentation/pages/articles_page.dart';
import '../di/app_dependencies.dart';
import '../../features/articles/domain/entities/article_entity.dart';
import '../../features/articles/presentation/pages/article_details_page.dart';

class AppRouter {
  AppRouter._();


  static const String articlesName = 'articles';

  static const String articlesPath = '/articles';

  static const String articleDetailsName = 'articleDetails';
  static const String articleDetailsPath = '/article-details';

  static GoRouter create({
    required AppDependencies dependencies,
  }) {
    return GoRouter(
      initialLocation: articlesPath,
      routes: [
        GoRoute(
          path: articlesPath,
          name: articlesName,
          builder: (context, state) {
            return BlocProvider(
              create: (_) {
                return dependencies.createArticlesCubit()
                  ..loadArticles();
              },
              child: const ArticlesPage(),
            );
          },
        ),
        GoRoute(
          path: articleDetailsPath,
          name: articleDetailsName,
          builder: (context, state) {
            final article = state.extra;

            if (article is! ArticleEntity) {
              return const Scaffold(
                body: Center(
                  child: Text('Article data is unavailable.'),
                ),
              );
            }

            return ArticleDetailsPage(
              article: article,
            );
          },
        ),
      ],
      errorBuilder: (context, state) {
        return _RouteErrorPage(
          message: state.error?.toString() ??
              'The requested page could not be found.',
        );
      },
    );


  }
}

class _RouteErrorPage extends StatelessWidget {
  final String message;

  const _RouteErrorPage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Page not found',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    context.go(AppRouter.articlesPath);
                  },
                  child: const Text('Back to articles'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}