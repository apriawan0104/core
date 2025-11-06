import 'failures.dart';

/// Base class for notification-related failures
class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Permission denied failure - user denied notification permission
class NotificationPermissionDeniedFailure extends NotificationFailure {
  const NotificationPermissionDeniedFailure({
    super.message = 'Notification permission denied.',
    super.code,
    super.details,
  });
}

/// Initialization failure - failed to initialize notification service
class NotificationInitializationFailure extends NotificationFailure {
  const NotificationInitializationFailure({
    super.message = 'Failed to initialize notification service.',
    super.code,
    super.details,
  });
}

/// Token failure - failed to get or refresh FCM token
class NotificationTokenFailure extends NotificationFailure {
  const NotificationTokenFailure({
    super.message = 'Failed to get notification token.',
    super.code,
    super.details,
  });
}

/// Topic subscription failure - failed to subscribe/unsubscribe to topic
class NotificationTopicFailure extends NotificationFailure {
  const NotificationTopicFailure({
    super.message = 'Failed to manage topic subscription.',
    super.code,
    super.details,
  });
}

/// Show notification failure - failed to show notification
class ShowNotificationFailure extends NotificationFailure {
  const ShowNotificationFailure({
    super.message = 'Failed to show notification.',
    super.code,
    super.details,
  });
}

/// Schedule notification failure - failed to schedule notification
class ScheduleNotificationFailure extends NotificationFailure {
  const ScheduleNotificationFailure({
    super.message = 'Failed to schedule notification.',
    super.code,
    super.details,
  });
}

/// Cancel notification failure - failed to cancel notification
class CancelNotificationFailure extends NotificationFailure {
  const CancelNotificationFailure({
    super.message = 'Failed to cancel notification.',
    super.code,
    super.details,
  });
}

/// Channel failure - failed to create/delete notification channel (Android)
class NotificationChannelFailure extends NotificationFailure {
  const NotificationChannelFailure({
    super.message = 'Failed to manage notification channel.',
    super.code,
    super.details,
  });
}

/// Platform not supported failure
class NotificationPlatformNotSupportedFailure extends NotificationFailure {
  const NotificationPlatformNotSupportedFailure({
    super.message = 'Notification not supported on this platform.',
    super.code,
    super.details,
  });
}

/// Unknown notification failure
class UnknownNotificationFailure extends NotificationFailure {
  const UnknownNotificationFailure({
    super.message = 'An unexpected notification error occurred.',
    super.code,
    super.details,
  });
}

