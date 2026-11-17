import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_notification.settings.dart';
import 'push_platform.dart';
import 'push_sound.dart';

/// Shows a notification while the app is in the foreground, and for data-only
/// messages that the OS will not display by itself.
///
/// This presenter owns its own plugin instance. Do not also initialize
/// `LocalNotificationService` in the same app, or the two plugins can replace
/// each other's tap callback.
abstract final class PushNotificationPresenter {
  static final plugin = FlutterLocalNotificationsPlugin();
  static void Function(String payload)? onOpened;
  static var _ready = false;

  static Future<void> initialize(PushNotificationSettings settings) async {
    if (PushPlatform.isWeb || _ready) return;

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(settings.notificationIcon),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        onOpened?.call(payload);
      },
    );
    await ensureChannels(settings);
    _ready = true;
  }

  static Future<void> ensureChannels(PushNotificationSettings settings) async {
    final sounds = <String>{
      pushSystemSound,
      resolvePushSound(settings, const {}),
      ...settings.extraSounds,
    };
    for (final sound in sounds) {
      await _ensureChannel(settings, sound);
    }
  }

  static Future<void> showRemote(
    RemoteMessage message,
    PushNotificationSettings settings,
  ) async {
    if (PushPlatform.isWeb) return;
    await initialize(settings);

    final title =
        message.notification?.title ?? message.data[settings.titleField];
    final body = message.notification?.body ?? message.data[settings.bodyField];
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final sound = resolvePushSound(
      settings,
      message.data,
      platformSound: message.notification?.android?.sound,
    );
    await _ensureChannel(settings, sound);

    final payload = Map<String, dynamic>.from(message.data);
    final messageId = message.messageId;
    if (messageId != null) payload['_messageId'] = messageId;

    final channelName = sound == pushSystemSound
        ? settings.androidChannelName
        : '${settings.androidChannelName} $sound';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelIdForSound(settings, sound),
        channelName,
        channelDescription: settings.androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: settings.notificationIcon,
        color: settings.notificationColor,
        sound: sound == pushSystemSound
            ? null
            : RawResourceAndroidNotificationSound(sound),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: sound == pushSystemSound ? null : iosSoundName(settings, sound),
      ),
    );

    await plugin.show(
      _notificationId(message),
      title,
      body,
      details,
      payload: jsonEncode(payload),
    );
  }

  static Future<void> _ensureChannel(
    PushNotificationSettings settings,
    String sound,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    final channelName = sound == pushSystemSound
        ? settings.androidChannelName
        : '${settings.androidChannelName} $sound';
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        androidChannelIdForSound(settings, sound),
        channelName,
        description: settings.androidChannelDescription,
        importance: Importance.high,
        sound: sound == pushSystemSound
            ? null
            : RawResourceAndroidNotificationSound(sound),
      ),
    );
  }

  static int _notificationId(RemoteMessage message) {
    final source =
        message.messageId ??
        message.sentTime?.millisecondsSinceEpoch.toString() ??
        message.data.toString();
    return source.hashCode & 0x7fffffff;
  }
}
