import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    as fbs;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../infrastructure/background_service/background_service.dart';
import '../../infrastructure/logging/logging.dart';
import '../../infrastructure/secure_storage/secure_storage.dart';
import '../../infrastructure/storage/storage.dart';

/// Injectable module for registering third-party/external dependencies
///
/// This module registers instances of external libraries and core services
/// that are needed by consumer apps.
///
/// Note: HttpClient is NOT registered here because it requires configuration
/// (baseUrl, headers, etc.) that varies per consumer app.
/// Each consumer app must register HttpClient manually in their DI setup.
@module
abstract class AppCoreModule {
  /// Provides singleton instance of FirebaseMessaging
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  /// Provides singleton instance of FlutterLocalNotificationsPlugin
  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  /// Provides singleton instance of BackgroundService
  @lazySingleton
  BackgroundService get backgroundService => FlutterBackgroundServiceImpl(
        fbs.FlutterBackgroundService(),
      );

  /// Provides singleton instance of SecureStorageService
  @lazySingleton
  SecureStorageService get secureStorageService =>
      FlutterSecureStorageServiceImpl();

  /// Provides singleton instance of StorageService
  @lazySingleton
  StorageService get storageService => HiveStorageServiceImpl();

  /// Provides singleton instance of LogService
  @lazySingleton
  LogService get logService => const ConsoleLogServiceImpl();

  // Note: HttpClient registration example:
  //
  // In your consumer app's DI setup:
  //
  // getIt.registerLazySingleton<HttpClient>(
  //   () => DioHttpClient(
  //     baseUrl: 'https://api.your-app.com',
  //     headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //     connectTimeout: 30000,
  //     receiveTimeout: 30000,
  //     enableLogging: !kReleaseMode,
  //   ),
  // );

  // Note: ChartService registration example:
  //
  // ChartService is NOT auto-registered to keep core library independent
  // from chart dependencies. Register manually in consumer app if needed.
  //
  // First, add to pubspec.yaml:
  //   syncfusion_flutter_charts: ^31.2.4
  //
  // Then register in your DI setup:
  //
  // getIt.registerLazySingleton<ChartService>(
  //   () => SyncfusionChartServiceImpl(),
  // );
  //
  // See CHART_SETUP.md for complete setup guide.
}
