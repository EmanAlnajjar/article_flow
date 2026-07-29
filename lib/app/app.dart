import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = AppRouter.create();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return locator<FavoritesCubit>()
          ..loadFavorites();
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ArticleFlow',
        routerConfig: _router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
      ),
    );
  }
}