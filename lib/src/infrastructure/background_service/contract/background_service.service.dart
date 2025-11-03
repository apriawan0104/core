import 'package:dartz/dartz.dart';

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/background_service/entities.dart';

/// Callback function for service start
/// This will be executed in a separate isolate
typedef ServiceStartCallback = Future<void> Function(ServiceInstance service);

/// Callback for iOS background fetch
typedef IosBackgroundCallback = Future<bool> Function(ServiceInstance service);

/// Abstract service instance that runs in background isolate
/// This represents the service instance in the background
abstract class ServiceInstance {
  /// Listen to method invocations from UI isolate
  ///
  /// Example:
  /// ```dart
  /// service.on('stop').listen((data) {
  ///   service.stopSelf();
  /// });
  /// ```
  Stream<BackgroundServiceData?> on(String method);

  /// Invoke a method to send data to UI isolate
  ///
  /// Example:
  /// ```dart
  /// service.invoke('update', {'progress': 50});
  /// ```
  Future<void> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]);

  /// Stop the service
  Future<void> stopSelf();

  /// Check if service is running in foreground mode (Android only)
  Future<bool> isForegroundService();

  /// Set service as foreground service (Android only)
  Future<void> setAsForegroundService();

  /// Set service as background service (Android only)
  Future<void> setAsBackgroundService();
}

/// Background Service
///
/// This service allows you to execute Dart code in background even when
/// the application is closed or minimized.
///
/// **Important Notes:**
/// - On Android: Can run as foreground service (shows notification) or
///   background service (no notification but may be killed by system)
/// - On iOS: Limited background execution due to iOS restrictions
///
/// Example:
/// ```dart
/// // Configure the service
/// final service = getIt<BackgroundService>();
///
/// await service.configure(
///   config: BackgroundServiceConfig(
///     autoStart: true,
///     isForegroundMode: true,
///     notificationChannelId: 'my_channel',
///     initialNotificationTitle: 'Service Running',
///     initialNotificationContent: 'Background task in progress',
///   ),
///   onStart: onServiceStart,
/// );
///
/// // Start the service
/// await service.start();
///
/// // Send data to service
/// await service.invoke('doSomething', {'key': 'value'});
///
/// // Listen for data from service
/// service.on('update').listen((data) {
///   print('Received: ${data?.payload}');
/// });
/// ```
abstract class BackgroundService {
  /// Configure the background service
  ///
  /// Must be called before [start]. It's recommended to call this in main()
  /// to ensure the callback handler is properly registered.
  ///
  /// Parameters:
  /// - [config]: Configuration for the service
  /// - [onStart]: Callback executed when service starts (runs in separate isolate)
  /// - [iosBackgroundCallback]: Optional callback for iOS background fetch
  Future<Either<Failure, void>> configure({
    required BackgroundServiceConfig config,
    required ServiceStartCallback onStart,
    IosBackgroundCallback? iosBackgroundCallback,
  });

  /// Start the background service
  ///
  /// Returns success if service started successfully
  Future<Either<Failure, void>> start();

  /// Check if service is currently running
  Future<Either<Failure, bool>> isRunning();

  /// Invoke a method to send data to the background service
  ///
  /// The background service can listen to this using [ServiceInstance.on]
  ///
  /// Example:
  /// ```dart
  /// // From UI
  /// await service.invoke('fetchData', {'url': 'https://api.example.com'});
  ///
  /// // In background service
  /// service.on('fetchData').listen((data) {
  ///   final url = data?.payload?['url'];
  ///   // Fetch data from url
  /// });
  /// ```
  Future<Either<Failure, void>> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]);

  /// Listen to method invocations from the background service
  ///
  /// The background service can send data using [ServiceInstance.invoke]
  ///
  /// Example:
  /// ```dart
  /// // From UI
  /// service.on('progress').listen((data) {
  ///   final progress = data?.payload?['progress'];
  ///   print('Progress: $progress%');
  /// });
  ///
  /// // In background service
  /// await service.invoke('progress', {'progress': 75});
  /// ```
  Stream<BackgroundServiceData?> on(String method);
}
