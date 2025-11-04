import 'package:dartz/dartz.dart';

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/connectivity/entities.dart';

/// Connectivity Service Interface
///
/// Generic connectivity checking interface that is independent of any specific implementation.
/// Can be implemented with internet_connection_checker_plus, connectivity_plus, or any other package.
///
/// **Dependency Independence**: This interface does NOT depend on any specific connectivity package.
/// Consumer apps can use any connectivity provider (internet_connection_checker_plus,
/// connectivity_plus, custom implementation) by implementing this interface.
///
/// **Features:**
/// - Real internet connectivity checking (not just Wi-Fi/Mobile connection)
/// - Listen to connectivity changes in real-time
/// - Custom check endpoints support
/// - Configurable check intervals and timeouts
/// - Lifecycle management (pause/resume)
/// - Cross-platform support
///
/// **Why This Matters:**
/// Many apps incorrectly use connectivity_plus which only checks if device is connected
/// to Wi-Fi or mobile network, NOT if there's actual internet access. This service
/// performs real connectivity checks by pinging actual endpoints.
///
/// Example:
/// ```dart
/// final connectivity = getIt<ConnectivityService>();
///
/// // One-time check
/// final result = await connectivity.hasInternetConnection();
/// result.fold(
///   (failure) => print('Check failed: $failure'),
///   (isConnected) => print('Connected: $isConnected'),
/// );
///
/// // Listen to changes
/// connectivity.onConnectivityChanged.listen((status) {
///   if (status == ConnectivityStatusEntity.connected) {
///     print('Internet available');
///   } else {
///     print('No internet');
///   }
/// });
/// ```
abstract class ConnectivityService {
  /// Check if device has internet connection (one-time check)
  ///
  /// Performs a real connectivity check by attempting to reach configured endpoints.
  /// This is NOT just checking if Wi-Fi is on - it verifies actual internet access.
  ///
  /// Returns:
  /// - `Right(true)` if internet is available
  /// - `Right(false)` if no internet connection
  /// - `Left(ConnectivityFailure)` if check failed
  ///
  /// Example:
  /// ```dart
  /// final result = await connectivity.hasInternetConnection();
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (isConnected) {
  ///     if (isConnected) {
  ///       // Proceed with online operations
  ///     } else {
  ///       // Show offline UI
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<ConnectivityFailure, bool>> hasInternetConnection();

  /// Stream of connectivity status changes
  ///
  /// Continuously monitors internet connectivity and emits status changes.
  /// Updates occur when actual internet connectivity changes, not just
  /// when Wi-Fi/Mobile connection changes.
  ///
  /// The stream is a broadcast stream, allowing multiple listeners.
  ///
  /// Example:
  /// ```dart
  /// final subscription = connectivity.onConnectivityChanged.listen((status) {
  ///   if (status == ConnectivityStatusEntity.connected) {
  ///     // Internet is available
  ///     syncData();
  ///   } else {
  ///     // No internet
  ///     showOfflineBanner();
  ///   }
  /// });
  ///
  /// // Don't forget to cancel when done
  /// subscription.cancel();
  /// ```
  Stream<ConnectivityStatusEntity> get onConnectivityChanged;

  /// Get current connectivity status (synchronous)
  ///
  /// Returns the last known connectivity status without performing a new check.
  /// Returns `null` if status hasn't been determined yet.
  ///
  /// Example:
  /// ```dart
  /// final status = connectivity.currentStatus;
  /// if (status?.isConnected ?? false) {
  ///   // Show online features
  /// }
  /// ```
  ConnectivityStatusEntity? get currentStatus;

  /// Check if currently connected to internet (synchronous)
  ///
  /// Returns the last known connection state without performing a new check.
  /// Returns `null` if connection state hasn't been determined yet.
  ///
  /// Example:
  /// ```dart
  /// if (connectivity.isConnected ?? false) {
  ///   // Safe to make network requests
  /// }
  /// ```
  bool? get isConnected;

  /// Initialize the connectivity service
  ///
  /// Must be called before using the service. Sets up connectivity monitoring
  /// and performs initial connectivity check.
  ///
  /// [checkInterval] - How often to check connectivity (default: 10 seconds)
  /// [checkOptions] - Custom endpoints to check (optional)
  ///
  /// Example:
  /// ```dart
  /// await connectivity.initialize(
  ///   checkInterval: Duration(seconds: 5),
  ///   checkOptions: [
  ///     ConnectivityCheckOptionEntity(
  ///       uri: Uri.parse('https://api.myapp.com/health'),
  ///     ),
  ///   ],
  /// );
  /// ```
  Future<Either<ConnectivityFailure, void>> initialize({
    Duration? checkInterval,
    List<ConnectivityCheckOptionEntity>? checkOptions,
  });

  /// Check if service is initialized
  bool get isInitialized;

  /// Pause connectivity monitoring
  ///
  /// Useful when app goes to background to save battery and resources.
  /// Stops periodic connectivity checks but maintains last known status.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void didChangeAppLifecycleState(AppLifecycleState state) {
  ///   if (state == AppLifecycleState.paused) {
  ///     connectivity.pause();
  ///   } else if (state == AppLifecycleState.resumed) {
  ///     connectivity.resume();
  ///   }
  /// }
  /// ```
  void pause();

  /// Resume connectivity monitoring
  ///
  /// Resumes periodic connectivity checks after being paused.
  /// Performs an immediate check when resumed.
  void resume();

  /// Check if monitoring is currently paused
  bool get isPaused;

  /// Update check interval
  ///
  /// Changes how frequently connectivity is checked.
  ///
  /// [interval] - New check interval (must be >= 1 second)
  ///
  /// Example:
  /// ```dart
  /// // Check more frequently when user is actively using network features
  /// connectivity.updateCheckInterval(Duration(seconds: 5));
  ///
  /// // Check less frequently during idle
  /// connectivity.updateCheckInterval(Duration(seconds: 30));
  /// ```
  void updateCheckInterval(Duration interval);

  /// Update custom check endpoints
  ///
  /// Changes which endpoints are used for connectivity checking.
  /// Useful if you want to verify connectivity to your own API servers.
  ///
  /// [options] - List of custom endpoints to check
  ///
  /// Example:
  /// ```dart
  /// connectivity.updateCheckOptions([
  ///   ConnectivityCheckOptionEntity(
  ///     uri: Uri.parse('https://api.myapp.com/ping'),
  ///     timeout: Duration(seconds: 5),
  ///   ),
  ///   ConnectivityCheckOptionEntity(
  ///     uri: Uri.parse('https://backup-api.myapp.com/ping'),
  ///   ),
  /// ]);
  /// ```
  void updateCheckOptions(List<ConnectivityCheckOptionEntity> options);

  /// Dispose resources and stop monitoring
  ///
  /// Call this when the service is no longer needed.
  /// Stops all connectivity checks and closes streams.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   connectivity.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose();
}
