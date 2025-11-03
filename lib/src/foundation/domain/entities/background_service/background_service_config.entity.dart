/// Configuration for background service initialization
class BackgroundServiceConfig {
  /// Auto start service on app launch
  final bool autoStart;

  /// Auto start service on device boot (Android only)
  final bool autoStartOnBoot;

  /// Run service in foreground mode (Android only)
  /// When true, shows a notification
  final bool isForegroundMode;

  /// Notification channel ID (Android only)
  final String? notificationChannelId;

  /// Initial notification title (Android only)
  final String? initialNotificationTitle;

  /// Initial notification content (Android only)
  final String? initialNotificationContent;

  /// Foreground service notification ID (Android only)
  final int? foregroundServiceNotificationId;

  /// Custom configuration that can be passed to the service
  final Map<String, dynamic>? customConfig;

  const BackgroundServiceConfig({
    this.autoStart = false,
    this.autoStartOnBoot = false,
    this.isForegroundMode = true,
    this.notificationChannelId,
    this.initialNotificationTitle,
    this.initialNotificationContent,
    this.foregroundServiceNotificationId,
    this.customConfig,
  });

  BackgroundServiceConfig copyWith({
    bool? autoStart,
    bool? autoStartOnBoot,
    bool? isForegroundMode,
    String? notificationChannelId,
    String? initialNotificationTitle,
    String? initialNotificationContent,
    int? foregroundServiceNotificationId,
    Map<String, dynamic>? customConfig,
  }) {
    return BackgroundServiceConfig(
      autoStart: autoStart ?? this.autoStart,
      autoStartOnBoot: autoStartOnBoot ?? this.autoStartOnBoot,
      isForegroundMode: isForegroundMode ?? this.isForegroundMode,
      notificationChannelId:
          notificationChannelId ?? this.notificationChannelId,
      initialNotificationTitle:
          initialNotificationTitle ?? this.initialNotificationTitle,
      initialNotificationContent:
          initialNotificationContent ?? this.initialNotificationContent,
      foregroundServiceNotificationId: foregroundServiceNotificationId ??
          this.foregroundServiceNotificationId,
      customConfig: customConfig ?? this.customConfig,
    );
  }
}

