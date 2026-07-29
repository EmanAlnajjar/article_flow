import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/auth_state.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authCubit = locator<AuthCubit>();

    final initialLocation =
        _authCubit.state.isAuthenticated
            ? AppRouter.articlesPath
            : AppRouter.signInPath;

    _router = AppRouter.create(initialLocation: initialLocation);
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      _router.go(AppRouter.articlesPath);
      return;
    }

    if (state.status == AuthStatus.unauthenticated) {
      _router.go(AppRouter.signInPath);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    unawaited(_authCubit.close());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<FavoritesCubit>(
          create: (_) {
            return locator<FavoritesCubit>()..loadFavorites();
          },
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },
        listener: _handleAuthState,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ArticleFlow',
          routerConfig: _router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
