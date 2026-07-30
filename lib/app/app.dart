import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/notifications/notification_service.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/auth_state.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/notifications/ presentation/cubit/notifications_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final NotificationService _notificationService;
  late final GoRouter _router;

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  int? _pendingArticleId;

  @override
  void initState() {
    super.initState();

    _authCubit = locator<AuthCubit>();
    _notificationService = locator<NotificationService>();

    final initialLocation =
        _authCubit.state.isAuthenticated
            ? AppRouter.articlesPath
            : AppRouter.signInPath;

    _router = AppRouter.create(initialLocation: initialLocation);

    _notificationSubscription = _notificationService.notificationTapStream
        .listen(_handleNotificationData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingData = _notificationService.takePendingNotificationData();

      if (pendingData != null) {
        _handleNotificationData(pendingData);
      }
    });
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final articleId = int.tryParse(data['articleId']?.toString() ?? '');

    if (type != 'article' || articleId == null || articleId <= 0) {
      return;
    }

    _pendingArticleId = articleId;

    if (_authCubit.state.isAuthenticated) {
      _openPendingArticle();
    }
  }

  void _openPendingArticle() {
    final articleId = _pendingArticleId;

    if (articleId == null) {
      return;
    }

    _pendingArticleId = null;

    _router.pushNamed(
      AppRouter.articleNotificationName,
      pathParameters: {'articleId': articleId.toString()},
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      _router.go(AppRouter.articlesPath);

      if (_pendingArticleId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openPendingArticle();
        });
      }

      return;
    }

    if (state.status == AuthStatus.unauthenticated) {
      _router.go(AppRouter.signInPath);
    }
  }

  @override
  void dispose() {
    unawaited(_notificationSubscription?.cancel());

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
        BlocProvider<NotificationsCubit>(
          create: (_) {
            return locator<NotificationsCubit>();
          },
        ),
        BlocProvider<ThemeCubit>(
          create: (_) {
            return locator<ThemeCubit>();
          },
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },
        listener: _handleAuthState,
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'InkSpire',
              routerConfig: _router,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
            );
          },
        ),
      ),
    );
  }
}
