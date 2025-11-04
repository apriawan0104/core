# URL Launcher Service

Generic, dependency-independent URL launcher service untuk BUMA Core. Service ini memungkinkan launching URLs, emails, phone calls, SMS, dan more tanpa terikat ke package tertentu.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Usage](#-usage)
- [API Reference](#-api-reference)
- [Platform Configuration](#-platform-configuration)
- [Launch Modes](#-launch-modes)
- [Error Handling](#-error-handling)
- [Testing](#-testing)
- [Migration](#-migration)
- [Examples](#-examples)

## ✨ Features

- ✅ **Dependency Independent** - Easy to switch implementations
- ✅ **Launch Web URLs** - Open URLs in browser or in-app
- ✅ **Email Support** - Compose emails with subject, body, cc, bcc
- ✅ **Phone Calls** - Launch phone dialer
- ✅ **SMS Messages** - Send SMS with pre-filled message
- ✅ **Multiple Launch Modes** - External, in-app, custom tabs
- ✅ **Error Handling** - Proper Either monad error handling
- ✅ **Cross-Platform** - Works on iOS, Android, Web, Desktop
- ✅ **Type Safe** - No third-party types exposed
- ✅ **Testable** - Easy to mock for unit tests

## 🏗️ Architecture

Service ini mengikuti **Dependency Independence** principle:

```
┌─────────────────────────────────────┐
│   Consumer App (Your Flutter App)  │
│   - Business Logic                 │
│   - UI Components                  │
└─────────────┬───────────────────────┘
              │ depends on
              ▼
┌─────────────────────────────────────┐
│   UrlLauncherService (Interface)   │  ← Stable contract
│   - launchUrl()                     │
│   - launchEmail()                   │
│   - launchPhone()                   │
└─────────────┬───────────────────────┘
              │ implemented by
              ▼
┌─────────────────────────────────────┐
│  UrlLauncherServiceImpl             │
│  (wraps url_launcher package)       │
└─────────────────────────────────────┘

Alternative implementations:
- CustomTabsServiceImpl
- WebViewServiceImpl
- MockUrlLauncherService (for tests)
```

**Key Benefits:**
- Interface tidak berubah meskipun ganti package
- Consumer code tidak perlu diubah saat migration
- Multiple implementations bisa coexist
- Easy to test dengan mocks

## 📦 Installation

### 1. Add to pubspec.yaml

```yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # Implementation dependency
  url_launcher: ^6.3.2
```

### 2. Register in DI Container

```dart
// lib/core/di/locator.dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register URL launcher service
  getIt.registerLazySingleton<UrlLauncherService>(
    () => UrlLauncherServiceImpl(),
  );
}
```

### 3. Platform Configuration

See [Platform Configuration](#-platform-configuration) section below.

## 🚀 Usage

### Basic URL Launch

```dart
import 'package:app_core/app_core.dart';

class MyService {
  final UrlLauncherService _urlLauncher;

  MyService(this._urlLauncher);

  Future<void> openWebsite() async {
    final result = await _urlLauncher.launchWebUrl(
      'https://flutter.dev',
      config: UrlLaunchConfig.externalBrowser,
    );

    result.fold(
      (failure) => print('Failed: ${failure.message}'),
      (success) => print('Opened successfully'),
    );
  }
}
```

### Email with Details

```dart
Future<void> contactSupport() async {
  final result = await _urlLauncher.launchEmail(
    'support@example.com',
    subject: 'Help Request',
    body: 'I need help with...',
    cc: ['manager@example.com'],
  );

  result.fold(
    (failure) => _showError(failure),
    (_) => _showSuccess(),
  );
}
```

### Phone Call

```dart
Future<void> callCustomerService() async {
  final result = await _urlLauncher.launchPhone('+1-800-EXAMPLE');
  
  result.fold(
    (failure) => print('Cannot make call'),
    (_) => print('Opening dialer'),
  );
}
```

### SMS

```dart
Future<void> sendFeedbackSms() async {
  final result = await _urlLauncher.launchSms(
    '+1234567890',
    message: 'Thank you for your service!',
  );

  result.fold(
    (failure) => print('Cannot send SMS'),
    (_) => print('Opening SMS app'),
  );
}
```

### Check Before Launch

```dart
Future<void> launchIfPossible(String url) async {
  // Check if URL can be launched
  final canLaunchResult = await _urlLauncher.canLaunchUrl(url);
  
  await canLaunchResult.fold(
    (failure) async => print('Check failed: ${failure.message}'),
    (canLaunch) async {
      if (canLaunch) {
        await _urlLauncher.launchUrl(url);
      } else {
        print('Cannot launch URL');
      }
    },
  );
}
```

## 📚 API Reference

### Core Methods

#### `launchUrl(String url, {UrlLaunchConfig config})`

Launch any URL with custom configuration.

```dart
Future<Either<UrlLauncherFailure, bool>> launchUrl(
  String url, {
  UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
});
```

#### `launchWebUrl(String url, {UrlLaunchConfig config})`

Launch web URL (http/https).

```dart
Future<Either<UrlLauncherFailure, bool>> launchWebUrl(
  String url, {
  UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
});
```

#### `launchEmail(String email, {...})`

Launch email app with pre-filled data.

```dart
Future<Either<UrlLauncherFailure, bool>> launchEmail(
  String email, {
  String? subject,
  String? body,
  List<String>? cc,
  List<String>? bcc,
});
```

#### `launchPhone(String phoneNumber)`

Launch phone dialer.

```dart
Future<Either<UrlLauncherFailure, bool>> launchPhone(String phoneNumber);
```

#### `launchSms(String phoneNumber, {String? message})`

Launch SMS app with pre-filled message.

```dart
Future<Either<UrlLauncherFailure, bool>> launchSms(
  String phoneNumber, {
  String? message,
});
```

### Utility Methods

#### `canLaunchUrl(String url)`

Check if URL can be launched.

```dart
Future<Either<UrlLauncherFailure, bool>> canLaunchUrl(String url);
```

#### `supportsLaunchMode(UrlLaunchMode mode)`

Check if launch mode is supported.

```dart
Future<Either<UrlLauncherFailure, bool>> supportsLaunchMode(
  UrlLaunchMode mode,
);
```

#### `closeInAppWebView()`

Close in-app web view if open.

```dart
Future<Either<UrlLauncherFailure, void>> closeInAppWebView();
```

## ⚙️ Platform Configuration

### iOS Configuration

Add to `ios/Runner/Info.plist`:

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

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <!-- Add inside <manifest>, outside <application> -->
  <queries>
    <!-- HTTP/HTTPS -->
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
    
    <!-- Custom Tabs support -->
    <intent>
      <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
  </queries>
</manifest>
```

**Note**: Android 11 (API 30)+ requires `<queries>` configuration!

## 🎨 Launch Modes

### Available Modes

```dart
enum UrlLaunchMode {
  platformDefault,              // iOS: SFSafariViewController, Android: Custom Tabs
  inAppWebView,                 // In-app web view
  inAppBrowserView,             // Custom Tabs/Safari View Controller
  externalApplication,          // Default external browser
  externalNonBrowserApplication // External non-browser app
}
```

### Usage Examples

```dart
// Platform default (recommended)
await _urlLauncher.launchWebUrl(
  url,
  config: UrlLaunchConfig(mode: UrlLaunchMode.platformDefault),
);

// External browser
await _urlLauncher.launchWebUrl(
  url,
  config: UrlLaunchConfig(mode: UrlLaunchMode.externalApplication),
);

// In-app browser (Custom Tabs/Safari VC)
await _urlLauncher.launchWebUrl(
  url,
  config: UrlLaunchConfig(mode: UrlLaunchMode.inAppBrowserView),
);

// In-app web view
await _urlLauncher.launchWebUrl(
  url,
  config: UrlLaunchConfig(mode: UrlLaunchMode.inAppWebView),
);
```

### Custom Configuration

```dart
final config = UrlLaunchConfig(
  mode: UrlLaunchMode.inAppBrowserView,
  enableJavaScript: true,
  enableDomStorage: true,
  headers: {'Authorization': 'Bearer token'},
  webViewConfiguration: WebViewConfiguration(
    showTitle: true,
    toolbarColor: '#FF5722',
    enableZoom: false,
  ),
);

await _urlLauncher.launchWebUrl(url, config: config);
```

## ❌ Error Handling

### Failure Types

```dart
// Cannot launch URL
UrlLauncherFailure.cannotLaunch(url);

// Invalid URL format
UrlLauncherFailure.invalidUrl(url);

// Launch mode not supported
UrlLauncherFailure.launchModeNotSupported(mode);

// URL scheme not supported
UrlLauncherFailure.schemeNotSupported(scheme);

// Platform error
UrlLauncherFailure.platformError(message);

// Unknown error
UrlLauncherFailure.unknown(message);
```

### Handling Errors

```dart
final result = await _urlLauncher.launchUrl(url);

result.fold(
  (failure) {
    // Handle failure
    if (failure.message.contains('Cannot launch')) {
      showSnackbar('No app can open this URL');
    } else if (failure.message.contains('Invalid')) {
      showSnackbar('Invalid URL format');
    } else {
      showSnackbar('Error: ${failure.message}');
    }
  },
  (success) {
    // Handle success
    print('URL launched successfully');
  },
);
```

## 🧪 Testing

### Create Mock Implementation

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
    verify(() => mockUrlLauncher.launchUrl(any())).called(1);
  });

  test('should handle launch failure', () async {
    // Arrange
    when(() => mockUrlLauncher.launchUrl(any()))
        .thenAnswer((_) async => Left(UrlLauncherFailure('Error')));

    // Act
    await myService.openWebsite();

    // Assert
    // Verify error handling
  });
}
```

## 🔄 Migration

### Switching to Different Package

Want to switch from `url_launcher` to `custom_tabs`? Easy!

**Step 1**: Create new implementation

```dart
class CustomTabsServiceImpl implements UrlLauncherService {
  @override
  Future<Either<UrlLauncherFailure, bool>> launchUrl(
    String url, {
    UrlLaunchConfig config = UrlLaunchConfig.defaultConfig,
  }) async {
    // Implementation using custom_tabs package
  }
  
  // Implement other methods...
}
```

**Step 2**: Update DI registration (ONE LINE!)

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

**That's it!** No other code changes needed.

## 📱 Examples

Check the `/example` directory for complete examples:

- Basic URL launching
- Email composition
- Phone calls and SMS
- Different launch modes
- Error handling
- Testing examples

## 🐛 Troubleshooting

### iOS Simulator: Cannot launch tel: or sms:

**Cause**: iOS Simulator doesn't have Phone or Messages app.  
**Solution**: Test on real device.

### Android: Cannot launch URL (API 30+)

**Cause**: Missing `<queries>` in AndroidManifest.xml.  
**Solution**: Add queries configuration (see Platform Configuration).

### URL with special characters fails

**Cause**: URL not properly encoded.  
**Solution**: Use `Uri.parse()` or manual encoding:

```dart
final uri = Uri.parse('https://example.com/search?q=hello world');
await _urlLauncher.launchUrl(uri.toString());
```

### Web: Launch must be triggered by user action

**Cause**: Browser security restrictions.  
**Solution**: Ensure launch is called from user interaction (button tap, etc.).

## 📖 Additional Resources

- [Quick Start Guide](QUICK_START.md)
- [Architecture Documentation](/ARCHITECTURE.md)
- [url_launcher package](https://pub.dev/packages/url_launcher)
- [Migration Guide](/MIGRATION_GUIDE.md)

## 🤝 Contributing

When adding features:
1. ✅ Never expose third-party types in interface
2. ✅ Use Either for error handling
3. ✅ Make features optional and backward compatible
4. ✅ Update documentation
5. ✅ Add tests
6. ✅ Follow existing patterns

## 📄 License

See LICENSE file in repository root.

