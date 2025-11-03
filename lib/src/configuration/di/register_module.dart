import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    as fbs;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../infrastructure/background_service/background_service.dart';

/// Injectable module for registering third-party/external dependencies
///
/// This module registers instances of external libraries that are needed
/// by our services but don't have @injectable annotations themselves.
///
/// Note: HttpClient is NOT registered here because it requires configuration
/// (baseUrl, headers, etc.) that varies per consumer app.
/// Each consumer app must register HttpClient manually in their DI setup.
/// See example in: example/network_example.dart
@module
abstract class RegisterModule {
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
}
