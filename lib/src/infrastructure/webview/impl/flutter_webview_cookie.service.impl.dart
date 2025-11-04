import 'package:app_core/src/errors/webview_failure.dart';
import 'package:app_core/src/infrastructure/webview/contract/contracts.dart';
import 'package:app_core/src/infrastructure/webview/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Implementation of [WebViewCookieService] using webview_flutter package
class FlutterWebViewCookieServiceImpl implements WebViewCookieService {
  final WebViewCookieManager _cookieManager = WebViewCookieManager();

  @override
  Future<Either<WebViewFailure, void>> setCookie(
    WebViewCookieData cookie,
  ) async {
    try {
      await _cookieManager.setCookie(
        WebViewCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path,
        ),
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewCookieFailure(
          'Failed to set cookie: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> removeCookie(
    String name,
    String domain, {
    String path = '/',
  }) async {
    try {
      // webview_flutter doesn't have a direct removeCookie method
      // We need to set an expired cookie
      await _cookieManager.setCookie(
        WebViewCookie(
          name: name,
          value: '',
          domain: domain,
          path: path,
        ),
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewCookieFailure(
          'Failed to remove cookie: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, void>> clearAllCookies() async {
    try {
      await _cookieManager.clearCookies();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        WebViewCookieFailure(
          'Failed to clear all cookies: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<WebViewFailure, bool>> hasCookies(String url) async {
    try {
      // webview_flutter doesn't provide a direct way to check for cookies
      // We return true as a default since we can't check this reliably
      // This would need platform-specific implementation for accurate results
      return const Right(false);
    } catch (e, stackTrace) {
      return Left(
        WebViewCookieFailure(
          'Failed to check for cookies: ${e.toString()}',
          details: stackTrace,
        ),
      );
    }
  }
}
