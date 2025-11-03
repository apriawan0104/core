/// Constants for notification service
class NotificationConstants {
  NotificationConstants._();

  /// Default notification channel ID for Android
  static const String defaultChannelId = 'default_notification_channel';

  /// Default notification channel name for Android
  static const String defaultChannelName = 'Default Notifications';

  /// Default notification channel description for Android
  static const String defaultChannelDescription =
      'Default channel for general notifications';

  /// High priority notification channel ID for Android
  static const String highPriorityChannelId = 'high_priority_channel';

  /// High priority notification channel name for Android
  static const String highPriorityChannelName = 'High Priority';

  /// High priority notification channel description for Android
  static const String highPriorityChannelDescription =
      'Channel for high priority notifications';

  /// Default notification icon for Android
  static const String defaultAndroidIcon = '@mipmap/ic_launcher';

  /// Default vibration pattern (in milliseconds)
  static const List<int> defaultVibrationPattern = [0, 250, 250, 250];

  /// Default LED color (blue)
  static const int defaultLedColor = 0xFF0000FF;

  /// Notification action IDs
  static const String actionIdTap = 'notification_tap';
  static const String actionIdDismiss = 'notification_dismiss';

  /// Payload keys
  static const String payloadKeyType = 'type';
  static const String payloadKeyData = 'data';
  static const String payloadKeyId = 'id';

  /// FCM topics prefix
  static const String topicPrefix = 'topic_';

  /// Maximum notification badge count
  static const int maxBadgeCount = 99;
}
