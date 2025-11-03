import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:injectable/injectable.dart';
import 'package:app_core/src/foundation/domain/entities/notification/entities.dart';
import 'package:app_core/src/infrastructure/notification/contract/notification.dart';
import 'package:timezone/timezone.dart' as tz;

/// Default implementation of LocalNotificationService
///
/// Wraps flutter_local_notifications package following DIP principle
@LazySingleton(as: LocalNotificationService)
class LocalNotificationServiceImpl implements LocalNotificationService {
  final fln.FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<NotificationDataEntity> _notificationTapController =
      StreamController<NotificationDataEntity>.broadcast();

  OnLocalNotificationTappedCallback? _onNotificationTapped;

  /// Creates instance with optional FlutterLocalNotificationsPlugin instance
  ///
  /// If [localNotifications] is not provided, creates new instance
  LocalNotificationServiceImpl({
    fln.FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
            localNotifications ?? fln.FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({
    OnLocalNotificationTappedCallback? onNotificationTapped,
    String? defaultAndroidIcon,
  }) async {
    _onNotificationTapped = onNotificationTapped;

    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Handle notification tap
  Future<void> _onNotificationResponse(
    fln.NotificationResponse response,
  ) async {
    final notification = NotificationDataEntity(
      id: response.id.toString(),
      title: null, // Not available in response
      body: null, // Not available in response
      data: response.payload != null ? {'payload': response.payload} : null,
    );

    _notificationTapController.add(notification);

    if (_onNotificationTapped != null) {
      await _onNotificationTapped!(notification);
    }
  }

  @override
  Future<bool> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    // iOS/macOS
    final iosResult = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: alert,
          badge: badge,
          sound: sound,
        );

    final macosResult = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: alert,
          badge: badge,
          sound: sound,
        );

    // Android 13+ (API 33+)
    final androidResult = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return iosResult ?? macosResult ?? androidResult ?? true;
  }

  @override
  Future<void> show(NotificationConfig config) async {
    await _localNotifications.show(
      config.id,
      config.title,
      config.body,
      _buildNotificationDetails(config),
      payload: config.payload,
    );
  }

  @override
  Future<void> schedule({
    required NotificationConfig config,
    required DateTime scheduledDate,
  }) async {
    await _localNotifications.zonedSchedule(
      config.id,
      config.title,
      config.body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _buildNotificationDetails(config),
      payload: config.payload,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> periodicallyShow({
    required NotificationConfig config,
    required RepeatInterval repeatInterval,
  }) async {
    await _localNotifications.periodicallyShow(
      config.id,
      config.title,
      config.body,
      _convertRepeatInterval(repeatInterval),
      _buildNotificationDetails(config),
      payload: config.payload,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> showDaily({
    required NotificationConfig config,
    required DateTime time,
  }) async {
    await _localNotifications.zonedSchedule(
      config.id,
      config.title,
      config.body,
      _nextInstanceOfTime(time),
      _buildNotificationDetails(config),
      payload: config.payload,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.time,
    );
  }

  @override
  Future<void> showWeekly({
    required NotificationConfig config,
    required int dayOfWeek,
    required DateTime time,
  }) async {
    await _localNotifications.zonedSchedule(
      config.id,
      config.title,
      config.body,
      _nextInstanceOfWeekday(dayOfWeek, time),
      _buildNotificationDetails(config),
      payload: config.payload,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _localNotifications.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  @override
  Future<List<NotificationDataEntity>> getPendingNotificationRequests() async {
    final requests = await _localNotifications.pendingNotificationRequests();

    return requests.map((request) {
      return NotificationDataEntity(
        id: request.id.toString(),
        title: request.title,
        body: request.body,
        data: request.payload != null ? {'payload': request.payload} : null,
      );
    }).toList();
  }

  @override
  Future<List<NotificationDataEntity>> getActiveNotifications() async {
    final notifications = await _localNotifications.getActiveNotifications();

    return notifications.map((notification) {
      return NotificationDataEntity(
        id: notification.id.toString(),
        title: notification.title,
        body: notification.body,
        data: notification.payload != null
            ? {'payload': notification.payload}
            : null,
      );
    }).toList();
  }

  @override
  Future<void> createNotificationChannel({
    required String channelId,
    required String channelName,
    String? channelDescription,
    NotificationImportance importance =
        NotificationImportance.defaultImportance,
    bool playSound = true,
    String? sound,
    bool enableVibration = true,
    List<int>? vibrationPattern,
    bool enableLights = true,
    int? ledColor,
  }) async {
    final androidChannel = fln.AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: _convertImportance(importance),
      playSound: playSound,
      sound:
          sound != null ? fln.RawResourceAndroidNotificationSound(sound) : null,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern != null
          ? Int64List.fromList(vibrationPattern)
          : null,
      enableLights: enableLights,
      ledColor: ledColor != null ? Color(ledColor) : null,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  @override
  Future<void> deleteNotificationChannel(String channelId) async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final android = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    final ios = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    final macos = await _localNotifications
        .resolvePlatformSpecificImplementation<
            fln.MacOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    return android ?? ios?.isEnabled ?? macos?.isEnabled ?? false;
  }

  @override
  Stream<NotificationDataEntity> get onNotificationTap =>
      _notificationTapController.stream;

  /// Build notification details from config
  fln.NotificationDetails _buildNotificationDetails(NotificationConfig config) {
    return fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        config.channelId ?? 'default_channel',
        config.channelName ?? 'Default Channel',
        channelDescription: config.channelDescription,
        importance: _convertImportance(
          config.importance ?? NotificationImportance.defaultImportance,
        ),
        priority: _convertPriority(
          config.priority ?? NotificationPriority.defaultPriority,
        ),
        playSound: config.playSound ?? true,
        sound: config.sound != null
            ? fln.RawResourceAndroidNotificationSound(config.sound!)
            : null,
        enableVibration: config.enableVibration ?? true,
        vibrationPattern: config.vibrationPattern != null
            ? Int64List.fromList(config.vibrationPattern!)
            : null,
        enableLights: config.enableLights ?? true,
        color: config.ledColor != null ? Color(config.ledColor!) : null,
        groupKey: config.groupKey,
        setAsGroupSummary: config.setAsGroupSummary ?? false,
        ongoing: config.ongoing ?? false,
        autoCancel: config.autoCancel ?? true,
        showWhen: config.showWhen ?? true,
        when: config.timestamp,
      ),
      iOS: fln.DarwinNotificationDetails(
        sound: config.sound,
        presentAlert: true,
        presentBadge: config.showBadge ?? true,
        presentSound: config.playSound ?? true,
        badgeNumber: config.badgeNumber,
        categoryIdentifier: config.category,
        threadIdentifier: config.threadIdentifier,
      ),
      macOS: fln.DarwinNotificationDetails(
        sound: config.sound,
        presentAlert: true,
        presentBadge: config.showBadge ?? true,
        presentSound: config.playSound ?? true,
        badgeNumber: config.badgeNumber,
        categoryIdentifier: config.category,
        threadIdentifier: config.threadIdentifier,
      ),
    );
  }

  /// Convert custom importance to plugin importance
  fln.Importance _convertImportance(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.none:
        return fln.Importance.none;
      case NotificationImportance.min:
        return fln.Importance.min;
      case NotificationImportance.low:
        return fln.Importance.low;
      case NotificationImportance.defaultImportance:
        return fln.Importance.defaultImportance;
      case NotificationImportance.high:
        return fln.Importance.high;
      case NotificationImportance.max:
        return fln.Importance.max;
      case NotificationImportance.unspecified:
        return fln.Importance.unspecified;
    }
  }

  /// Convert custom priority to plugin priority
  fln.Priority _convertPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return fln.Priority.min;
      case NotificationPriority.low:
        return fln.Priority.low;
      case NotificationPriority.defaultPriority:
        return fln.Priority.defaultPriority;
      case NotificationPriority.high:
        return fln.Priority.high;
      case NotificationPriority.max:
        return fln.Priority.max;
    }
  }

  /// Convert custom repeat interval to plugin repeat interval
  fln.RepeatInterval _convertRepeatInterval(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.everyMinute:
        return fln.RepeatInterval.everyMinute;
      case RepeatInterval.hourly:
        return fln.RepeatInterval.hourly;
      case RepeatInterval.daily:
        return fln.RepeatInterval.daily;
      case RepeatInterval.weekly:
        return fln.RepeatInterval.weekly;
    }
  }

  /// Get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Get next instance of a specific weekday and time
  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, DateTime time) {
    var scheduledDate = _nextInstanceOfTime(time);

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Dispose resources
  void dispose() {
    _notificationTapController.close();
  }
}
