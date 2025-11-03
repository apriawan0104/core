import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Injectable module for registering third-party/external dependencies
///
/// This module registers instances of external libraries that are needed
/// by our services but don't have @injectable annotations themselves.
@module
abstract class RegisterModule {
  /// Provides singleton instance of FirebaseMessaging
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  /// Provides singleton instance of FlutterLocalNotificationsPlugin
  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}

