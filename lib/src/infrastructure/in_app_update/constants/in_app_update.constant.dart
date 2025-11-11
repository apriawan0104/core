/// Constants for in-app update service.
///
/// This class contains all constant values used by the in-app update service.
class InAppUpdateConstants {
  InAppUpdateConstants._();

  /// Default update check interval in hours.
  ///
  /// Recommended to check for updates once per day to avoid
  /// annoying users with too frequent update prompts.
  static const int defaultUpdateCheckIntervalHours = 24;

  /// Default flexible update prompt interval in hours.
  ///
  /// After a flexible update is downloaded, wait this long before
  /// prompting the user again to complete the installation.
  static const int defaultFlexibleUpdatePromptIntervalHours = 12;

  /// High priority threshold.
  ///
  /// Updates with priority >= this value should use immediate update flow.
  static const int highPriorityThreshold = 4;

  /// Medium priority threshold.
  ///
  /// Updates with priority >= this value should prompt more frequently.
  static const int mediumPriorityThreshold = 3;

  /// Staleness days threshold for immediate update.
  ///
  /// If an update has been available for this many days or more,
  /// consider using immediate update flow.
  static const int stalenessDaysThresholdForImmediate = 7;

  /// Staleness days threshold for flexible update prompt.
  ///
  /// If an update has been available for this many days or more,
  /// increase the frequency of prompts.
  static const int stalenessDaysThresholdForPrompt = 3;

  /// Error code constants from Android In-App Update API.
  static const String errorApiNotAvailable = 'ERROR_API_NOT_AVAILABLE';
  static const String errorUpdateNotAvailable = 'ERROR_UPDATE_NOT_AVAILABLE';
  static const String errorUpdateUnavailable = 'ERROR_UPDATE_UNAVAILABLE';
  static const String errorDownloadNotPresent = 'ERROR_DOWNLOAD_NOT_PRESENT';
  static const String errorInstallNotAllowed = 'ERROR_INSTALL_NOT_ALLOWED';
  static const String errorInstallUnavailable = 'ERROR_INSTALL_UNAVAILABLE';
  static const String errorUnknown = 'ERROR_UNKNOWN';

  /// Custom error codes.
  static const String platformNotSupported = 'PLATFORM_NOT_SUPPORTED';
  static const String updateInProgress = 'UPDATE_IN_PROGRESS';
  static const String updateCancelled = 'UPDATE_CANCELLED';

  /// Android-specific constants.
  static const String androidPlatform = 'android';

  /// iOS-specific constants.
  static const String iosPlatform = 'ios';

  /// Storage keys for tracking update state.
  static const String keyLastUpdateCheck = 'in_app_update_last_check';
  static const String keyLastFlexiblePrompt =
      'in_app_update_last_flexible_prompt';
  static const String keyUpdateSkippedVersion =
      'in_app_update_skipped_version';
  static const String keyFlexibleUpdateDownloaded =
      'in_app_update_flexible_downloaded';

  /// Update request codes (for tracking).
  static const int immediateUpdateRequestCode = 1001;
  static const int flexibleUpdateRequestCode = 1002;
}

