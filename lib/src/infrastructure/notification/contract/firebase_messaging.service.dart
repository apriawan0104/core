import 'package:app_core/src/foundation/domain/entities/notification/entities.dart';

/// Callback for when notification is tapped
typedef OnNotificationTappedCallback = Future<void> Function(
  NotificationDataEntity notification,
);

/// Callback for when notification is received in foreground
typedef OnForegroundNotificationCallback = Future<void> Function(
  NotificationDataEntity notification,
);

/// Callback for when notification is received in background
typedef OnBackgroundNotificationCallback = Future<void> Function(
  NotificationDataEntity notification,
);

/// Abstract service for Firebase Cloud Messaging
///
/// This interface wraps firebase_messaging package following DIP principle.
/// Consumer apps should inject their own implementations or use the default impl.
abstract class FirebaseMessagingService {
  /// Initialize Firebase Messaging service
  ///
  /// [onNotificationTapped] - Optional callback when user taps notification
  /// [onForegroundNotification] - Optional callback for foreground notifications
  /// [onBackgroundNotification] - Optional callback for background notifications
  /// [autoInitEnabled] - Enable/disable auto-initialization (default: true)
  Future<void> initialize({
    OnNotificationTappedCallback? onNotificationTapped,
    OnForegroundNotificationCallback? onForegroundNotification,
    OnBackgroundNotificationCallback? onBackgroundNotification,
    bool autoInitEnabled = true,
  });

  /// Request notification permissions (iOS only)
  ///
  /// Returns true if permission granted
  Future<bool> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  });

  /// Get FCM token
  ///
  /// Returns the Firebase Cloud Messaging token
  Future<String?> getToken();

  /// Delete FCM token
  Future<void> deleteToken();

  /// Subscribe to topic
  ///
  /// [topic] - Topic name to subscribe to
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from topic
  ///
  /// [topic] - Topic name to unsubscribe from
  Future<void> unsubscribeFromTopic(String topic);

  /// Get initial notification (if app was opened from terminated state)
  ///
  /// Returns the notification data if app was opened from notification
  Future<NotificationDataEntity?> getInitialNotification();

  /// Stream of FCM token changes
  Stream<String> get onTokenRefresh;

  /// Stream of notification taps
  Stream<NotificationDataEntity> get onNotificationTap;

  /// Stream of foreground notifications
  Stream<NotificationDataEntity> get onForegroundNotification;

  /// Check if notifications are supported on this platform
  bool get isSupported;

  /// Set auto-init enabled state
  Future<void> setAutoInitEnabled(bool enabled);

  /// Get auto-init enabled state
  bool isAutoInitEnabled();

  /// Set delivery metrics export to BigQuery enabled (Android only)
  Future<void> setDeliveryMetricsExportToBigQuery(bool enabled);
}
