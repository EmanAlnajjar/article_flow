import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../ network/network_info.dart';
import '../../features/articles/data/data_sources/article_local_data_source.dart';
import '../../features/articles/data/data_sources/article_local_data_source_impl.dart';
import '../../features/articles/data/data_sources/article_remote_data_source.dart';
import '../../features/articles/data/data_sources/article_remote_data_source_impl.dart';
import '../../features/articles/data/repositories/article_repository_impl.dart';
import '../../features/articles/domain/repositories/article_repository.dart';
import '../../features/articles/domain/use_cases/get_article_by_id_use_case.dart';
import '../../features/articles/domain/use_cases/get_articles_use_case.dart';
import '../../features/articles/domain/use_cases/search_articles_use_case.dart';
import '../../features/articles/presentation/cubit/articles_cubit.dart';
import '../../features/authentication/data/data_sources/auth_remote_data_source.dart';
import '../../features/authentication/data/data_sources/auth_remote_data_source_impl.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/use_cases/auth_use_cases.dart';
import '../../features/authentication/presentation/cubit/auth_cubit.dart';
import '../../features/favorites/data/data_sources/favorite_local_data_source.dart';
import '../../features/favorites/data/data_sources/favorite_local_data_source_impl.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/domain/use_cases/favorite_use_cases.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/notifications/ presentation/cubit/notifications_cubit.dart';
import '../api/api_client.dart';
import '../database/hive_service.dart';

import '../notifications/notification_service.dart';

import '../../features/notifications/data/data_sources/notification_local_data_source.dart';
import '../../features/notifications/data/data_sources/notification_local_data_source_impl.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/use_cases/notification_use_cases.dart';
import '../theme/theme_cubit.dart';



final locator = GetIt.instance;

void setupLocator() {
  _registerCore();
  _registerArticles();
  _registerFavorites();
  _registerNotifications();
  _registerAuthentication();
}

void _registerCore() {
  locator.registerLazySingleton<Dio>(Dio.new);

  locator.registerLazySingleton<ApiClient>(() => ApiClient(locator<Dio>()));

  locator.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);

  locator.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );

  locator.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );

  locator.registerLazySingleton<NotificationService>(
        () => NotificationService(
      firebaseMessaging: locator<FirebaseMessaging>(),
      localNotifications:
      locator<FlutterLocalNotificationsPlugin>(),
      saveNotificationUseCase:
      locator<SaveNotificationUseCase>(),
      markNotificationAsReadUseCase:
      locator<MarkNotificationAsReadUseCase>(),
    ),
  );

  locator.registerFactory<ThemeCubit>(
        () => ThemeCubit(
      settingsBox: HiveService.settingsBox,
    ),
  );
}

void _registerArticles() {
  locator.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(apiClient: locator<ApiClient>()),
  );

  locator.registerLazySingleton<ArticleLocalDataSource>(
    () => ArticleLocalDataSourceImpl(
      articlesBox: HiveService.articlesBox,
      metadataBox: HiveService.cacheMetadataBox,
    ),
  );

  locator.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      remoteDataSource: locator<ArticleRemoteDataSource>(),
      localDataSource: locator<ArticleLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<GetArticlesUseCase>(
    () => GetArticlesUseCase(locator<ArticleRepository>()),
  );

  locator.registerLazySingleton<GetArticleByIdUseCase>(
    () => GetArticleByIdUseCase(locator<ArticleRepository>()),
  );

  locator.registerLazySingleton<SearchArticlesUseCase>(
    () => SearchArticlesUseCase(locator<ArticleRepository>()),
  );

  locator.registerFactory<ArticlesCubit>(
    () => ArticlesCubit(
      getArticlesUseCase: locator<GetArticlesUseCase>(),
      searchArticlesUseCase: locator<SearchArticlesUseCase>(),
      networkInfo: locator<NetworkInfo>(),
    ),
  );
}

void _registerFavorites() {
  locator.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSourceImpl(favoritesBox: HiveService.favoritesBox),
  );

  locator.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      localDataSource: locator<FavoriteLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(locator<FavoriteRepository>()),
  );

  locator.registerLazySingleton<IsFavoriteUseCase>(
    () => IsFavoriteUseCase(locator<FavoriteRepository>()),
  );

  locator.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(locator<FavoriteRepository>()),
  );

  locator.registerLazySingleton<ClearFavoritesUseCase>(
    () => ClearFavoritesUseCase(locator<FavoriteRepository>()),
  );

  locator.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      getFavoritesUseCase: locator<GetFavoritesUseCase>(),
      isFavoriteUseCase: locator<IsFavoriteUseCase>(),
      toggleFavoriteUseCase: locator<ToggleFavoriteUseCase>(),
      clearFavoritesUseCase: locator<ClearFavoritesUseCase>(),
    ),
  );
}

void _registerNotifications() {
  locator.registerLazySingleton<
      NotificationLocalDataSource>(
        () => NotificationLocalDataSourceImpl(
      notificationsBox:
      HiveService.notificationsBox,
    ),
  );

  locator.registerLazySingleton<
      NotificationRepository>(
        () => NotificationRepositoryImpl(
      localDataSource:
      locator<NotificationLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<
      WatchNotificationsUseCase>(
        () => WatchNotificationsUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      GetNotificationsUseCase>(
        () => GetNotificationsUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      SaveNotificationUseCase>(
        () => SaveNotificationUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      MarkNotificationAsReadUseCase>(
        () => MarkNotificationAsReadUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      MarkAllNotificationsAsReadUseCase>(
        () => MarkAllNotificationsAsReadUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      DeleteNotificationUseCase>(
        () => DeleteNotificationUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerLazySingleton<
      ClearNotificationsUseCase>(
        () => ClearNotificationsUseCase(
      locator<NotificationRepository>(),
    ),
  );

  locator.registerFactory<NotificationsCubit>(
        () => NotificationsCubit(
      watchNotificationsUseCase:
      locator<WatchNotificationsUseCase>(),
      markNotificationAsReadUseCase:
      locator<
          MarkNotificationAsReadUseCase
      >(),
      markAllNotificationsAsReadUseCase:
      locator<
          MarkAllNotificationsAsReadUseCase
      >(),
      deleteNotificationUseCase:
      locator<DeleteNotificationUseCase>(),
      clearNotificationsUseCase:
      locator<ClearNotificationsUseCase>(),
    ),
  );
}

void _registerAuthentication() {
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  locator.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: locator<FirebaseAuth>(),
      googleSignIn: locator<GoogleSignIn>(),
    ),
  );

  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: locator<AuthRemoteDataSource>()),
  );

  locator.registerLazySingleton<WatchAuthStateUseCase>(
    () => WatchAuthStateUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SignInWithEmailAndPasswordUseCase>(
    () => SignInWithEmailAndPasswordUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<CreateUserWithEmailAndPasswordUseCase>(
    () => CreateUserWithEmailAndPasswordUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(locator<AuthRepository>()),
  );

  locator.registerFactory<AuthCubit>(
    () => AuthCubit(
      watchAuthStateUseCase: locator<WatchAuthStateUseCase>(),
      getCurrentUserUseCase: locator<GetCurrentUserUseCase>(),
      signInWithGoogleUseCase: locator<SignInWithGoogleUseCase>(),
      signInWithEmailAndPasswordUseCase:
          locator<SignInWithEmailAndPasswordUseCase>(),
      createUserWithEmailAndPasswordUseCase:
          locator<CreateUserWithEmailAndPasswordUseCase>(),
      sendPasswordResetEmailUseCase: locator<SendPasswordResetEmailUseCase>(),
      signOutUseCase: locator<SignOutUseCase>(),
    ),
  );
}
