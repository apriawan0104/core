import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'push_notification.settings.dart';
import 'push_platform.dart';

/// Starts Firebase when the native project files or [settings] contain options.
///
/// Returns false on web and when Firebase has not been configured yet, so the
/// rest of the app can still launch.
Future<bool> ensurePushFirebase(PushNotificationSettings settings) async {
  if (PushPlatform.isWeb) return false;
  if (Firebase.apps.isNotEmpty) return true;

  try {
    final options = _firebaseOptions(settings);
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
    return true;
  } catch (error, stackTrace) {
    debugPrint('Firebase push is not configured: $error\n$stackTrace');
    return false;
  }
}

FirebaseOptions? _firebaseOptions(PushNotificationSettings settings) {
  if (PushPlatform.isAndroid) {
    return _options(
      apiKey: settings.androidApiKey,
      appId: settings.androidAppId,
      messagingSenderId: settings.androidMessagingSenderId,
      projectId: settings.androidProjectId,
    );
  }
  if (PushPlatform.isIos) {
    return _options(
      apiKey: settings.iosApiKey,
      appId: settings.iosAppId,
      messagingSenderId: settings.iosMessagingSenderId,
      projectId: settings.iosProjectId,
      iosBundleId: settings.iosBundleId,
    );
  }
  return null;
}

FirebaseOptions? _options({
  required String apiKey,
  required String appId,
  required String messagingSenderId,
  required String projectId,
  String? iosBundleId,
}) {
  if (apiKey.isEmpty ||
      appId.isEmpty ||
      messagingSenderId.isEmpty ||
      projectId.isEmpty) {
    return null;
  }
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    iosBundleId: iosBundleId,
  );
}
