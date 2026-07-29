import 'package:hive_flutter/hive_flutter.dart';

import '../../features/articles/data/models/article_model.dart';

class HiveService {
  HiveService._();

  static const String articlesBoxName = 'articles_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String cacheMetadataBoxName = 'cache_metadata_box';

  static const String cachedTotalKey = 'cached_total';
  static const String lastUpdateKey = 'last_update';

  static late final Box<ArticleModel> articlesBox;
  static late final Box<ArticleModel> favoritesBox;
  static late final Box<dynamic> cacheMetadataBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArticleModelAdapter());
    }

    articlesBox = await Hive.openBox<ArticleModel>(articlesBoxName);

    favoritesBox = await Hive.openBox<ArticleModel>(favoritesBoxName);

    cacheMetadataBox = await Hive.openBox<dynamic>(cacheMetadataBoxName);
  }

  static Future<void> clearArticleCache() async {
    await articlesBox.clear();
    await cacheMetadataBox.clear();
  }

  static Future<void> clearFavorites() async {
    await favoritesBox.clear();
  }
}
