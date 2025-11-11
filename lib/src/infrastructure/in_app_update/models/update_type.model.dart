/// Enum representing the type of update to perform.
///
/// This wraps the update type from the in_app_update package
/// to provide a dependency-independent representation.
enum UpdateType {
  /// Immediate update - requires the app to restart immediately.
  ///
  /// Shows a full-screen UI that blocks the user from using the app
  /// until the update is downloaded and installed.
  ///
  /// **Use for critical updates** like security patches or breaking changes.
  immediate,

  /// Flexible update - downloads in the background.
  ///
  /// Allows users to continue using the app while the update downloads.
  /// Once downloaded, you can prompt the user to install the update.
  ///
  /// **Use for non-critical updates** to provide better user experience.
  flexible;

  /// Check if this is an immediate update.
  bool get isImmediate => this == UpdateType.immediate;

  /// Check if this is a flexible update.
  bool get isFlexible => this == UpdateType.flexible;
}

