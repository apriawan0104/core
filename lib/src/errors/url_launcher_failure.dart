import 'package:app_core/src/errors/failures.dart';

/// Failure class for URL launcher related errors
class UrlLauncherFailure extends Failure {
  const UrlLauncherFailure(String message) : super(message: message);

  /// Factory constructor for when URL cannot be launched
  factory UrlLauncherFailure.cannotLaunch(String url) {
    return UrlLauncherFailure('Cannot launch URL: $url');
  }

  /// Factory constructor for when URL is invalid
  factory UrlLauncherFailure.invalidUrl(String url) {
    return UrlLauncherFailure('Invalid URL format: $url');
  }

  /// Factory constructor for when launch mode is not supported
  factory UrlLauncherFailure.launchModeNotSupported(String mode) {
    return UrlLauncherFailure('Launch mode not supported: $mode');
  }

  /// Factory constructor for when URL scheme is not supported
  factory UrlLauncherFailure.schemeNotSupported(String scheme) {
    return UrlLauncherFailure('URL scheme not supported: $scheme');
  }

  /// Factory constructor for platform-specific errors
  factory UrlLauncherFailure.platformError(String message) {
    return UrlLauncherFailure('Platform error: $message');
  }

  /// Factory constructor for generic errors
  factory UrlLauncherFailure.unknown(String message) {
    return UrlLauncherFailure('Unknown error: $message');
  }
}
