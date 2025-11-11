import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

import '../../../errors/failures.dart';
import '../models/models.dart';

/// Abstract service for HTTP request/response inspection
///
/// This service provides functionality to inspect HTTP(S) requests and responses
/// in your Flutter application. It is designed to be implementation-agnostic,
/// allowing different inspection tools (Chucker, Alice, Charles Proxy, etc.)
/// to be used interchangeably.
///
/// ## Features:
/// - Intercept and log HTTP requests/responses
/// - Display notifications for network calls
/// - Provide UI for inspecting network traffic
/// - Share request/response data
/// - Configure inspection behavior
///
/// ## Usage:
/// ```dart
/// // Initialize the service
/// final result = await httpInspector.initialize(
///   HttpInspectorConfig(
///     showNotifications: true,
///     showOnRelease: false,
///   ),
/// );
///
/// // Get interceptor for Dio
/// final dioInterceptor = httpInspector.getDioInterceptor();
/// dio.interceptors.add(dioInterceptor);
///
/// // Get HTTP client wrapper
/// final httpClient = httpInspector.getHttpClient(http.Client());
///
/// // Get navigator observer for navigation
/// MaterialApp(
///   navigatorObservers: [httpInspector.getNavigatorObserver()],
/// );
/// ```
///
/// ## Implementation Examples:
/// - ChuckerHttpInspectorServiceImpl (using chucker_flutter)
/// - AliceHttpInspectorServiceImpl (using alice)
/// - Custom implementation for other tools
abstract class HttpInspectorService {
  /// Initialize the HTTP inspector with configuration
  ///
  /// Must be called before using any other methods.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = await httpInspector.initialize(
  ///   HttpInspectorConfig(
  ///     showNotifications: true,
  ///     showOnRelease: false,
  ///     showOnlyErrors: true,
  ///   ),
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Failed to initialize: $failure'),
  ///   (_) => print('Initialized successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> initialize(HttpInspectorConfig config);

  /// Get Dio interceptor for inspecting Dio requests
  ///
  /// Add the returned interceptor to your Dio instance to enable inspection.
  ///
  /// Returns [Right(Interceptor)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = httpInspector.getDioInterceptor();
  /// result.fold(
  ///   (failure) => print('Failed to get interceptor: $failure'),
  ///   (interceptor) => dio.interceptors.add(interceptor),
  /// );
  /// ```
  Either<Failure, dynamic> getDioInterceptor();

  /// Get HTTP client wrapper for inspecting http package requests
  ///
  /// Wrap your http.Client instance with the returned client to enable inspection.
  ///
  /// Returns [Right(HttpClient)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = httpInspector.getHttpClient(http.Client());
  /// result.fold(
  ///   (failure) => print('Failed to get client: $failure'),
  ///   (client) {
  ///     final response = await client.get(Uri.parse('https://api.example.com'));
  ///   },
  /// );
  /// ```
  Either<Failure, dynamic> getHttpClient(dynamic baseClient);

  /// Get Chopper interceptor for inspecting Chopper requests
  ///
  /// Add the returned interceptor to your ChopperClient instance to enable inspection.
  ///
  /// Returns [Right(Interceptor)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = httpInspector.getChopperInterceptor();
  /// result.fold(
  ///   (failure) => print('Failed to get interceptor: $failure'),
  ///   (interceptor) => ChopperClient(
  ///     interceptors: [interceptor],
  ///   ),
  /// );
  /// ```
  Either<Failure, dynamic> getChopperInterceptor();

  /// Get navigator observer for navigating to inspector UI
  ///
  /// Add the returned observer to your MaterialApp to enable navigation to inspector screens.
  ///
  /// Returns navigator observer instance.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [httpInspector.getNavigatorObserver()],
  ///   home: MyHomePage(),
  /// );
  /// ```
  NavigatorObserver getNavigatorObserver();

  /// Update inspector configuration at runtime
  ///
  /// Allows changing inspector behavior without restarting the app.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = await httpInspector.updateConfig(
  ///   config.copyWith(showOnlyErrors: true),
  /// );
  /// ```
  Future<Either<Failure, void>> updateConfig(HttpInspectorConfig config);

  /// Get current configuration
  ///
  /// Returns [Right(HttpInspectorConfig)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = httpInspector.getConfig();
  /// result.fold(
  ///   (failure) => print('Failed to get config: $failure'),
  ///   (config) => print('Current config: $config'),
  /// );
  /// ```
  Either<Failure, HttpInspectorConfig> getConfig();

  /// Clear all stored HTTP requests/responses
  ///
  /// Useful for privacy or testing purposes.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = await httpInspector.clearData();
  /// result.fold(
  ///   (failure) => print('Failed to clear data: $failure'),
  ///   (_) => print('Data cleared successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> clearData();

  /// Check if inspector is enabled
  ///
  /// Returns true if inspector is currently active and inspecting requests.
  ///
  /// Example:
  /// ```dart
  /// if (httpInspector.isEnabled()) {
  ///   print('Inspector is active');
  /// }
  /// ```
  bool isEnabled();

  /// Enable or disable inspector at runtime
  ///
  /// Allows toggling inspector without changing configuration.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// final result = await httpInspector.setEnabled(false);
  /// result.fold(
  ///   (failure) => print('Failed to disable: $failure'),
  ///   (_) => print('Inspector disabled'),
  /// );
  /// ```
  Future<Either<Failure, void>> setEnabled(bool enabled);

  /// Show inspector UI manually
  ///
  /// Navigates to the inspector screen to view captured requests.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// // Add a debug button in your app
  /// ElevatedButton(
  ///   onPressed: () async {
  ///     await httpInspector.showInspectorUI(context);
  ///   },
  ///   child: Text('Show HTTP Inspector'),
  /// );
  /// ```
  Future<Either<Failure, void>> showInspectorUI(BuildContext context);

  /// Dispose and cleanup resources
  ///
  /// Should be called when inspector is no longer needed.
  ///
  /// Returns [Right(void)] on success, [Left(HttpInspectorFailure)] on failure.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   httpInspector.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<Either<Failure, void>> dispose();
}
