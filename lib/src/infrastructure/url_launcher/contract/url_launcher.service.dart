import 'package:dartz/dartz.dart';
import 'package:app_core/src/errors/url_launcher_failure.dart';
import 'package:app_core/src/infrastructure/url_launcher/models/models.dart';

/// Abstract service for launching URLs
///
/// This interface provides URL launching capabilities without exposing
/// third-party dependencies. Any implementation (url_launcher, custom_tabs, etc.)
/// can be swapped without changing consumer code.
///
/// Example implementations:
/// - UrlLauncherPackageServiceImpl (using url_launcher package)
/// - CustomTabsServiceImpl (using custom_tabs package)
/// - WebViewServiceImpl (using webview_flutter)
abstract class UrlLauncherService {
  /// Launch a URL with the given configuration
  ///
  /// [url] - The URL to launch (must be properly encoded)
  /// [config] - Configuration for how to launch the URL
  ///
  /// Returns [Right(true)] if URL was launched successfully
  /// Returns [Left(UrlLauncherFailure)] if launch failed
  ///
  /// Example:
  /// ```dart
  /// final result = await urlLauncher.launchUrl(
  ///   'https://flutter.dev',
  ///   config: UrlLaunchConfig.externalBrowser,
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Failed: ${failure.message}'),
  ///   (success) => print('Launched successfully'),
  /// );
  /// ```
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  });

  /// Check if a URL can be launched
  ///
  /// [url] - The URL to check
  ///
  /// Returns [Right(true)] if URL can be launched
  /// Returns [Right(false)] if URL cannot be launched
  /// Returns [Left(UrlLauncherFailure)] if check failed
  ///
  /// Note: This may return false even if launchUrl would work in some cases.
  /// See package documentation for platform-specific behavior.
  ///
  /// Example:
  /// ```dart
  /// final canLaunch = await urlLauncher.canLaunchUrl('tel:+1234567890');
  /// canLaunch.fold(
  ///   (failure) => print('Check failed: ${failure.message}'),
  ///   (can) => print(can ? 'Can launch' : 'Cannot launch'),
  /// );
  /// ```
  Future<Either<UrlLauncherFailure, bool>> canLaunchUrl(String url);

  /// Check if a specific launch mode is supported on current platform
  ///
  /// [mode] - The launch mode to check
  ///
  /// Returns [Right(true)] if launch mode is supported
  /// Returns [Right(false)] if launch mode is not supported
  /// Returns [Left(UrlLauncherFailure)] if check failed
  ///
  /// Example:
  /// ```dart
  /// final isSupported = await urlLauncher.supportsLaunchMode(
  ///   UrlLaunchMode.inAppBrowserView,
  /// );
  /// ```
  Future<Either<UrlLauncherFailure, bool>> supportsLaunchMode(
    UrlLaunchMode mode,
  );

  /// Launch a web URL
  ///
  /// Convenience method specifically for web URLs (http/https).
  ///
  /// [url] - The web URL to launch
  /// [config] - Configuration for how to launch the URL
  ///
  /// Returns [Right(true)] if URL was launched successfully
  /// Returns [Left(UrlLauncherFailure)] if launch failed
  Future<Either<UrlLauncherFailure, bool>> launchWebUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  });

  /// Launch email with optional subject and body
  ///
  /// [email] - The email address
  /// [subject] - Optional email subject
  /// [body] - Optional email body
  /// [cc] - Optional CC recipients
  /// [bcc] - Optional BCC recipients
  ///
  /// Returns [Right(true)] if email app was launched successfully
  /// Returns [Left(UrlLauncherFailure)] if launch failed
  ///
  /// Example:
  /// ```dart
  /// await urlLauncher.launchEmail(
  ///   'support@example.com',
  ///   subject: 'Bug Report',
  ///   body: 'I found a bug...',
  /// );
  /// ```
  Future<Either<UrlLauncherFailure, bool>> launchEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  });

  /// Launch phone call
  ///
  /// [phoneNumber] - The phone number to call (e.g., '+1234567890')
  ///
  /// Returns [Right(true)] if phone app was launched successfully
  /// Returns [Left(UrlLauncherFailure)] if launch failed
  ///
  /// Example:
  /// ```dart
  /// await urlLauncher.launchPhone('+1234567890');
  /// ```
  Future<Either<UrlLauncherFailure, bool>> launchPhone(String phoneNumber);

  /// Launch SMS with optional message
  ///
  /// [phoneNumber] - The phone number to send SMS to
  /// [message] - Optional message body
  ///
  /// Returns [Right(true)] if SMS app was launched successfully
  /// Returns [Left(UrlLauncherFailure)] if launch failed
  ///
  /// Example:
  /// ```dart
  /// await urlLauncher.launchSms(
  ///   '+1234567890',
  ///   message: 'Hello from app!',
  /// );
  /// ```
  Future<Either<UrlLauncherFailure, bool>> launchSms(
    String phoneNumber, {
    String? message,
  });

  /// Close in-app web view (if currently open)
  ///
  /// Only applicable when using in-app web view mode.
  /// Has no effect on other launch modes.
  ///
  /// Returns [Right(void)] if closed successfully or not applicable
  /// Returns [Left(UrlLauncherFailure)] if close failed
  Future<Either<UrlLauncherFailure, void>> closeInAppWebView();
}
