import 'package:app_core/src/foundation/domain/entities/notification/entities.dart';

/// Notification importance level (Android)
enum NotificationImportance {
  /// Unspecified importance
  unspecified,

  /// No importance
  none,

  /// Minimum importance
  min,

  /// Low importance
  low,

  /// Default importance
  defaultImportance,

  /// High importance
  high,

  /// Maximum importance
  max,
}

/// Notification priority (Android)
enum NotificationPriority {
  /// Minimum priority
  min,

  /// Low priority
  low,

  /// Default priority
  defaultPriority,

  /// High priority
  high,

  /// Maximum priority
  max,
}

/// Notification style
enum NotificationStyle {
  /// Default notification
  defaultStyle,

  /// Big text style
  bigText,

  /// Big picture style
  bigPicture,

  /// Inbox style
  inbox,

  /// Messaging style
  messaging,

  /// Media style
  media,
}

/// Repeat interval for periodic notifications
enum RepeatInterval {
  /// Every minute
  everyMinute,

  /// Hourly
  hourly,

  /// Daily
  daily,

  /// Weekly
  weekly,
}

/// Configuration for showing a notification
class NotificationConfig {
  /// Notification ID
  final int id;

  /// Title
  final String? title;

  /// Body text
  final String? body;

  /// Payload data
  final String? payload;

  /// Channel ID (Android)
  final String? channelId;

  /// Channel name (Android)
  final String? channelName;

  /// Channel description (Android)
  final String? channelDescription;

  /// Importance level (Android)
  final NotificationImportance? importance;

  /// Priority (Android)
  final NotificationPriority? priority;

  /// Notification style
  final NotificationStyle? style;

  /// Large icon path/URL
  final String? largeIcon;

  /// Big picture path/URL (for big picture style)
  final String? bigPicture;

  /// Sound file name (without extension)
  final String? sound;

  /// Enable sound
  final bool? playSound;

  /// Enable vibration
  final bool? enableVibration;

  /// Vibration pattern in milliseconds
  final List<int>? vibrationPattern;

  /// Enable lights
  final bool? enableLights;

  /// LED color (Android)
  final int? ledColor;

  /// Show badge (iOS)
  final bool? showBadge;

  /// Badge number (iOS)
  final int? badgeNumber;

  /// Category identifier (iOS)
  final String? category;

  /// Thread identifier for grouping (iOS)
  final String? threadIdentifier;

  /// Group key (Android)
  final String? groupKey;

  /// Set as group summary (Android)
  final bool? setAsGroupSummary;

  /// Ongoing notification (Android)
  final bool? ongoing;

  /// Auto cancel when tapped (Android)
  final bool? autoCancel;

  /// Show when locked screen (Android)
  final bool? showWhen;

  /// Timestamp (Android)
  final int? timestamp;

  const NotificationConfig({
    required this.id,
    this.title,
    this.body,
    this.payload,
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.importance,
    this.priority,
    this.style,
    this.largeIcon,
    this.bigPicture,
    this.sound,
    this.playSound,
    this.enableVibration,
    this.vibrationPattern,
    this.enableLights,
    this.ledColor,
    this.showBadge,
    this.badgeNumber,
    this.category,
    this.threadIdentifier,
    this.groupKey,
    this.setAsGroupSummary,
    this.ongoing,
    this.autoCancel,
    this.showWhen,
    this.timestamp,
  });
}

/// Callback for when local notification is tapped
typedef OnLocalNotificationTappedCallback = Future<void> Function(
  NotificationDataEntity notification,
);

/// Abstract service for local notifications
///
/// This interface wraps flutter_local_notifications package following DIP principle.
/// Consumer apps should inject their own implementations or use the default impl.
abstract class LocalNotificationService {
  /// Initialize local notification service
  ///
  /// [onNotificationTapped] - Optional callback when user taps notification
  /// [defaultAndroidIcon] - Default icon for Android notifications
  Future<void> initialize({
    OnLocalNotificationTappedCallback? onNotificationTapped,
    String? defaultAndroidIcon,
  });

  /// Request notification permissions
  ///
  /// Returns true if permission granted
  Future<bool> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  /// Show a notification immediately
  ///
  /// [config] - Configuration for the notification
  Future<void> show(NotificationConfig config);

  /// Schedule a notification for a specific time
  ///
  /// [config] - Configuration for the notification
  /// [scheduledDate] - When to show the notification
  Future<void> schedule({
    required NotificationConfig config,
    required DateTime scheduledDate,
  });

  /// Schedule a periodic notification
  ///
  /// [config] - Configuration for the notification
  /// [repeatInterval] - How often to repeat
  Future<void> periodicallyShow({
    required NotificationConfig config,
    required RepeatInterval repeatInterval,
  });

  /// Schedule a daily notification at specific time
  ///
  /// [config] - Configuration for the notification
  /// [time] - Time of day to show notification
  Future<void> showDaily({
    required NotificationConfig config,
    required DateTime time,
  });

  /// Schedule a weekly notification on specific day and time
  ///
  /// [config] - Configuration for the notification
  /// [dayOfWeek] - Day of week (1 = Monday, 7 = Sunday)
  /// [time] - Time of day to show notification
  Future<void> showWeekly({
    required NotificationConfig config,
    required int dayOfWeek,
    required DateTime time,
  });

  /// Cancel a specific notification
  ///
  /// [id] - Notification ID to cancel
  Future<void> cancel(int id);

  /// Cancel all notifications
  Future<void> cancelAll();

  /// Get list of pending notification requests
  Future<List<NotificationDataEntity>> getPendingNotificationRequests();

  /// Get list of active notifications
  Future<List<NotificationDataEntity>> getActiveNotifications();

  /// Create a notification channel (Android 8.0+)
  ///
  /// [channelId] - Unique channel identifier
  /// [channelName] - User-visible channel name
  /// [channelDescription] - User-visible channel description
  /// [importance] - Channel importance level
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
  });

  /// Delete a notification channel (Android 8.0+)
  ///
  /// [channelId] - Channel ID to delete
  Future<void> deleteNotificationChannel(String channelId);

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Stream of notification taps
  Stream<NotificationDataEntity> get onNotificationTap;
}
