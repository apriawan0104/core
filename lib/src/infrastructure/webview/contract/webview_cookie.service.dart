import 'package:app_core/src/errors/webview_failure.dart';
import 'package:app_core/src/infrastructure/webview/models/models.dart';
import 'package:dartz/dartz.dart';

/// Abstract interface for WebView cookie management
///
/// This service provides cookie management functionality for webviews.
///
/// Example usage:
/// ```dart
/// final cookieService = getIt<WebViewCookieService>();
///
/// // Set a cookie
/// final cookie = WebViewCookieData(
///   name: 'session',
///   value: 'abc123',
///   domain: 'example.com',
/// );
///
/// final result = await cookieService.setCookie(cookie);
/// ```
abstract class WebViewCookieService {
  /// Set a cookie
  ///
  /// [cookie] - The cookie data to set
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> setCookie(WebViewCookieData cookie);

  /// Remove a cookie
  ///
  /// [name] - Name of the cookie to remove
  /// [domain] - Domain of the cookie
  /// [path] - Path of the cookie (defaults to '/')
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> removeCookie(
    String name,
    String domain, {
    String path = '/',
  });

  /// Clear all cookies
  ///
  /// Returns [Either] containing [WebViewFailure] on error or void on success
  Future<Either<WebViewFailure, void>> clearAllCookies();

  /// Check if cookies exist
  ///
  /// [url] - URL to check cookies for
  ///
  /// Returns [Either] containing [WebViewFailure] on error or boolean on success
  Future<Either<WebViewFailure, bool>> hasCookies(String url);
}
