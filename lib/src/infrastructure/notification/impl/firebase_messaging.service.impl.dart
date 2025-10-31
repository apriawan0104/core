import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

import '../../../helpers/helpers.dart';
import '../constants/constants.dart';
import '../contract/firebase_messaging.service.dart';

@LazySingleton(as: FirebaseMessagingService)
class FirebaseMessagingServiceImpl extends FirebaseMessagingService {
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  FirebaseRemoteConfig get _firebaseRemoteConfig =>
      FirebaseRemoteConfig.instance;

  bool? _isInitialized;

  @override
  Future<bool> init({
    required void Function(RemoteMessage?) initialAction,
    required void Function(RemoteMessage) notificationAction,
    required void Function(RemoteMessage) messageAction,
    required void Function(RemoteMessage) backgroundAction,
    required void Function() onNotificationPermissionDenied,
  }) async {
    final isPermissionGranted = await requestPermission(
      onPermissionDenied: onNotificationPermissionDenied,
    );

    if (isPermissionGranted && (_isInitialized ?? false)) {
      return true;
    }

    final fcmToken = await getToken();

    if (fcmToken != null) {
      // TODO: Save to storage
    }

    logger.i('FCM Token: ${fcmToken ?? '-'}');

    unawaited(
      _firebaseMessaging.getInitialMessage().then(
            initialAction,
          ),
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      notificationAction,
    );

    FirebaseMessaging.onMessage.listen(
      messageAction,
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    return _isInitialized ??= await _isFirebaseMessagingAuthorized();
  }

  @override
  Future<bool> requestPermission({
    void Function()? onPermissionDenied,
  }) async {
    try {
      final notificationSettings = await _firebaseMessaging.requestPermission();

      final isAuthorized = notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized;

      // Check feature flag before showing the settings dialog
      final enableForceNotificationPermission = _firebaseRemoteConfig.getBool(
        SharedFirebaseRemoteConfigConstant.enableForceNotificationPermission,
      );

      if (!isAuthorized && enableForceNotificationPermission) {
        onPermissionDenied?.call();
      }

      return isAuthorized || !enableForceNotificationPermission;
    } catch (e, stackTrace) {
      logger.e(
        'Error while requesting firebase notification permission',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return false;
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e, stackTrace) {
      logger.e(
        'Error while getting firebase token',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return null;
  }

  Future<bool> _isFirebaseMessagingAuthorized() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    final isNotificationEnabled =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    return isNotificationEnabled;
  }

  @override
  Future<void> subscribeToTopic(String topic) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.i('Firebase message background: ${message.toMap()}');
}
