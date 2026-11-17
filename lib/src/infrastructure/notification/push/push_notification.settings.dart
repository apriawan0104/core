import 'package:flutter/material.dart';

/// Values a project supplies to the reusable push engine.
///
/// Topic prefixes, sound, channel names, icon, color, and the payload keys the
/// engine reads for title, body, and sound. Route names and payload-to-screen
/// rules are not here. The app reads them in its tap callback.
class PushNotificationSettings {
  const PushNotificationSettings({
    required this.generalTopic,
    required this.moduleTopicPrefix,
    required this.defaultSound,
    required this.iosSoundExtension,
    required this.extraSounds,
    required this.defaultAndroidChannelId,
    required this.soundChannelPrefix,
    required this.androidChannelName,
    required this.androidChannelDescription,
    required this.notificationIcon,
    required this.notificationColor,
    required this.soundField,
    required this.titleField,
    required this.bodyField,
    this.storagePrefix = 'push',
    this.androidApiKey = '',
    this.androidAppId = '',
    this.androidMessagingSenderId = '',
    this.androidProjectId = '',
    this.iosApiKey = '',
    this.iosAppId = '',
    this.iosMessagingSenderId = '',
    this.iosProjectId = '',
    this.iosBundleId = '',
  });

  final String generalTopic;
  final String moduleTopicPrefix;
  final String defaultSound;
  final String iosSoundExtension;
  final List<String> extraSounds;
  final String defaultAndroidChannelId;
  final String soundChannelPrefix;
  final String androidChannelName;
  final String androidChannelDescription;
  final String notificationIcon;
  final Color notificationColor;

  /// Payload key for the sound name.
  final String soundField;

  /// Payload key for the title when the notification block is missing.
  final String titleField;

  /// Payload key for the body when the notification block is missing.
  final String bodyField;

  /// Prefix for the audience keys stored on the device.
  final String storagePrefix;

  final String androidApiKey;
  final String androidAppId;
  final String androidMessagingSenderId;
  final String androidProjectId;
  final String iosApiKey;
  final String iosAppId;
  final String iosMessagingSenderId;
  final String iosProjectId;
  final String iosBundleId;
}
