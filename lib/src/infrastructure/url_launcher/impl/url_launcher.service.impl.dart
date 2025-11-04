import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:app_core/src/errors/url_launcher_failure.dart';
import 'package:app_core/src/infrastructure/url_launcher/contract/contracts.dart';
import 'package:app_core/src/infrastructure/url_launcher/models/models.dart';

/// Implementation of [UrlLauncherService] using the url_launcher package
/// 
/// This implementation wraps the url_launcher package to provide
/// dependency-independent URL launching capabilities.
/// 
/// To switch to a different provider (e.g., custom_tabs, webview_flutter),
/// simply create a new implementation of [UrlLauncherService] and update
/// the DI registration.
class UrlLauncherServiceImpl implements UrlLauncherService {
  /// Convert our [UrlLaunchMode] to url_launcher's LaunchMode
  url_launcher.LaunchMode _convertLaunchMode(UrlLaunchMode mode) {
    switch (mode) {
      case UrlLaunchMode.platformDefault:
        return url_launcher.LaunchMode.platformDefault;
      case UrlLaunchMode.inAppWebView:
        return url_launcher.LaunchMode.inAppWebView;
      case UrlLaunchMode.inAppBrowserView:
        return url_launcher.LaunchMode.inAppBrowserView;
      case UrlLaunchMode.externalApplication:
        return url_launcher.LaunchMode.externalApplication;
      case UrlLaunchMode.externalNonBrowserApplication:
        return url_launcher.LaunchMode.externalNonBrowserApplication;
    }
  }

  /// Helper to encode query parameters properly
  String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    try {
      // Parse URL
      final uri = Uri.parse(url);
      
      // Convert launch mode
      final mode = _convertLaunchMode(config.mode);

      // Launch URL with configuration
      final launched = await url_launcher.launchUrl(
        uri,
        mode: mode,
        webViewConfiguration: url_launcher.WebViewConfiguration(
          enableJavaScript: config.enableJavaScript,
          enableDomStorage: config.enableDomStorage,
          headers: config.headers ?? {},
        ),
      );

      if (!launched) {
        return Left(UrlLauncherFailure.cannotLaunch(url));
      }

      return const Right(true);
    } on FormatException catch (e) {
      return Left(UrlLauncherFailure.invalidUrl('$url - ${e.message}'));
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> canLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final can = await url_launcher.canLaunchUrl(uri);
      return Right(can);
    } on FormatException catch (e) {
      return Left(UrlLauncherFailure.invalidUrl('$url - ${e.message}'));
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> supportsLaunchMode(
    UrlLaunchMode mode,
  ) async {
    try {
      final launchMode = _convertLaunchMode(mode);
      final supports = await url_launcher.supportsLaunchMode(launchMode);
      return Right(supports);
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchWebUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    // Validate web URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return Left(UrlLauncherFailure.invalidUrl(
        'Web URL must start with http:// or https://',
      ));
    }

    return launchUrl(url, config: config);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    try {
      // Build query parameters
      final params = <String, String>{};
      if (subject != null) params['subject'] = subject;
      if (body != null) params['body'] = body;
      if (cc != null && cc.isNotEmpty) params['cc'] = cc.join(',');
      if (bcc != null && bcc.isNotEmpty) params['bcc'] = bcc.join(',');

      // Build mailto URI
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters(params),
      );

      final launched = await url_launcher.launchUrl(uri);
      
      if (!launched) {
        return Left(UrlLauncherFailure.cannotLaunch(uri.toString()));
      }

      return const Right(true);
    } on FormatException catch (e) {
      return Left(UrlLauncherFailure.invalidUrl('$email - ${e.message}'));
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchPhone(
    String phoneNumber,
  ) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      final launched = await url_launcher.launchUrl(uri);
      
      if (!launched) {
        return Left(UrlLauncherFailure.cannotLaunch(uri.toString()));
      }

      return const Right(true);
    } on FormatException catch (e) {
      return Left(UrlLauncherFailure.invalidUrl('$phoneNumber - ${e.message}'));
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchSms(
    String phoneNumber, {
    String? message,
  }) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: message != null ? {'body': message} : null,
      );
      
      final launched = await url_launcher.launchUrl(uri);
      
      if (!launched) {
        return Left(UrlLauncherFailure.cannotLaunch(uri.toString()));
      }

      return const Right(true);
    } on FormatException catch (e) {
      return Left(UrlLauncherFailure.invalidUrl('$phoneNumber - ${e.message}'));
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<UrlLauncherFailure, void>> closeInAppWebView() async {
    try {
      await url_launcher.closeInAppWebView();
      return const Right(null);
    } catch (e) {
      return Left(UrlLauncherFailure.unknown(e.toString()));
    }
  }
}

