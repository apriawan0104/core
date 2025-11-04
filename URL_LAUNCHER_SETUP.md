# URL Launcher Setup Guide

Complete setup guide untuk menggunakan URL Launcher service di BUMA Core.

## 📋 Table of Contents

- [Overview](#-overview)
- [Installation](#-installation)
- [Platform Configuration](#-platform-configuration)
- [Basic Setup](#-basic-setup)
- [Usage Examples](#-usage-examples)
- [Advanced Configuration](#-advanced-configuration)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

## 🎯 Overview

URL Launcher service adalah dependency-independent abstraction untuk launching URLs, emails, phone calls, dan SMS messages. Service ini wrap `url_launcher` package sehingga mudah untuk diganti dengan implementasi lain tanpa mengubah business logic.

### Features

- ✅ Launch web URLs (http/https)
- ✅ Compose and send emails
- ✅ Make phone calls
- ✅ Send SMS messages
- ✅ Multiple launch modes (in-app, external, etc.)
- ✅ Cross-platform support (iOS, Android, Web, Desktop)
- ✅ Type-safe with Either monad error handling
- ✅ Easy to test and mock

## 📦 Installation

### 1. Add Dependencies

Package `url_launcher` sudah included di `app_core`, jadi Anda tidak perlu add dependencies lagi.

Jika menggunakan standalone:

```yaml
# pubspec.yaml
dependencies:
  # BUMA Core
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # url_launcher sudah included di app_core
```

### 2. Import Package

```dart
import 'package:app_core/app_core.dart';
```

## ⚙️ Platform Configuration

### iOS Configuration

Add URL schemes ke `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys... -->
    
    <!-- Add this for URL Launcher -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>https</string>
        <string>http</string>
        <string>mailto</string>
        <string>tel</string>
        <string>sms</string>
        <!-- Add other schemes if needed -->
    </array>
</dict>
</plist>
```

**Why?** iOS requires declaring URL schemes that your app will check or launch.

### Android Configuration

Add queries ke `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add inside <manifest>, OUTSIDE <application> -->
    <queries>
        <!-- Web URLs -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
        
        <!-- Email -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="mailto" />
        </intent>
        
        <!-- Phone -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="tel" />
        </intent>
        
        <!-- SMS -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="sms" />
        </intent>
        
        <!-- Custom Tabs support (for in-app browser) -->
        <intent>
            <action android:name="android.support.customtabs.action.CustomTabsService" />
        </intent>
    </queries>
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

**Why?** Android 11 (API 30)+ requires declaring intents your app will interact with for privacy/security.

### Web Configuration

No additional configuration needed for web platform.

### Desktop (Windows, macOS, Linux)

No additional configuration needed for desktop platforms.

## 🚀 Basic Setup

### Step 1: Register Service

Register service di DI container Anda:

```dart
// lib/core/di/locator.dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Register URL Launcher service
  getIt.registerLazySingleton<UrlLauncherService>(
    () => UrlLauncherServiceImpl(),
  );
}
```

### Step 2: Use Service

Inject dan gunakan service:

```dart
import 'package:app_core/app_core.dart';

class MyScreen extends StatelessWidget {
  final UrlLauncherService _urlLauncher = getIt<UrlLauncherService>();

  Future<void> openWebsite() async {
    final result = await _urlLauncher.launchWebUrl(
      'https://flutter.dev',
      config: UrlLaunchConfig.externalBrowser,
    );

    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (_) => print('Success'),
    );
  }
}
```

## 💡 Usage Examples

### 1. Launch Web URL

```dart
// External browser
await _urlLauncher.launchWebUrl(
  'https://flutter.dev',
  config: UrlLaunchConfig.externalBrowser,
);

// In-app browser (Custom Tabs/Safari View Controller)
await _urlLauncher.launchWebUrl(
  'https://flutter.dev',
  config: UrlLaunchConfig.inAppBrowser,
);

// Platform default
await _urlLauncher.launchWebUrl(
  'https://flutter.dev',
  config: UrlLaunchConfig.defaultConfig,
);
```

### 2. Send Email

```dart
// Simple email
await _urlLauncher.launchEmail('support@example.com');

// Email with subject and body
await _urlLauncher.launchEmail(
  'support@example.com',
  subject: 'Bug Report',
  body: 'I found a bug in the app...',
);

// Email with CC and BCC
await _urlLauncher.launchEmail(
  'team@example.com',
  subject: 'Meeting',
  body: 'Let\'s meet tomorrow',
  cc: ['manager@example.com'],
  bcc: ['admin@example.com'],
);
```

### 3. Make Phone Call

```dart
await _urlLauncher.launchPhone('+1-800-EXAMPLE');

// With country code
await _urlLauncher.launchPhone('+62812345678');
```

### 4. Send SMS

```dart
// SMS without message
await _urlLauncher.launchSms('+1234567890');

// SMS with pre-filled message
await _urlLauncher.launchSms(
  '+1234567890',
  message: 'Hello from Flutter!',
);
```

### 5. Check Before Launch

```dart
// Check if URL can be launched
final canLaunch = await _urlLauncher.canLaunchUrl('tel:+1234567890');

await canLaunch.fold(
  (failure) async => print('Check failed'),
  (can) async {
    if (can) {
      await _urlLauncher.launchPhone('+1234567890');
    } else {
      print('Phone app not available');
    }
  },
);
```

## 🎨 Advanced Configuration

### Custom Web View Configuration

```dart
final config = UrlLaunchConfig(
  mode: UrlLaunchMode.inAppBrowserView,
  enableJavaScript: true,
  enableDomStorage: true,
  headers: {
    'Authorization': 'Bearer your-token',
    'Custom-Header': 'value',
  },
  webViewConfiguration: WebViewConfiguration(
    showTitle: true,
    toolbarColor: '#FF5722',  // Material Orange
    enableZoom: false,
  ),
);

await _urlLauncher.launchWebUrl('https://example.com', config: config);
```

### Launch Modes

```dart
// Platform default (recommended for most cases)
UrlLaunchMode.platformDefault

// In-app web view
UrlLaunchMode.inAppWebView

// In-app browser (Custom Tabs on Android, Safari VC on iOS)
UrlLaunchMode.inAppBrowserView

// External application (default browser)
UrlLaunchMode.externalApplication

// External non-browser app
UrlLaunchMode.externalNonBrowserApplication
```

### Check Launch Mode Support

```dart
final isSupported = await _urlLauncher.supportsLaunchMode(
  UrlLaunchMode.inAppBrowserView,
);

isSupported.fold(
  (failure) => print('Check failed'),
  (supported) => print(supported ? 'Supported' : 'Not supported'),
);
```

### Close In-App Web View

```dart
// Close currently open in-app web view
await _urlLauncher.closeInAppWebView();
```

## 🧪 Testing

### Create Mock Service

```dart
class MockUrlLauncherService extends Mock implements UrlLauncherService {}

void main() {
  late MockUrlLauncherService mockUrlLauncher;
  late MyService myService;

  setUp(() {
    mockUrlLauncher = MockUrlLauncherService();
    myService = MyService(mockUrlLauncher);
  });

  test('should launch URL successfully', () async {
    // Arrange
    when(() => mockUrlLauncher.launchUrl(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    await myService.openWebsite();

    // Assert
    verify(() => mockUrlLauncher.launchUrl('https://example.com')).called(1);
  });

  test('should handle failure', () async {
    // Arrange
    when(() => mockUrlLauncher.launchUrl(any()))
        .thenAnswer((_) async => Left(UrlLauncherFailure('Network error')));

    // Act
    await myService.openWebsite();

    // Assert
    // Verify error handling logic
  });
}
```

### Integration Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_core/app_core.dart';

void main() {
  late UrlLauncherService urlLauncher;

  setUp(() {
    urlLauncher = UrlLauncherServiceImpl();
  });

  testWidgets('should launch URL when button tapped', (tester) async {
    // Build widget with button
    await tester.pumpWidget(MyApp());

    // Tap button
    await tester.tap(find.byKey(Key('launch_button')));
    await tester.pump();

    // Verify URL launched (may need platform channel mock)
  });
}
```

## 🐛 Troubleshooting

### Issue: "Cannot launch URL" on iOS Simulator

**Problem**: iOS Simulator doesn't have Phone or Messages app.

**Solution**: Test on real iOS device.

### Issue: "Cannot launch URL" on Android 11+

**Problem**: Missing `<queries>` configuration in AndroidManifest.xml.

**Solution**: Add `<queries>` section as shown in [Platform Configuration](#-platform-configuration).

### Issue: URL with special characters not working

**Problem**: URL not properly encoded.

**Solution**: Use `Uri` class to encode:

```dart
final uri = Uri.parse('https://example.com/search?q=hello world');
await _urlLauncher.launchUrl(uri.toString());

// Or encode manually
final encodedUrl = 'https://example.com/search?q=${Uri.encodeComponent('hello world')}';
await _urlLauncher.launchUrl(encodedUrl);
```

### Issue: Email with special characters in subject/body

**Problem**: Query parameters not properly encoded.

**Solution**: Service handles encoding automatically:

```dart
// This works correctly - encoding handled by service
await _urlLauncher.launchEmail(
  'test@example.com',
  subject: 'Hello & Welcome!',  // Special chars handled
  body: 'Testing 1+1=2',        // Special chars handled
);
```

### Issue: Web browser security blocks popup

**Problem**: Browser prevents opening URL not triggered by user action.

**Solution**: Ensure `launchUrl` is called from user interaction (button tap, etc.):

```dart
// ✅ Good - Called from button press
ElevatedButton(
  onPressed: () => _urlLauncher.launchUrl('https://example.com'),
  child: Text('Open'),
);

// ❌ Bad - Called automatically on build
@override
void initState() {
  super.initState();
  _urlLauncher.launchUrl('https://example.com');  // May be blocked
}
```

### Issue: In-app browser doesn't open

**Problem**: Launch mode not supported on platform.

**Solution**: Check support first or use platform default:

```dart
// Check if mode is supported
final isSupported = await _urlLauncher.supportsLaunchMode(
  UrlLaunchMode.inAppBrowserView,
);

await isSupported.fold(
  (failure) async {
    // Use fallback
    await _urlLauncher.launchWebUrl(
      url,
      config: UrlLaunchConfig.defaultConfig,
    );
  },
  (supported) async {
    if (supported) {
      await _urlLauncher.launchWebUrl(
        url,
        config: UrlLaunchConfig.inAppBrowser,
      );
    } else {
      // Use fallback
      await _urlLauncher.launchWebUrl(
        url,
        config: UrlLaunchConfig.externalBrowser,
      );
    }
  },
);
```

## 📚 Additional Resources

- [URL Launcher README](lib/src/infrastructure/url_launcher/doc/README.md) - Complete API documentation
- [Quick Start Guide](lib/src/infrastructure/url_launcher/doc/QUICK_START.md) - Quick reference
- [Example Code](example/url_launcher_example.dart) - Complete examples
- [url_launcher package](https://pub.dev/packages/url_launcher) - Original package documentation

## 🔄 Migration Guide

### Switching to Different Implementation

Jika ingin ganti dari `url_launcher` ke package lain (misalnya `custom_tabs`):

1. **Create new implementation**:

```dart
class CustomTabsServiceImpl implements UrlLauncherService {
  @override
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    // Implementation using custom_tabs
  }
  
  // Implement other methods...
}
```

2. **Update DI registration** (only one line changes):

```dart
// OLD
getIt.registerLazySingleton<UrlLauncherService>(
  () => UrlLauncherServiceImpl(),
);

// NEW
getIt.registerLazySingleton<UrlLauncherService>(
  () => CustomTabsServiceImpl(),
);
```

**That's it!** All your business logic and UI code remain unchanged.

## 💡 Best Practices

1. **Always handle errors**:
   ```dart
   result.fold(
     (failure) => showErrorDialog(failure.message),
     (_) => showSuccessMessage(),
   );
   ```

2. **Use appropriate launch mode**:
   - External browser: For general web links
   - In-app browser: For OAuth, short content
   - In-app web view: For full control (rare)

3. **Check capabilities when needed**:
   ```dart
   final canLaunch = await _urlLauncher.canLaunchUrl(url);
   // Show/hide buttons based on result
   ```

4. **Encode URLs properly**:
   ```dart
   final uri = Uri.parse('https://example.com/path?query=value');
   await _urlLauncher.launchUrl(uri.toString());
   ```

5. **Test on real devices**:
   - Simulators may not have all apps (phone, sms)
   - Real device behavior may differ

6. **Use dependency injection**:
   ```dart
   class MyService {
     final UrlLauncherService _urlLauncher;
     MyService(this._urlLauncher);  // Easy to test
   }
   ```

## ❓ FAQ

**Q: Can I use url_launcher directly instead of this service?**

A: You can, but using this service provides:
- Consistent error handling
- Easy to test
- Easy to switch implementations
- Type-safe APIs
- No breaking changes when package updates

**Q: Does this support deep links?**

A: Yes, you can launch any URL scheme:
```dart
await _urlLauncher.launchUrl('myapp://path/to/screen');
```

**Q: Can I launch multiple URLs at once?**

A: Not recommended. Launch one at a time:
```dart
await _urlLauncher.launchUrl(url1);
await _urlLauncher.launchUrl(url2);
```

**Q: How do I open app settings?**

A: Platform-specific URLs:
```dart
// iOS
await _urlLauncher.launchUrl('app-settings:');

// Android
await _urlLauncher.launchUrl('app-settings:');
```

**Q: Can I customize browser appearance?**

A: Yes, for in-app browsers:
```dart
config: UrlLaunchConfig(
  mode: UrlLaunchMode.inAppBrowserView,
  webViewConfiguration: WebViewConfiguration(
    toolbarColor: '#FF5722',
    enableZoom: false,
  ),
);
```

## 🤝 Contributing

Issues or improvements? Submit PR or open issue di repository.

## 📄 License

See LICENSE file in repository root.

