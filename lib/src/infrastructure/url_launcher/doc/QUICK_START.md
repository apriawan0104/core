# URL Launcher - Quick Start Guide

Quick start guide untuk menggunakan URL Launcher service di BUMA Core.

## 📦 Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # Implementation dependency (url_launcher package)
  url_launcher: ^6.3.2
```

### 2. Platform Configuration

#### iOS (Info.plist)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
  <string>mailto</string>
  <string>tel</string>
  <string>sms</string>
</array>
```

#### Android (AndroidManifest.xml)

```xml
<manifest>
  <!-- Add inside <manifest> tag, outside <application> -->
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="mailto" />
    </intent>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="tel" />
    </intent>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="sms" />
    </intent>
    <intent>
      <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
  </queries>
  
  <application>
    <!-- Your app config -->
  </application>
</manifest>
```

## 🚀 Basic Usage

### 1. Register Service

```dart
// lib/core/di/locator.dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register URL Launcher service
  getIt.registerLazySingleton<UrlLauncherService>(
    () => UrlLauncherServiceImpl(),
  );
}
```

### 2. Launch Web URL

```dart
import 'package:app_core/app_core.dart';

class MyWidget extends StatelessWidget {
  final UrlLauncherService urlLauncher = getIt<UrlLauncherService>();

  Future<void> openWebsite() async {
    final result = await urlLauncher.launchWebUrl(
      'https://flutter.dev',
      config: UrlLaunchConfig.externalBrowser,
    );

    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (success) => print('URL opened successfully'),
    );
  }
}
```

### 3. Launch Email

```dart
Future<void> sendEmail() async {
  final result = await urlLauncher.launchEmail(
    'support@example.com',
    subject: 'Bug Report',
    body: 'I found a bug in the app...',
  );

  result.fold(
    (failure) => showErrorDialog(failure.message),
    (_) => showSuccessMessage(),
  );
}
```

### 4. Launch Phone Call

```dart
Future<void> callSupport() async {
  final result = await urlLauncher.launchPhone('+1234567890');

  result.fold(
    (failure) => print('Cannot make call: ${failure.message}'),
    (_) => print('Opening phone dialer'),
  );
}
```

### 5. Launch SMS

```dart
Future<void> sendSms() async {
  final result = await urlLauncher.launchSms(
    '+1234567890',
    message: 'Hello from my app!',
  );

  result.fold(
    (failure) => print('Cannot send SMS: ${failure.message}'),
    (_) => print('Opening SMS app'),
  );
}
```

## 📱 Launch Modes

```dart
// Open in external browser (default)
await urlLauncher.launchWebUrl(
  'https://example.com',
  config: UrlLaunchConfig.externalBrowser,
);

// Open in in-app browser (Custom Tabs/Safari View Controller)
await urlLauncher.launchWebUrl(
  'https://example.com',
  config: UrlLaunchConfig.inAppBrowser,
);

// Open in in-app web view
await urlLauncher.launchWebUrl(
  'https://example.com',
  config: UrlLaunchConfig.inAppWebView,
);
```

## ✅ Check Before Launch

```dart
Future<void> openUrlSafely(String url) async {
  // Check if URL can be launched
  final canLaunch = await urlLauncher.canLaunchUrl(url);
  
  await canLaunch.fold(
    (failure) async {
      print('Check failed: ${failure.message}');
    },
    (can) async {
      if (can) {
        await urlLauncher.launchUrl(url);
      } else {
        print('Cannot launch this URL');
      }
    },
  );
}
```

## 🎨 Custom Configuration

```dart
final customConfig = UrlLaunchConfig(
  mode: UrlLaunchMode.inAppBrowserView,
  enableJavaScript: true,
  enableDomStorage: true,
  webViewConfiguration: WebViewConfiguration(
    showTitle: true,
    toolbarColor: '#FF5722',
    enableZoom: false,
  ),
);

await urlLauncher.launchWebUrl(
  'https://example.com',
  config: customConfig,
);
```

## ⚠️ Error Handling

```dart
Future<void> launchWithErrorHandling(String url) async {
  final result = await urlLauncher.launchUrl(url);

  result.fold(
    (failure) {
      // Handle different types of failures
      if (failure.message.contains('Cannot launch')) {
        showDialog(context, 'No app can handle this URL');
      } else if (failure.message.contains('Invalid')) {
        showDialog(context, 'Invalid URL format');
      } else {
        showDialog(context, 'Unknown error: ${failure.message}');
      }
    },
    (_) => print('Success'),
  );
}
```

## 🔧 Testing

```dart
// Create mock for testing
class MockUrlLauncherService implements UrlLauncherService {
  @override
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    // Mock implementation
    return const Right(true);
  }

  // Implement other methods...
}

// Use in tests
final mockLauncher = MockUrlLauncherService();
```

## 📚 Next Steps

- See [README.md](README.md) for detailed documentation
- Check [example app](/example) for more examples
- Read about [architecture patterns](/ARCHITECTURE.md)

## 🆘 Common Issues

### "Cannot launch URL" on iOS

**Solution**: Add URL scheme to Info.plist (see Platform Configuration above)

### "Cannot launch URL" on Android 11+

**Solution**: Add `<queries>` to AndroidManifest.xml (see Platform Configuration above)

### URL with special characters not working

**Solution**: Use `Uri.parse()` to properly encode the URL:

```dart
final uri = Uri.parse('https://example.com/search?q=hello world');
await urlLauncher.launchUrl(uri.toString());
```

## 💡 Pro Tips

1. **Always handle errors** - `launchUrl` can fail for many reasons
2. **Check canLaunchUrl for better UX** - Hide buttons if URL can't be launched
3. **Use appropriate launch mode** - External browser for links, in-app for auth flows
4. **Test on real devices** - Simulators may not have phone/SMS apps
5. **Encode query parameters** - Use `Uri` class for proper encoding

