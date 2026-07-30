import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/notifications/data/data_sources/notification_local_data_source_impl.dart';
import '../../features/notifications/data/models/app_notification_model.dart';
import '../../features/notifications/domain/use_cases/notification_use_cases.dart';
import '../../firebase_options.dart';
import '../database/hive_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationsBox =
  await _openBackgroundNotificationsBox();

  final localDataSource =
  NotificationLocalDataSourceImpl(
    notificationsBox: notificationsBox,
  );

  await localDataSource.saveNotification(
    notification: _createNotificationModel(
      message,
      isRead: false,
    ),
  );

  debugPrint(
    'Background notification saved: '
        '${message.messageId}',
  );
}

Future<Box<AppNotificationModel>>
_openBackgroundNotificationsBox() async {
  if (Hive.isBoxOpen(
    HiveService.notificationsBoxName,
  )) {
    return Hive.box<AppNotificationModel>(
      HiveService.notificationsBoxName,
    );
  }

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(
      AppNotificationModelAdapter(),
    );
  }

  return Hive.openBox<AppNotificationModel>(
    HiveService.notificationsBoxName,
  );
}

AppNotificationModel _createNotificationModel(
    RemoteMessage message, {
      required bool isRead,
    }) {
  final data = message.data;
  final notification = message.notification;

  final articleId = int.tryParse(
    data['articleId']?.toString() ?? '',
  );

  final fallbackId =
      '${DateTime.now().microsecondsSinceEpoch}'
      '-${data.hashCode}';

  return AppNotificationModel(
    id: message.messageId ?? fallbackId,
    title:
    notification?.title ??
        data['title']?.toString() ??
        'ArticleFlow',
    body:
    notification?.body ??
        data['body']?.toString() ??
        'You have a new update.',
    type:
    data['type']?.toString() ?? 'general',
    articleId: articleId,
    receivedAt:
    message.sentTime ?? DateTime.now(),
    isRead: isRead,
  );
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin
  _localNotifications;

  final SaveNotificationUseCase
  _saveNotificationUseCase;

  final MarkNotificationAsReadUseCase
  _markNotificationAsReadUseCase;

  final StreamController<Map<String, dynamic>>
  _notificationTapController =
  StreamController<Map<String, dynamic>>.broadcast();

  Map<String, dynamic>? _pendingNotificationData;
  bool _isInitialized = false;

  static const String channelId =
      'article_flow_notifications';

  static const String channelName =
      'ArticleFlow Notifications';

  static const String channelDescription =
      'Notifications about new articles and updates.';

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
  );

  NotificationService({
    required FirebaseMessaging firebaseMessaging,
    required FlutterLocalNotificationsPlugin
    localNotifications,
    required SaveNotificationUseCase
    saveNotificationUseCase,
    required MarkNotificationAsReadUseCase
    markNotificationAsReadUseCase,
  }) : _firebaseMessaging = firebaseMessaging,
        _localNotifications = localNotifications,
        _saveNotificationUseCase =
            saveNotificationUseCase,
        _markNotificationAsReadUseCase =
            markNotificationAsReadUseCase;

  Stream<Map<String, dynamic>>
  get notificationTapStream {
    return _notificationTapController.stream;
  }

  Map<String, dynamic>?
  takePendingNotificationData() {
    final data = _pendingNotificationData;
    _pendingNotificationData = null;

    return data;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    await _initializeLocalNotifications();
    await _requestPermission();
    await _configureForegroundNotifications();

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        unawaited(
          _handleFirebaseNotificationOpened(
            message,
          ),
        );
      },
    );

    final initialMessage =
    await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      await _handleFirebaseNotificationOpened(
        initialMessage,
      );
    }

    await _printToken();
  }

  Future<void>
  _initializeLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings =
    DarwinInitializationSettings();

    const initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
      _handleLocalNotificationOpened,
    );

    if (!kIsWeb &&
        defaultTargetPlatform ==
            TargetPlatform.android) {
      final androidPlugin =
      _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();

      await androidPlugin
          ?.createNotificationChannel(
        _channel,
      );
    }
  }

  Future<void> _requestPermission() async {
    final settings =
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission: '
          '${settings.authorizationStatus}',
    );
  }

  Future<void>
  _configureForegroundNotifications() async {
    await _firebaseMessaging
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    final storedNotification =
    _createNotificationModel(
      message,
      isRead: false,
    );

    await _saveNotificationUseCase(
      notification: storedNotification,
    );

    debugPrint(
      'Foreground notification saved: '
          '${message.messageId}',
    );

    if (kIsWeb ||
        defaultTargetPlatform !=
            TargetPlatform.android) {
      return;
    }

    final payload = Map<String, dynamic>.from(
      message.data,
    );

    payload['notificationId'] =
        storedNotification.id;

    await _localNotifications.show(
      storedNotification.id.hashCode,
      storedNotification.title,
      storedNotification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription:
          channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  Future<void>
  _handleFirebaseNotificationOpened(
      RemoteMessage message,
      ) async {
    final storedNotification =
    _createNotificationModel(
      message,
      isRead: true,
    );

    await _saveNotificationUseCase(
      notification: storedNotification,
    );

    final data = Map<String, dynamic>.from(
      message.data,
    );

    data['notificationId'] =
        storedNotification.id;

    debugPrint(
      'FCM notification opened: $data',
    );

    _dispatchNotificationData(data);
  }

  void _handleLocalNotificationOpened(
      NotificationResponse response,
      ) {
    unawaited(
      _processLocalNotificationOpened(
        response,
      ),
    );
  }

  Future<void>
  _processLocalNotificationOpened(
      NotificationResponse response,
      ) async {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decodedPayload = jsonDecode(payload);

      if (decodedPayload is! Map) {
        return;
      }

      final data = Map<String, dynamic>.from(
        decodedPayload,
      );

      final notificationId =
      data['notificationId']?.toString();

      if (notificationId != null &&
          notificationId.isNotEmpty) {
        await _markNotificationAsReadUseCase(
          id: notificationId,
        );
      }

      debugPrint(
        'Local notification opened: $data',
      );

      _dispatchNotificationData(data);
    } catch (exception) {
      debugPrint(
        'Invalid notification payload: '
            '$exception',
      );
    }
  }

  void _dispatchNotificationData(
      Map<String, dynamic> data,
      ) {
    if (data.isEmpty) {
      return;
    }

    if (_notificationTapController.hasListener) {
      _notificationTapController.add(data);
      return;
    }

    _pendingNotificationData = data;
  }

  Future<void> _printToken() async {
    try {
      final token =
      await _firebaseMessaging.getToken();

      debugPrint('FCM TOKEN: $token');
    } catch (exception) {
      debugPrint(
        'Unable to get FCM token: $exception',
      );
    }
  }
}