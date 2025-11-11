/// Enum representing the availability status of an update.
///
/// This wraps the update availability status from the in_app_update package
/// to provide a dependency-independent representation.
enum UpdateAvailability {
  /// No update is available.
  unknown,

  /// An update is available.
  updateAvailable,

  /// No update is currently available.
  updateNotAvailable,

  /// Developer triggered update is already in progress.
  developerTriggeredUpdateInProgress;

  /// Check if an update is available.
  bool get isUpdateAvailable =>
      this == UpdateAvailability.updateAvailable ||
      this == UpdateAvailability.developerTriggeredUpdateInProgress;

  /// Check if no update is available.
  bool get isUpdateNotAvailable =>
      this == UpdateAvailability.updateNotAvailable ||
      this == UpdateAvailability.unknown;
}

