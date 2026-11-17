import 'package:flutter/foundation.dart';

/// Platform checks that stay valid on web.
///
/// `dart:io` `Platform` cannot be imported from web code.
abstract final class PushPlatform {
  static bool get isWeb => kIsWeb;

  static bool get isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
