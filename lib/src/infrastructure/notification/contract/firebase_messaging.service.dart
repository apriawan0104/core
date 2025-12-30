import 'package:dartz/dartz.dart';
import 'package:app_core/src/errors/errors.dart';
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
///
/// **Features:**
/// - Push notification support
/// - Topic subscription
/// - Token management
/// - Permission handling
/// - Error handling with Either<Failure, Success>
///
/// Example:
/// ```dart
/// final fcmService = getIt<FirebaseMessagingService>();
///
/// final result = await fcmService.initialize(
///   onNotificationTapped: (notification) async {
///     print('Tapped: ${notification.title}');
///   },
/// );
///
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (_) => print('Initialized successfully'),
/// );
/// ```
abstract class FirebaseMessagingService {
  /// Initialize Firebase Messaging service
  ///
  /// [onNotificationTapped] - Optional callback when user taps notification
  /// [onForegroundNotification] - Optional callback for foreground notifications
  /// [onBackgroundNotification] - Optional callback for background notifications
  /// [autoInitEnabled] - Enable/disable auto-initialization (default: true)
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> initialize({
    OnNotificationTappedCallback? onNotificationTapped,
    OnForegroundNotificationCallback? onForegroundNotification,
    OnBackgroundNotificationCallback? onBackgroundNotification,
    bool autoInitEnabled = true,
  });

  /// Request notification permissions (iOS only)
  ///
  /// Returns Either<NotificationFailure, bool> - true if permission granted
  Future<Either<NotificationFailure, bool>> requestPermission({
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
  /// Returns Either<NotificationFailure, String> with the FCM token
  Future<Either<NotificationFailure, String>> getToken();

  /// Delete FCM token
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> deleteToken();

  /// Subscribe to topic
  ///
  /// [topic] - Topic name to subscribe to
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> subscribeToTopic(String topic);

  /// Unsubscribe from topic
  ///
  /// [topic] - Topic name to unsubscribe from
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> unsubscribeFromTopic(String topic);

  /// Get initial notification (if app was opened from terminated state)
  ///
  /// Returns Either<NotificationFailure, NotificationDataEntity?> with the notification data
  Future<Either<NotificationFailure, NotificationDataEntity?>>
      getInitialNotification();

  /// Stream of FCM token changes
  Stream<String> get onTokenRefresh;

  /// Stream of notification taps
  Stream<NotificationDataEntity> get onNotificationTap;

  /// Stream of foreground notifications
  Stream<NotificationDataEntity> get onForegroundNotification;

  /// Check if notifications are supported on this platform
  bool get isSupported;

  /// Set auto-init enabled state
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> setAutoInitEnabled(bool enabled);

  /// Get auto-init enabled state
  bool isAutoInitEnabled();

  /// Set delivery metrics export to BigQuery enabled (Android only)
  ///
  /// Returns Either<NotificationFailure, void>
  Future<Either<NotificationFailure, void>> setDeliveryMetricsExportToBigQuery(
      bool enabled);
}
