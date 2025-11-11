import 'failures.dart';

/// Failure specific to in-app update operations.
///
/// This failure is returned when any in-app update operation fails.
///
/// Common error codes:
/// - `ERROR_API_NOT_AVAILABLE`: In-app updates not available (must be installed via Google Play)
/// - `ERROR_UPDATE_NOT_AVAILABLE`: No update available
/// - `ERROR_UPDATE_UNAVAILABLE`: Update available but cannot be performed
/// - `ERROR_DOWNLOAD_NOT_PRESENT`: Flexible update download not complete
/// - `ERROR_INSTALL_NOT_ALLOWED`: Installation not allowed (e.g., app in foreground)
/// - `ERROR_INSTALL_UNAVAILABLE`: Installation is unavailable
/// - `ERROR_UNKNOWN`: Unknown error occurred
/// - `PLATFORM_NOT_SUPPORTED`: Platform does not support in-app updates (iOS)
/// - `UPDATE_IN_PROGRESS`: An update is already in progress
/// - `UPDATE_CANCELLED`: User cancelled the update
class InAppUpdateFailure extends Failure {
  const InAppUpdateFailure({
    required super.message,
    super.code,
    super.details,
  });

  /// Create failure for API not available error.
  ///
  /// This usually means the app is not installed via Google Play Store.
  factory InAppUpdateFailure.apiNotAvailable() {
    return const InAppUpdateFailure(
      message: 'In-app updates API is not available. '
          'The app must be installed via Google Play Store.',
      code: 'ERROR_API_NOT_AVAILABLE',
    );
  }

  /// Create failure for no update available.
  factory InAppUpdateFailure.updateNotAvailable() {
    return const InAppUpdateFailure(
      message: 'No update is available for this app.',
      code: 'ERROR_UPDATE_NOT_AVAILABLE',
    );
  }

  /// Create failure for update unavailable.
  factory InAppUpdateFailure.updateUnavailable() {
    return const InAppUpdateFailure(
      message: 'Update is available but cannot be performed.',
      code: 'ERROR_UPDATE_UNAVAILABLE',
    );
  }

  /// Create failure for download not present.
  factory InAppUpdateFailure.downloadNotPresent() {
    return const InAppUpdateFailure(
      message: 'Flexible update has not been downloaded yet.',
      code: 'ERROR_DOWNLOAD_NOT_PRESENT',
    );
  }

  /// Create failure for install not allowed.
  factory InAppUpdateFailure.installNotAllowed() {
    return const InAppUpdateFailure(
      message: 'Installation is not allowed. '
          'The app may be running in the foreground.',
      code: 'ERROR_INSTALL_NOT_ALLOWED',
    );
  }

  /// Create failure for install unavailable.
  factory InAppUpdateFailure.installUnavailable() {
    return const InAppUpdateFailure(
      message: 'Installation is unavailable.',
      code: 'ERROR_INSTALL_UNAVAILABLE',
    );
  }

  /// Create failure for platform not supported.
  factory InAppUpdateFailure.platformNotSupported() {
    return const InAppUpdateFailure(
      message: 'In-app updates are not supported on this platform. '
          'Only Android is supported.',
      code: 'PLATFORM_NOT_SUPPORTED',
    );
  }

  /// Create failure for update in progress.
  factory InAppUpdateFailure.updateInProgress() {
    return const InAppUpdateFailure(
      message: 'An update is already in progress.',
      code: 'UPDATE_IN_PROGRESS',
    );
  }

  /// Create failure for cancelled update.
  factory InAppUpdateFailure.updateCancelled() {
    return const InAppUpdateFailure(
      message: 'The update was cancelled by the user.',
      code: 'UPDATE_CANCELLED',
    );
  }

  /// Create failure for unknown error.
  factory InAppUpdateFailure.unknown(String? message) {
    return InAppUpdateFailure(
      message: message ?? 'An unknown error occurred during app update.',
      code: 'ERROR_UNKNOWN',
    );
  }
}
