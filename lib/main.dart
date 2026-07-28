import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/di/app_dependencies.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies.create();

  final router = AppRouter.create(
    dependencies: dependencies,
  );

  runApp(
    MyApp(router: router),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ArticleFlow',
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
    );
  }
}