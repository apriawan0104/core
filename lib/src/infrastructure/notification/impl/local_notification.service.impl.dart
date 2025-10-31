import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../../foundation/domain/entities/notification/entities.dart';
import '../../../helpers/helpers.dart';
// import '../../../constants/notification.constant.dart';
// import '../../../utilities/helpers/notification.helper.dart';
import '../constants/constants.dart';
import '../contract/local_notification.service.dart';
import '../helper/helper.dart';

@LazySingleton(as: LocalNotificationService)
class LocalNotificationServiceImpl extends LocalNotificationService {
  LocalNotificationServiceImpl({
    required this.flutterLocalNotificationsPlugin,
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  late AndroidNotificationDetails androidNotificationDetails;
  late DarwinNotificationDetails darwinNotificationDetails;

  @override
  Future<void> init({
    required void Function(NotificationData) notificationAction,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  }) async {
    try {
      await _initializeLocalNotification(
        notificationAction: notificationAction,
      );

      await _configureNotificationPlatformDetails();
    } catch (e, stackTrace) {
      logger.e(
        'Error while initializing local notification service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    bool? isGranted;

    try {
      if (Platform.isAndroid) {
        isGranted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        isGranted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e, stackTrace) {
      logger.e(
        'Error while requesting notification permissions',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return isGranted ?? false;
  }

  @override
  Future<void> showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error while showing notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeLocalNotification({
    required void Function(NotificationData) notificationAction,
  }) async {
    const androidInitializationSettings = AndroidInitializationSettings(
      'ic_notification',
    );
    final darwinInitializationSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        _onDidReceiveLocalNotification(
          notificationAction: notificationAction,
          id: id,
          title: title,
          body: body,
          payload: payload,
        );
      },
    );
    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        _onDidReceiveNotificationResponse(
          notificationResponse: notificationResponse,
          notificationAction: notificationAction,
        );
      },
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );
  }

  Future<void> _configureNotificationPlatformDetails({
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  }) async {
    androidNotificationDetails = AndroidNotificationDetails(
      androidChannelId ?? NotificationConstant.defaultAndroidChannelId,
      androidChannelName ?? NotificationConstant.defaultAndroidChannelName,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      visibility: NotificationVisibility.public,
      channelDescription: androidChannelDescription ??
          NotificationConstant.defaultAndroidChannelDescription,
      icon: 'ic_notification',
      color: const Color(0xFF08A94C),
    );
    darwinNotificationDetails = const DarwinNotificationDetails();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            androidNotificationDetails.channelId,
            androidNotificationDetails.channelName,
            description: androidNotificationDetails.channelDescription,
            importance: androidNotificationDetails.importance,
          ),
        );
  }

  Future<void> _onDidReceiveNotificationResponse({
    required NotificationResponse notificationResponse,
    required void Function(NotificationData) notificationAction,
  }) async {
    _handleNotificationAction(
      payload: notificationResponse.payload,
      notificationAction: notificationAction,
    );
  }

  Future<void> _onDidReceiveLocalNotification({
    required void Function(NotificationData) notificationAction,
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    _handleNotificationAction(
      payload: payload,
      notificationAction: notificationAction,
    );
  }

  void _handleNotificationAction({
    required String? payload,
    required void Function(NotificationData) notificationAction,
  }) {
    final notificationData = NotificationHelper.parseNotificationData(payload);

    if (notificationData != null) {
      notificationAction(notificationData);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  // TODO: Implement background notification response
  logger.i(
    'Background Notification: $notificationResponse',
    time: DateTime.now(),
  );
}
