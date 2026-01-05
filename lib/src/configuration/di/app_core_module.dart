import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    as fbs;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../infrastructure/background_service/background_service.dart';
import '../../infrastructure/logging/logging.dart';
import '../../infrastructure/secure_storage/secure_storage.dart';
import '../../infrastructure/storage/storage.dart';
import '../../infrastructure/url_launcher/url_launcher.dart'; // ← Tambahkan ini

/// Injectable module for registering third-party/external dependencies
///
/// This module registers instances of external libraries and core services
/// that are needed by consumer apps.
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

  /// Provides singleton instance of UrlLauncherService
  @lazySingleton
  UrlLauncherService get urlLauncherService =>
      UrlLauncherServiceImpl(); // ← Tambahkan ini
}
