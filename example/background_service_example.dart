// ignore_for_file: avoid_print, unused_local_variable

import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:app_core/app_core.dart';
// In real app, import flutter_background_service
// import 'package:flutter_background_service/flutter_background_service.dart' as fbs;

/// Example: Background Service Implementation
/// 
/// This example demonstrates how to implement and use background service
/// for running tasks in background even when app is closed.

// ============================================================================
// 1. SETUP: Create Background Service Entry Point
// ============================================================================

/// Background service entry point
/// Must be annotated with @pragma('vm:entry-point') for release mode
@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  print('🚀 Background service started');

  // Listen for stop command from UI
  service.on('stop').listen((data) async {
    print('🛑 Stop command received');
    await service.stopSelf();
  });

  // Listen for custom commands
  service.on('fetch_data').listen((data) {
    print('📥 Fetch data command received: ${data?.payload}');
    // Perform data fetching
    // Send result back to UI
    service.invoke('data_fetched', {
      'status': 'success',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  // Periodic background task
  var counter = 0;
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    // Check if service is still running
    if (await service.isForegroundService()) {
      counter++;
      print('⏰ Periodic task #$counter at ${DateTime.now()}');

      // Send progress update to UI
      service.invoke('progress', {
        'count': counter,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      // Service stopped, cancel timer
      timer.cancel();
      print('⏹️ Service stopped, cancelling timer');
    }
  });
}

/// iOS background callback (optional)
/// iOS has strict limitations - max 15-30 seconds execution
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  print('📱 iOS background fetch triggered');

  // Do quick background work
  // Example: sync data, check for updates, etc.

  // Return true to indicate success
  return true;
}

// ============================================================================
// 2. CONFIGURATION: Setup in main()
// ============================================================================

Future<void> setupBackgroundService() async {
  print('⚙️ Setting up background service...');

  // In real app, get from DI container
  // final service = getIt<BackgroundService>();

  // For this example, create instance directly
  // final service = FlutterBackgroundServiceImpl(
  //   fbs.FlutterBackgroundService(),
  // );

  // Example configuration
  final config = BackgroundServiceConfig(
    autoStart: true,
    autoStartOnBoot: true,
    isForegroundMode: true, // Recommended for reliability
    notificationChannelId: 'example_bg_service',
    initialNotificationTitle: 'Background Service',
    initialNotificationContent: 'Service is running in background',
    foregroundServiceNotificationId: 999,
    customConfig: {
      'api_url': 'https://api.example.com',
      'sync_interval': 60,
    },
  );

  // Configure service
  // final result = await service.configure(
  //   config: config,
  //   onStart: onBackgroundServiceStart,
  //   iosBackgroundCallback: onIosBackground,
  // );

  // result.fold(
  //   (failure) => print('❌ Failed to configure: ${failure.message}'),
  //   (_) => print('✅ Service configured successfully'),
  // );

  print('✅ Background service setup complete');
}

// ============================================================================
// 3. USAGE: Interacting with Service
// ============================================================================

class BackgroundServiceUsageExample {
  // In real app, inject via DI
  // final BackgroundService _service;
  //
  // BackgroundServiceUsageExample(this._service);

  /// Start the background service
  Future<void> startService() async {
    print('\n📍 Starting background service...');

    // final result = await _service.start();

    // result.fold(
    //   (failure) => print('❌ Failed to start: ${failure.message}'),
    //   (_) => print('✅ Service started successfully'),
    // );
  }

  /// Check if service is running
  Future<void> checkServiceStatus() async {
    print('\n📍 Checking service status...');

    // final result = await _service.isRunning();

    // result.fold(
    //   (failure) => print('❌ Error checking status: ${failure.message}'),
    //   (isRunning) => print('ℹ️ Service is ${isRunning ? 'running' : 'stopped'}'),
    // );
  }

  /// Send command to background service
  Future<void> sendCommand() async {
    print('\n📍 Sending fetch_data command...');

    // final result = await _service.invoke('fetch_data', {
    //   'url': 'https://api.example.com/data',
    //   'params': {'limit': 10},
    // });

    // result.fold(
    //   (failure) => print('❌ Failed to send: ${failure.message}'),
    //   (_) => print('✅ Command sent successfully'),
    // );
  }

  /// Listen to updates from background service
  StreamSubscription<BackgroundServiceData?>? listenToUpdates() {
    print('\n📍 Listening to service updates...');

    // return _service.on('progress').listen((data) {
    //   if (data != null) {
    //     print('📊 Progress update: ${data.payload}');
    //   }
    // });

    return null;
  }

  /// Stop the background service
  Future<void> stopService() async {
    print('\n📍 Stopping background service...');

    // final result = await _service.invoke('stop');

    // result.fold(
    //   (failure) => print('❌ Failed to stop: ${failure.message}'),
    //   (_) => print('✅ Stop command sent'),
    // );
  }
}

// ============================================================================
// 4. USE CASES: Common Scenarios
// ============================================================================

/// Use Case 1: Periodic Data Sync
class PeriodicSyncExample {
  Future<void> setupPeriodicSync() async {
    print('\n📍 Use Case: Periodic Data Sync');

    final config = BackgroundServiceConfig(
      autoStart: true,
      isForegroundMode: true,
      initialNotificationTitle: 'Data Sync',
      initialNotificationContent: 'Syncing data...',
    );

    print('⚙️ Config: Sync every 15 minutes');
    print('⚙️ Mode: Foreground service');
  }
}

/// Use Case 2: Location Tracking
class LocationTrackingExample {
  Future<void> setupLocationTracking() async {
    print('\n📍 Use Case: Location Tracking');

    final config = BackgroundServiceConfig(
      autoStart: true,
      isForegroundMode: true,
      initialNotificationTitle: 'Location Tracking',
      initialNotificationContent: 'Tracking your location',
    );

    print('⚙️ Config: Continuous location tracking');
    print('⚙️ Note: Need FOREGROUND_SERVICE_LOCATION permission on Android 14+');
  }
}

/// Use Case 3: Background Download
class BackgroundDownloadExample {
  Future<void> setupBackgroundDownload() async {
    print('\n📍 Use Case: Background Download');

    final config = BackgroundServiceConfig(
      autoStart: false, // Start manually when download begins
      isForegroundMode: true,
      initialNotificationTitle: 'Downloading',
      initialNotificationContent: 'Download in progress...',
    );

    print('⚙️ Config: Manual start for downloads');
    print('⚙️ Update notification with progress');
  }
}

/// Use Case 4: Background API Polling (No Notification)
class BackgroundPollingExample {
  Future<void> setupBackgroundPolling() async {
    print('\n📍 Use Case: Background API Polling');

    final config = BackgroundServiceConfig(
      autoStart: true,
      isForegroundMode: false, // No notification
      autoStartOnBoot: true,
    );

    print('⚙️ Config: Background mode (no notification)');
    print('⚠️ Warning: May be killed by system');
    print('⚠️ Warning: Requires battery optimization disabled');
  }
}

// ============================================================================
// 5. TESTING: Mock Implementation
// ============================================================================

class MockBackgroundService implements BackgroundService {
  bool _isRunning = false;
  final _controller = StreamController<BackgroundServiceData?>.broadcast();

  @override
  Future<Either<Failure, void>> configure({
    required BackgroundServiceConfig config,
    required ServiceStartCallback onStart,
    IosBackgroundCallback? iosBackgroundCallback,
  }) async {
    print('🧪 Mock: Service configured');
    return right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, void>> start() async {
    _isRunning = true;
    print('🧪 Mock: Service started');
    return right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, bool>> isRunning() async {
    return right<Failure, bool>(_isRunning);
  }

  @override
  Future<Either<Failure, void>> invoke(
    String method, [
    Map<String, dynamic>? payload,
  ]) async {
    print('🧪 Mock: Invoked $method with $payload');

    if (method == 'stop') {
      _isRunning = false;
    }

    return right<Failure, void>(null);
  }

  @override
  Stream<BackgroundServiceData?> on(String method) {
    return _controller.stream
        .where((data) => data?.method == method);
  }

  void simulateUpdate(String method, Map<String, dynamic> payload) {
    _controller.add(BackgroundServiceData(
      method: method,
      payload: payload,
    ));
  }

  void dispose() {
    _controller.close();
  }
}

// ============================================================================
// MAIN: Run Examples
// ============================================================================

void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('📱 Background Service Example');
  print('═══════════════════════════════════════════════════════════\n');

  // Setup
  await setupBackgroundService();

  // Usage examples
  final example = BackgroundServiceUsageExample();
  await example.startService();
  await example.checkServiceStatus();
  await example.sendCommand();
  final subscription = example.listenToUpdates();
  
  // Simulate some work
  await Future.delayed(const Duration(seconds: 2));
  
  await example.stopService();
  await subscription?.cancel();

  // Use cases
  await PeriodicSyncExample().setupPeriodicSync();
  await LocationTrackingExample().setupLocationTracking();
  await BackgroundDownloadExample().setupBackgroundDownload();
  await BackgroundPollingExample().setupBackgroundPolling();

  // Testing
  print('\n═══════════════════════════════════════════════════════════');
  print('🧪 Testing with Mock');
  print('═══════════════════════════════════════════════════════════\n');

  final mock = MockBackgroundService();
  await mock.configure(
    config: const BackgroundServiceConfig(),
    onStart: onBackgroundServiceStart,
  );
  await mock.start();

  mock.on('progress').listen((data) {
    print('📊 Received update: ${data?.payload}');
  });

  mock.simulateUpdate('progress', {'count': 1});
  await Future.delayed(const Duration(milliseconds: 100));

  await mock.invoke('stop');
  mock.dispose();

  print('\n✅ All examples completed!');
  print('═══════════════════════════════════════════════════════════\n');
}

