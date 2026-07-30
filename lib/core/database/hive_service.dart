import 'package:hive_flutter/hive_flutter.dart';

import '../../features/articles/data/models/article_model.dart';
import '../../features/notifications/data/models/app_notification_model.dart';

class HiveService {
  HiveService._();

  static const String articlesBoxName = 'articles_box';

  static const String favoritesBoxName = 'favorites_box';

  static const String cacheMetadataBoxName = 'cache_metadata_box';

  static const String notificationsBoxName = 'notifications_box';

  static const String cachedTotalKey = 'cached_total';

  static const String lastUpdateKey = 'last_update';

  static const String settingsBoxName = 'settings_box';

  static late final Box<ArticleModel> articlesBox;

  static late final Box<ArticleModel> favoritesBox;

  static late final Box<dynamic> cacheMetadataBox;

  static late final Box<AppNotificationModel> notificationsBox;

  static bool _isInitialized = false;

  static late final Box<dynamic> settingsBox;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(
        ArticleModelAdapter(),
      );
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(
        AppNotificationModelAdapter(),
      );
    }

    articlesBox = await Hive.openBox<ArticleModel>(
      articlesBoxName,
    );

    favoritesBox = await Hive.openBox<ArticleModel>(
      favoritesBoxName,
    );

    cacheMetadataBox = await Hive.openBox<dynamic>(
      cacheMetadataBoxName,
    );

    notificationsBox =
    await Hive.openBox<AppNotificationModel>(
      notificationsBoxName,
    );

    _isInitialized = true;

    settingsBox = await Hive.openBox<dynamic>(
      settingsBoxName,
    );


  }

  static Future<void> clearArticleCache() async {
    await articlesBox.clear();
    await cacheMetadataBox.clear();
  }

  static Future<void> clearFavorites() async {
    await favoritesBox.clear();
  }

  static Future<void> clearNotifications() async {
    await notificationsBox.clear();
  }
}
