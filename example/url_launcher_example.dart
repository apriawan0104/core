// ignore_for_file: avoid_print

import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

/// Example demonstrating URL Launcher service usage
///
/// This example shows how to:
/// 1. Setup and register the service
/// 2. Launch web URLs
/// 3. Send emails
/// 4. Make phone calls
/// 5. Send SMS
/// 6. Handle errors properly

final getIt = GetIt.instance;

void main() async {
  // Setup
  setupUrlLauncherService();

  // Examples
  await launchWebUrlExample();
  await launchEmailExample();
  await launchPhoneExample();
  await launchSmsExample();
  await checkUrlCanBeLaunchedExample();
  await customConfigurationExample();
}

/// Setup: Register URL Launcher service in DI container
void setupUrlLauncherService() {
  // Register the service implementation
  getIt.registerLazySingleton<UrlLauncherService>(
    () => UrlLauncherServiceImpl(),
  );

  print('✅ URL Launcher service registered');
}

/// Example 1: Launch web URL
Future<void> launchWebUrlExample() async {
  print('\n📱 Example 1: Launch Web URL');

  final urlLauncher = getIt<UrlLauncherService>();

  // Launch with external browser
  final result1 = await urlLauncher.launchWebUrl(
    'https://flutter.dev',
    config: UrlLaunchConfig.externalBrowser,
  );

  result1.fold(
    (failure) => print('❌ Failed to launch: ${failure.message}'),
    (_) => print('✅ Opened in external browser'),
  );

  // Launch with in-app browser
  final result2 = await urlLauncher.launchWebUrl(
    'https://dart.dev',
    config: UrlLaunchConfig.inAppBrowser,
  );

  result2.fold(
    (failure) => print('❌ Failed to launch: ${failure.message}'),
    (_) => print('✅ Opened in in-app browser'),
  );

  // Launch with platform default
  final result3 = await urlLauncher.launchUrl(
    'https://pub.dev',
    config: UrlLaunchConfig.defaultConfig,
  );

  result3.fold(
    (failure) => print('❌ Failed to launch: ${failure.message}'),
    (_) => print('✅ Opened with platform default'),
  );
}

/// Example 2: Send email
Future<void> launchEmailExample() async {
  print('\n📧 Example 2: Send Email');

  final urlLauncher = getIt<UrlLauncherService>();

  // Simple email
  final result1 = await urlLauncher.launchEmail('support@example.com');

  result1.fold(
    (failure) => print('❌ Failed to open email: ${failure.message}'),
    (_) => print('✅ Opened email app'),
  );

  // Email with subject and body
  final result2 = await urlLauncher.launchEmail(
    'feedback@example.com',
    subject: 'App Feedback',
    body: 'I love this app!',
  );

  result2.fold(
    (failure) => print('❌ Failed to open email: ${failure.message}'),
    (_) => print('✅ Opened email with subject and body'),
  );

  // Email with CC and BCC
  final result3 = await urlLauncher.launchEmail(
    'team@example.com',
    subject: 'Meeting Request',
    body: 'Let\'s schedule a meeting',
    cc: ['manager@example.com'],
    bcc: ['admin@example.com'],
  );

  result3.fold(
    (failure) => print('❌ Failed to open email: ${failure.message}'),
    (_) => print('✅ Opened email with CC and BCC'),
  );
}

/// Example 3: Make phone call
Future<void> launchPhoneExample() async {
  print('\n📞 Example 3: Make Phone Call');

  final urlLauncher = getIt<UrlLauncherService>();

  final result = await urlLauncher.launchPhone('+1-800-EXAMPLE');

  result.fold(
    (failure) => print('❌ Failed to open dialer: ${failure.message}'),
    (_) => print('✅ Opened phone dialer'),
  );
}

/// Example 4: Send SMS
Future<void> launchSmsExample() async {
  print('\n💬 Example 4: Send SMS');

  final urlLauncher = getIt<UrlLauncherService>();

  // SMS without message
  final result1 = await urlLauncher.launchSms('+1234567890');

  result1.fold(
    (failure) => print('❌ Failed to open SMS: ${failure.message}'),
    (_) => print('✅ Opened SMS app'),
  );

  // SMS with pre-filled message
  final result2 = await urlLauncher.launchSms(
    '+1234567890',
    message: 'Hello from Flutter!',
  );

  result2.fold(
    (failure) => print('❌ Failed to open SMS: ${failure.message}'),
    (_) => print('✅ Opened SMS with pre-filled message'),
  );
}

/// Example 5: Check if URL can be launched
Future<void> checkUrlCanBeLaunchedExample() async {
  print('\n🔍 Example 5: Check URL Capabilities');

  final urlLauncher = getIt<UrlLauncherService>();

  // Check web URL
  final webCheck = await urlLauncher.canLaunchUrl('https://flutter.dev');
  webCheck.fold(
    (failure) => print('❌ Check failed: ${failure.message}'),
    (canLaunch) =>
        print('Web URL: ${canLaunch ? '✅ Can launch' : '❌ Cannot launch'}'),
  );

  // Check phone URL
  final phoneCheck = await urlLauncher.canLaunchUrl('tel:+1234567890');
  phoneCheck.fold(
    (failure) => print('❌ Check failed: ${failure.message}'),
    (canLaunch) =>
        print('Phone URL: ${canLaunch ? '✅ Can launch' : '❌ Cannot launch'}'),
  );

  // Check email URL
  final emailCheck = await urlLauncher.canLaunchUrl('mailto:test@example.com');
  emailCheck.fold(
    (failure) => print('❌ Check failed: ${failure.message}'),
    (canLaunch) =>
        print('Email URL: ${canLaunch ? '✅ Can launch' : '❌ Cannot launch'}'),
  );

  // Check SMS URL
  final smsCheck = await urlLauncher.canLaunchUrl('sms:+1234567890');
  smsCheck.fold(
    (failure) => print('❌ Check failed: ${failure.message}'),
    (canLaunch) =>
        print('SMS URL: ${canLaunch ? '✅ Can launch' : '❌ Cannot launch'}'),
  );

  // Check if launch mode is supported
  final modeCheck = await urlLauncher.supportsLaunchMode(
    UrlLaunchMode.inAppBrowserView,
  );
  modeCheck.fold(
    (failure) => print('❌ Check failed: ${failure.message}'),
    (isSupported) => print(
      'In-app browser: ${isSupported ? '✅ Supported' : '❌ Not supported'}',
    ),
  );
}

/// Example 6: Custom configuration
Future<void> customConfigurationExample() async {
  print('\n⚙️ Example 6: Custom Configuration');

  final urlLauncher = getIt<UrlLauncherService>();

  // Custom web view configuration
  final customConfig = UrlLaunchConfig(
    mode: UrlLaunchMode.inAppBrowserView,
    enableJavaScript: true,
    enableDomStorage: true,
    headers: {
      'Authorization': 'Bearer token123',
      'Custom-Header': 'value',
    },
    webViewConfiguration: const WebViewConfiguration(
      showTitle: true,
      toolbarColor: '#FF5722',
      enableZoom: false,
    ),
  );

  final result = await urlLauncher.launchWebUrl(
    'https://example.com',
    config: customConfig,
  );

  result.fold(
    (failure) => print('❌ Failed to launch: ${failure.message}'),
    (_) => print('✅ Opened with custom configuration'),
  );

  // Close in-app web view (if opened)
  final closeResult = await urlLauncher.closeInAppWebView();
  closeResult.fold(
    (failure) => print('❌ Failed to close: ${failure.message}'),
    (_) => print('✅ In-app web view closed (if was open)'),
  );
}

/// Example 7: Error handling patterns
Future<void> errorHandlingExample() async {
  print('\n❌ Example 7: Error Handling');

  final urlLauncher = getIt<UrlLauncherService>();

  // Pattern 1: Simple fold
  final result1 = await urlLauncher.launchUrl('https://example.com');
  result1.fold(
    (failure) => print('Error: ${failure.message}'),
    (_) => print('Success'),
  );

  // Pattern 2: Check type of failure
  final result2 = await urlLauncher.launchUrl('invalid-url');
  result2.fold(
    (failure) {
      if (failure.message.contains('Invalid')) {
        print('Invalid URL format');
      } else if (failure.message.contains('Cannot launch')) {
        print('No app can handle this URL');
      } else {
        print('Unknown error: ${failure.message}');
      }
    },
    (_) => print('Success'),
  );

  // Pattern 3: Return value from fold
  final canProceed = result1.fold(
    (failure) => false,
    (_) => true,
  );

  if (canProceed) {
    print('✅ Can proceed with next step');
  } else {
    print('❌ Cannot proceed');
  }

  // Pattern 4: Async operations in fold
  await result1.fold(
    (failure) async {
      // Log error to analytics
      print('Logging error: ${failure.message}');
    },
    (_) async {
      // Track success event
      print('Tracking success event');
    },
  );
}

/// Example 8: Real-world use case - Social media sharing
class SocialMediaService {
  final UrlLauncherService _urlLauncher;

  SocialMediaService(this._urlLauncher);

  Future<void> shareOnTwitter(String text) async {
    final url =
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}';

    final result = await _urlLauncher.launchWebUrl(
      url,
      config: UrlLaunchConfig.externalBrowser,
    );

    result.fold(
      (failure) => print('Failed to share on Twitter: ${failure.message}'),
      (_) => print('Opened Twitter share dialog'),
    );
  }

  Future<void> shareOnWhatsApp(String phoneNumber, String text) async {
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(text)}';

    final result = await _urlLauncher.launchUrl(url);

    result.fold(
      (failure) => print('Failed to open WhatsApp: ${failure.message}'),
      (_) => print('Opened WhatsApp chat'),
    );
  }

  Future<void> openFacebookPage(String pageId) async {
    // Try native app first, fallback to web
    final nativeResult = await _urlLauncher.launchUrl('fb://page/$pageId');

    nativeResult.fold(
      (failure) async {
        // Fallback to web
        print('Native app not available, opening in browser');
        await _urlLauncher.launchWebUrl('https://www.facebook.com/$pageId');
      },
      (_) => print('Opened in Facebook app'),
    );
  }
}

/// Example 9: Testing with mock
class MockUrlLauncherService implements UrlLauncherService {
  @override
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    print('Mock: Would launch $url');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> canLaunchUrl(String url) async {
    print('Mock: Checking if can launch $url');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> supportsLaunchMode(
    UrlLaunchMode mode,
  ) async {
    print('Mock: Checking if supports $mode');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchWebUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    print('Mock: Would launch web URL $url');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    print('Mock: Would send email to $email');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchPhone(
      String phoneNumber) async {
    print('Mock: Would call $phoneNumber');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, bool>> launchSms(
    String phoneNumber, {
    String? message,
  }) async {
    print('Mock: Would send SMS to $phoneNumber');
    return const Right(true);
  }

  @override
  Future<Either<UrlLauncherFailure, void>> closeInAppWebView() async {
    print('Mock: Would close in-app web view');
    return const Right(null);
  }
}
