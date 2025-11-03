/// Background Service Constants
class BackgroundServiceConstants {
  const BackgroundServiceConstants._();

  /// Default notification channel ID for Android
  static const String defaultNotificationChannelId = 'background_service';

  /// Default notification ID for Android foreground service
  static const int defaultNotificationId = 888;

  /// Default notification title
  static const String defaultNotificationTitle = 'Background Service';

  /// Default notification content
  static const String defaultNotificationContent = 'Service is running';

  /// Method name to stop service
  static const String methodStop = 'stop';

  /// Method name to start service
  static const String methodStart = 'start';

  /// Method name for service update
  static const String methodUpdate = 'update';

  /// iOS background task identifier
  static const String iosTaskIdentifier = 'dev.flutter.background.refresh';
}

