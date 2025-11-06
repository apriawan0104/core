import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import 'package:app_core/src/errors/errors.dart';
import 'package:app_core/src/foundation/domain/entities/notification/entities.dart';
import 'package:app_core/src/infrastructure/notification/contract/notification.dart';

/// Default implementation of FirebaseMessagingService
///
/// Wraps firebase_messaging package following DIP principle
@LazySingleton(as: FirebaseMessagingService)
class FirebaseMessagingServiceImpl implements FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging;

  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  final StreamController<NotificationDataEntity> _notificationTapController =
      StreamController<NotificationDataEntity>.broadcast();
  final StreamController<NotificationDataEntity>
      _foregroundNotificationController =
      StreamController<NotificationDataEntity>.broadcast();

  OnNotificationTappedCallback? _onNotificationTapped;
  OnForegroundNotificationCallback? _onForegroundNotification;
  OnBackgroundNotificationCallback? _onBackgroundNotification;

  /// Creates instance with optional FirebaseMessaging instance
  ///
  /// If [firebaseMessaging] is not provided, uses default instance
  FirebaseMessagingServiceImpl({
    FirebaseMessaging? firebaseMessaging,
  }) : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<Either<NotificationFailure, void>> initialize({
    OnNotificationTappedCallback? onNotificationTapped,
    OnForegroundNotificationCallback? onForegroundNotification,
    OnBackgroundNotificationCallback? onBackgroundNotification,
    bool autoInitEnabled = true,
  }) async {
    try {
      _onNotificationTapped = onNotificationTapped;
      _onForegroundNotification = onForegroundNotification;
      _onBackgroundNotification = onBackgroundNotification;

      // Set auto-init
      await _firebaseMessaging.setAutoInitEnabled(autoInitEnabled);

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _tokenRefreshController.add(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = _convertToNotificationEntity(message);
        _foregroundNotificationController.add(notification);

        if (_onForegroundNotification != null) {
          await _onForegroundNotification!(notification);
        }
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        final notification = _convertToNotificationEntity(message);
        _notificationTapController.add(notification);

        if (_onNotificationTapped != null) {
          await _onNotificationTapped!(notification);
        }
      });

      // Handle background messages (if callback provided)
      if (_onBackgroundNotification != null) {
        FirebaseMessaging.onBackgroundMessage(
          _backgroundMessageHandler,
        );
      }

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        NotificationInitializationFailure(
          message: 'Failed to initialize Firebase Messaging: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  /// Background message handler
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    // Note: This is a static handler as required by firebase_messaging
    // Consumer apps should register their own background handler if needed
    // using FirebaseMessaging.onBackgroundMessage directly
  }

  @override
  Future<Either<NotificationFailure, bool>> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: alert,
        announcement: announcement,
        badge: badge,
        carPlay: carPlay,
        criticalAlert: criticalAlert,
        provisional: provisional,
        sound: sound,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      return Right(granted);
    } catch (e, stackTrace) {
      return Left(
        NotificationPermissionDeniedFailure(
          message: 'Failed to request notification permission: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, String>> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        return const Left(
          NotificationTokenFailure(
            message: 'FCM token is null',
          ),
        );
      }
      return Right(token);
    } catch (e, stackTrace) {
      return Left(
        NotificationTokenFailure(
          message: 'Failed to get FCM token: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        NotificationTokenFailure(
          message: 'Failed to delete FCM token: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        NotificationTopicFailure(
          message: 'Failed to subscribe to topic "$topic": ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'topic': topic},
        ),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, void>> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        NotificationTopicFailure(
          message: 'Failed to unsubscribe from topic "$topic": ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'topic': topic},
        ),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationDataEntity?>>
      getInitialNotification() async {
    try {
      final message = await _firebaseMessaging.getInitialMessage();
      if (message == null) {
        return const Right(null);
      }

      return Right(_convertToNotificationEntity(message));
    } catch (e, stackTrace) {
      return Left(
        UnknownNotificationFailure(
          message: 'Failed to get initial notification: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<NotificationDataEntity> get onNotificationTap =>
      _notificationTapController.stream;

  @override
  Stream<NotificationDataEntity> get onForegroundNotification =>
      _foregroundNotificationController.stream;

  @override
  bool get isSupported =>
      true; // firebase_messaging supports all major platforms

  @override
  Future<Either<NotificationFailure, void>> setAutoInitEnabled(
      bool enabled) async {
    try {
      await _firebaseMessaging.setAutoInitEnabled(enabled);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        UnknownNotificationFailure(
          message: 'Failed to set auto-init enabled: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  bool isAutoInitEnabled() {
    return _firebaseMessaging.isAutoInitEnabled;
  }

  @override
  Future<Either<NotificationFailure, void>> setDeliveryMetricsExportToBigQuery(
      bool enabled) async {
    try {
      await _firebaseMessaging.setDeliveryMetricsExportToBigQuery(enabled);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        UnknownNotificationFailure(
          message:
              'Failed to set delivery metrics export: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  /// Convert RemoteMessage to NotificationDataEntity
  NotificationDataEntity _convertToNotificationEntity(RemoteMessage message) {
    return NotificationDataEntity(
      id: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      channelId: message.notification?.android?.channelId,
      sound: message.notification?.android?.sound ??
          message.notification?.apple?.sound?.name,
      badge: message.notification?.apple?.badge != null
          ? int.tryParse(message.notification!.apple!.badge.toString())
          : null,
      timestamp: message.sentTime,
    );
  }

  /// Dispose resources
  void dispose() {
    _tokenRefreshController.close();
    _notificationTapController.close();
    _foregroundNotificationController.close();
  }
}
