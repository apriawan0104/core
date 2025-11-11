import 'package:dartz/dartz.dart';

import '../../../errors/errors.dart';
import '../models/models.dart';

/// Abstract interface for in-app update service.
///
/// This interface provides a dependency-independent abstraction for managing
/// in-app updates. It wraps the Android In-App Update API while keeping the
/// core library independent from any specific update provider.
///
/// ## Design Philosophy
///
/// This service follows the Dependency Independence principle:
/// - No third-party types exposed in public API
/// - Easy to switch between update providers (Google Play, custom providers)
/// - Multiple implementations can coexist
/// - Testable with mock implementations
///
/// ## Platform Support
///
/// - ✅ **Android**: Fully supported via Google Play In-App Updates API
/// - ❌ **iOS**: Not supported (iOS doesn't offer this functionality)
///
/// For iOS, consider using alternative solutions like the `upgrader` package.
///
/// ## Update Types
///
/// ### 1. Immediate Update (Full-Screen)
///
/// Shows a full-screen UI that blocks the user from using the app until
/// the update is downloaded and installed. Use for critical updates.
///
/// ```dart
/// final updateInfo = await updateService.checkForUpdate();
/// updateInfo.fold(
///   (failure) => print('Check failed: $failure'),
///   (info) async {
///     if (info.isUpdateAvailable && info.shouldBeImmediate) {
///       await updateService.performImmediateUpdate();
///     }
///   },
/// );
/// ```
///
/// ### 2. Flexible Update (Background)
///
/// Allows users to continue using the app while the update downloads in
/// the background. Use for non-critical updates.
///
/// ```dart
/// final updateInfo = await updateService.checkForUpdate();
/// updateInfo.fold(
///   (failure) => print('Check failed: $failure'),
///   (info) async {
///     if (info.isUpdateAvailable && info.canBeFlexible) {
///       // Start background download
///       await updateService.startFlexibleUpdate();
///
///       // Later, when download completes, prompt user to install
///       updateService.installStatusStream.listen((status) {
///         if (status.isDownloaded) {
///           // Show snackbar or dialog
///           await updateService.completeFlexibleUpdate();
///         }
///       });
///     }
///   },
/// );
/// ```
///
/// ## Testing
///
/// In-app updates **cannot be tested locally**. The app must be:
/// - Uploaded to Google Play Console (Internal/Alpha/Beta track)
/// - Installed on device via Google Play
/// - Have a higher version code available on Play Store
///
/// See: https://developer.android.com/guide/playcore/in-app-updates/test
///
/// ## Error Handling
///
/// All methods return `Either<Failure, T>` for consistent error handling:
/// - Left(InAppUpdateFailure) - When update operation fails
/// - Right(value) - When operation succeeds
///
/// Common failures:
/// - `ERROR_API_NOT_AVAILABLE`: App not installed via Google Play
/// - `ERROR_UPDATE_NOT_AVAILABLE`: No update available
/// - `PLATFORM_NOT_SUPPORTED`: Called on iOS
///
/// ## Implementation Example
///
/// See [AndroidInAppUpdateServiceImpl] for the Android implementation.
abstract class InAppUpdateService {
  /// Initialize the in-app update service.
  ///
  /// Must be called before any other methods. This sets up the necessary
  /// connections to the Google Play Store API.
  ///
  /// Returns:
  /// - Right(void) - Initialization successful
  /// - Left(InAppUpdateFailure) - Initialization failed
  ///
  /// Example:
  /// ```dart
  /// final result = await updateService.initialize();
  /// result.fold(
  ///   (failure) => print('Failed to initialize: $failure'),
  ///   (_) => print('Update service initialized'),
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, void>> initialize();

  /// Check if there's an update available.
  ///
  /// This method checks with Google Play to see if a newer version of
  /// the app is available for download.
  ///
  /// Returns:
  /// - Right(AppUpdateInfo) - Update info retrieved successfully
  /// - Left(InAppUpdateFailure) - Check failed
  ///
  /// The returned [AppUpdateInfo] contains:
  /// - Update availability status
  /// - Whether immediate/flexible update is allowed
  /// - Available version code
  /// - Update priority
  /// - Days since update became available
  ///
  /// Example:
  /// ```dart
  /// final result = await updateService.checkForUpdate();
  /// result.fold(
  ///   (failure) => print('Check failed: $failure'),
  ///   (info) {
  ///     if (info.isUpdateAvailable) {
  ///       print('Update available: v${info.availableVersionCode}');
  ///       print('Priority: ${info.updatePriority}');
  ///       print('Staleness: ${info.clientVersionStalenessDays} days');
  ///     } else {
  ///       print('No update available');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, AppUpdateInfo>> checkForUpdate();

  /// Perform an immediate update (full-screen).
  ///
  /// Shows a full-screen UI that prevents the user from using the app
  /// until the update is downloaded and installed. The app will restart
  /// automatically after the update completes.
  ///
  /// **Use cases:**
  /// - Critical security patches
  /// - Breaking changes in backend API
  /// - High-priority bugs that prevent app usage
  /// - Updates with priority >= 4
  ///
  /// Returns:
  /// - Right(void) - Update started (app will restart)
  /// - Left(InAppUpdateFailure) - Update failed or cancelled
  ///
  /// Common failures:
  /// - `ERROR_API_NOT_AVAILABLE`: Not installed via Play Store
  /// - `ERROR_UPDATE_NOT_AVAILABLE`: No update available
  /// - `UPDATE_CANCELLED`: User cancelled the update
  ///
  /// Example:
  /// ```dart
  /// final updateInfo = await updateService.checkForUpdate();
  /// await updateInfo.fold(
  ///   (failure) => print('Check failed'),
  ///   (info) async {
  ///     if (info.isUpdateAvailable && info.immediateUpdateAllowed) {
  ///       final result = await updateService.performImmediateUpdate();
  ///       result.fold(
  ///         (failure) => print('Update failed: $failure'),
  ///         (_) => print('Update completed (app will restart)'),
  ///       );
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, void>> performImmediateUpdate();

  /// Start a flexible update (background download).
  ///
  /// Begins downloading the update in the background while allowing
  /// the user to continue using the app. Once download completes,
  /// call [completeFlexibleUpdate] to install the update.
  ///
  /// **Use cases:**
  /// - Non-critical feature updates
  /// - Performance improvements
  /// - Minor bug fixes
  /// - Updates with priority < 4
  ///
  /// **Workflow:**
  /// 1. Call `startFlexibleUpdate()` to begin download
  /// 2. Monitor [installStatusStream] for download progress
  /// 3. When status is `downloaded`, prompt user to install
  /// 4. Call `completeFlexibleUpdate()` to install
  ///
  /// Returns:
  /// - Right(void) - Download started
  /// - Left(InAppUpdateFailure) - Failed to start download
  ///
  /// Common failures:
  /// - `ERROR_API_NOT_AVAILABLE`: Not installed via Play Store
  /// - `ERROR_UPDATE_NOT_AVAILABLE`: No update available
  /// - `UPDATE_IN_PROGRESS`: Update already downloading
  ///
  /// Example:
  /// ```dart
  /// // Start download
  /// final result = await updateService.startFlexibleUpdate();
  /// result.fold(
  ///   (failure) => print('Download failed: $failure'),
  ///   (_) => print('Download started'),
  /// );
  ///
  /// // Listen for completion
  /// updateService.installStatusStream.listen((status) {
  ///   print('Status: $status');
  ///   if (status.isDownloaded) {
  ///     // Show snackbar: "Update downloaded. Install now?"
  ///   }
  /// });
  /// ```
  Future<Either<InAppUpdateFailure, void>> startFlexibleUpdate();

  /// Complete a flexible update (install downloaded update).
  ///
  /// Installs an update that was previously downloaded via
  /// [startFlexibleUpdate]. The app will restart after installation.
  ///
  /// **Important:** Only call this after the download is complete
  /// (when [installStatusStream] emits [InstallStatus.downloaded]).
  ///
  /// **User Experience Best Practice:**
  /// - Show a snackbar or dialog when download completes
  /// - Allow user to choose when to install (don't force immediately)
  /// - Inform user that the app will restart
  ///
  /// Returns:
  /// - Right(void) - Installation started (app will restart)
  /// - Left(InAppUpdateFailure) - Installation failed
  ///
  /// Common failures:
  /// - `ERROR_DOWNLOAD_NOT_PRESENT`: Update not downloaded yet
  /// - `ERROR_INSTALL_NOT_ALLOWED`: Installation not allowed
  ///
  /// Example:
  /// ```dart
  /// // After download completes
  /// final result = await updateService.completeFlexibleUpdate();
  /// result.fold(
  ///   (failure) => print('Install failed: $failure'),
  ///   (_) => print('Installing update (app will restart)'),
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, void>> completeFlexibleUpdate();

  /// Stream of installation status updates.
  ///
  /// Emits [InstallStatus] events during a flexible update to track
  /// download and installation progress.
  ///
  /// **Status Flow:**
  /// 1. `pending` - Update queued for download
  /// 2. `downloading` - Download in progress
  /// 3. `downloaded` - Download complete, ready to install
  /// 4. `installing` - Installation in progress
  /// 5. `installed` - Installation complete
  ///
  /// **Error States:**
  /// - `failed` - Download or installation failed
  /// - `canceled` - User cancelled the update
  ///
  /// Example:
  /// ```dart
  /// updateService.installStatusStream.listen((status) {
  ///   switch (status) {
  ///     case InstallStatus.pending:
  ///       print('Update pending...');
  ///       break;
  ///     case InstallStatus.downloading:
  ///       print('Downloading update...');
  ///       // Show progress indicator
  ///       break;
  ///     case InstallStatus.downloaded:
  ///       print('Update ready to install');
  ///       // Show snackbar with "Install" button
  ///       break;
  ///     case InstallStatus.installing:
  ///       print('Installing...');
  ///       break;
  ///     case InstallStatus.installed:
  ///       print('Update installed');
  ///       break;
  ///     case InstallStatus.failed:
  ///       print('Update failed');
  ///       break;
  ///     case InstallStatus.canceled:
  ///       print('Update cancelled');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<InstallStatus> get installStatusStream;

  /// Check if in-app updates are supported on this platform.
  ///
  /// Returns:
  /// - Right(true) - In-app updates supported (Android)
  /// - Right(false) - In-app updates not supported (iOS, Web, etc.)
  /// - Left(InAppUpdateFailure) - Error checking support
  ///
  /// Example:
  /// ```dart
  /// final result = await updateService.isUpdateSupported();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (supported) {
  ///     if (supported) {
  ///       // Show update UI
  ///     } else {
  ///       // Use alternative update method (e.g., upgrader package)
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, bool>> isUpdateSupported();

  /// Get current installation status.
  ///
  /// Returns the current status of a flexible update installation.
  /// Useful for checking update state when app restarts.
  ///
  /// Returns:
  /// - Right(InstallStatus) - Current status
  /// - Left(InAppUpdateFailure) - Error getting status
  ///
  /// Example:
  /// ```dart
  /// final result = await updateService.getCurrentInstallStatus();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (status) {
  ///     if (status.isDownloaded) {
  ///       // Prompt user to complete installation
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<InAppUpdateFailure, InstallStatus>> getCurrentInstallStatus();

  /// Dispose resources used by the update service.
  ///
  /// Call this when the service is no longer needed to clean up resources.
  /// After calling dispose, the service should not be used anymore.
  ///
  /// Example:
  /// ```dart
  /// await updateService.dispose();
  /// ```
  Future<Either<InAppUpdateFailure, void>> dispose();
}
