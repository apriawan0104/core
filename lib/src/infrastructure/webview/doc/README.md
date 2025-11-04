# WebView Infrastructure Module

Modul ini menyediakan interface generic untuk webview functionality yang **independent dari package webview tertentu**.

## 🎯 Prinsip Dependency Independence

Modul ini dirancang dengan prinsip **Dependency Independence** - artinya:

✅ **Interface TIDAK expose webview_flutter types**  
✅ **Mudah diganti ke package lain tanpa ubah business logic**  
✅ **Testable dengan mock implementations**  
✅ **Implementation details tersembunyi dari consumer**

### Current Implementation

Saat ini menggunakan **webview_flutter** v4.13.0, tapi consumer code **TIDAK tahu** dan **TIDAK peduli** package apa yang dipakai.

## 📦 Platform Support

| Platform | Minimum Version |
|----------|----------------|
| Android  | API 21+        |
| iOS      | 12.0+          |
| macOS    | 10.14+         |

## 🚀 Quick Start

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  app_core: ^x.x.x
  
  # These are already included in app_core, but listed for reference
  # webview_flutter: ^4.13.0
  # webview_flutter_android: ^3.x.x
  # webview_flutter_wkwebview: ^3.x.x
```

### 2. Platform Configuration

#### Android

**Minimum SDK 21**

`android/app/build.gradle`:
```gradle
android {
  defaultConfig {
    minSdkVersion 21
  }
}
```

#### iOS

**Minimum iOS 12.0**

`ios/Podfile`:
```ruby
platform :ios, '12.0'
```

**For HTTP URLs** (optional), add to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

#### macOS

**Minimum macOS 10.14**

Enable network access in `macos/Runner/DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 3. Register Services in DI

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Register WebView Service
  getIt.registerLazySingleton<WebViewService>(
    () => FlutterWebViewServiceImpl(),
  );
  
  // Register Cookie Service
  getIt.registerLazySingleton<WebViewCookieService>(
    () => FlutterWebViewCookieServiceImpl(),
  );
}
```

### 4. Basic Usage

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class MyWebViewPage extends StatefulWidget {
  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final WebViewService _webViewService;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  Future<void> _initializeWebView() async {
    _webViewService = getIt<WebViewService>();
    
    // Configure webview
    final config = WebViewConfig(
      javaScriptEnabled: true,
      zoomEnabled: true,
      backgroundColor: 0xFFFFFFFF,
    );
    
    // Initialize
    final result = await _webViewService.initialize(config);
    
    result.fold(
      (failure) => print('Failed: ${failure.message}'),
      (_) async {
        // Load URL after initialization
        await _webViewService.loadUrl('https://flutter.dev');
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the controller from service implementation
    final controller = (_webViewService as FlutterWebViewServiceImpl).controller;
    
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('WebView')),
      body: WebViewWidget(controller: controller),
    );
  }
}
```

## 📚 Core Features

### 1. Load Content

#### Load URL
```dart
final result = await webViewService.loadUrl(
  'https://example.com',
  headers: {'Authorization': 'Bearer token'},
);
```

#### Load Request (POST)
```dart
final request = WebViewRequest.post(
  Uri.parse('https://api.example.com/data'),
  headers: {'Content-Type': 'application/json'},
  body: utf8.encode(jsonEncode({'key': 'value'})),
);

final result = await webViewService.loadRequest(request);
```

#### Load HTML String
```dart
final html = '''
<!DOCTYPE html>
<html>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
''';

final result = await webViewService.loadHtmlString(
  html,
  baseUrl: 'https://example.com',
);
```

### 2. JavaScript Execution

#### Run JavaScript (no return value)
```dart
await webViewService.runJavaScript(
  'console.log("Hello from Dart");',
);
```

#### Run JavaScript with Result
```dart
final result = await webViewService.runJavaScriptReturningResult(
  'document.title',
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (jsResult) {
    if (jsResult.isString) {
      print('Title: ${jsResult.asString()}');
    }
  },
);
```

### 3. JavaScript Channels (Dart ↔ JS Communication)

```dart
// Add channel
final channel = WebViewJavaScriptChannel(
  name: 'FlutterChannel',
  onMessageReceived: (message) {
    print('Message from JS: $message');
  },
);

await webViewService.addJavaScriptChannel(channel);

// In JavaScript:
// FlutterChannel.postMessage('Hello from JavaScript!');
```

### 4. Navigation

```dart
// Go back
await webViewService.goBack();

// Go forward
await webViewService.goForward();

// Reload
await webViewService.reload();

// Check navigation state
final canGoBack = await webViewService.canGoBack();
final canGoForward = await webViewService.canGoForward();
```

### 5. Navigation Delegate (Handle Navigation Events)

```dart
await webViewService.setNavigationDelegate(
  onNavigationRequest: (request) {
    // Block navigation to youtube.com
    if (request.url.contains('youtube.com')) {
      return WebViewNavigationDecision.prevent;
    }
    return WebViewNavigationDecision.navigate;
  },
  onPageStarted: (url) {
    print('Page started: $url');
  },
  onPageFinished: (url) {
    print('Page finished: $url');
  },
  onProgress: (progress) {
    print('Loading: $progress%');
  },
  onWebResourceError: (error) {
    print('Error: ${error.description}');
  },
  onHttpError: (error) {
    print('HTTP Error: ${error.statusCode}');
  },
);
```

### 6. Cookie Management

```dart
final cookieService = getIt<WebViewCookieService>();

// Set cookie
final cookie = WebViewCookieData(
  name: 'session',
  value: 'abc123',
  domain: 'example.com',
  path: '/',
  isSecure: true,
  isHttpOnly: true,
);

await cookieService.setCookie(cookie);

// Remove cookie
await cookieService.removeCookie('session', 'example.com');

// Clear all cookies
await cookieService.clearAllCookies();
```

### 7. Configuration

```dart
// Set JavaScript mode
await webViewService.setJavaScriptMode(
  WebViewJavaScriptMode.unrestricted,
);

// Set user agent
await webViewService.setUserAgent('MyApp/1.0');

// Set background color
await webViewService.setBackgroundColor(0xFF000000); // Black

// Enable/disable zoom
await webViewService.enableZoom(true);
```

### 8. Scroll Control

```dart
// Get scroll position
final positionResult = await webViewService.getScrollPosition();
positionResult.fold(
  (failure) => print('Error'),
  ((x, y) position) => print('Scroll: ${position.$1}, ${position.$2}'),
);

// Scroll to position
await webViewService.scrollTo(0, 100);

// Scroll by offset
await webViewService.scrollBy(0, 50);
```

### 9. Cache Management

```dart
// Clear cache
await webViewService.clearCache();

// Clear local storage
await webViewService.clearLocalStorage();
```

## 🎨 Complete Example

See `example/webview_example.dart` for a complete, working example.

## 🔄 Dependency Migration

Jika suatu saat perlu ganti dari `webview_flutter` ke package lain (misal `flutter_inappwebview`):

### Steps:

1. **Create new implementation**
```dart
class InAppWebViewServiceImpl implements WebViewService {
  // Implement all methods using flutter_inappwebview
}
```

2. **Update DI registration**
```dart
// OLD:
// getIt.registerLazySingleton<WebViewService>(
//   () => FlutterWebViewServiceImpl(),
// );

// NEW:
getIt.registerLazySingleton<WebViewService>(
  () => InAppWebViewServiceImpl(),
);
```

3. **Update pubspec.yaml**
```yaml
# Remove:
# webview_flutter: ^4.13.0

# Add:
flutter_inappwebview: ^6.0.0
```

4. **Done!** ✅

**NO changes needed in:**
- ❌ Business logic
- ❌ UI code (yang pakai `WebViewService`)
- ❌ Tests

**Migration time: < 1 hour, not days!** 🚀

## 🧪 Testing

### Mock Implementation for Testing

```dart
class MockWebViewService extends Mock implements WebViewService {}

void main() {
  late MockWebViewService mockWebViewService;
  
  setUp(() {
    mockWebViewService = MockWebViewService();
  });
  
  test('should load URL successfully', () async {
    // Arrange
    when(() => mockWebViewService.loadUrl(any()))
      .thenAnswer((_) async => const Right(null));
    
    // Act
    final result = await mockWebViewService.loadUrl('https://example.com');
    
    // Assert
    expect(result.isRight(), true);
    verify(() => mockWebViewService.loadUrl('https://example.com')).called(1);
  });
}
```

## ⚠️ Known Limitations

### webview_flutter v4.13.0:

1. **Custom headers on POST requests** (Android): Not supported. Workaround: use `loadHtmlString` with response data.
2. **Cookie inspection**: `hasCookies()` method doesn't have platform support for checking cookies reliably.
3. **File upload**: Requires platform-specific configuration.

## 📖 API Reference

### WebViewService

Main service for webview operations.

**Key Methods:**
- `initialize(config)` - Initialize webview with configuration
- `loadUrl(url)` - Load a URL
- `loadRequest(request)` - Load a custom request
- `loadHtmlString(html)` - Load HTML string
- `runJavaScript(code)` - Execute JavaScript
- `runJavaScriptReturningResult(code)` - Execute JS and get result
- `currentUrl()` - Get current URL
- `getTitle()` - Get page title
- `goBack()` / `goForward()` / `reload()` - Navigation
- `addJavaScriptChannel(channel)` - Add JS communication channel
- `setNavigationDelegate()` - Set navigation callbacks
- `clearCache()` / `clearLocalStorage()` - Clear data
- `scrollTo()` / `scrollBy()` / `getScrollPosition()` - Scroll control

### WebViewCookieService

Service for cookie management.

**Key Methods:**
- `setCookie(cookie)` - Set a cookie
- `removeCookie(name, domain)` - Remove a cookie
- `clearAllCookies()` - Clear all cookies
- `hasCookies(url)` - Check if cookies exist

## 🔗 Related Documentation

- [QUICK_START.md](./QUICK_START.md) - Quick start guide
- [../../../../../../example/webview_example.dart](../../../../../../example/webview_example.dart) - Complete example
- [WebView Flutter Package](https://pub.dev/packages/webview_flutter) - Official documentation
- [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md) - Project architecture

## 🆘 Troubleshooting

### Issue: WebView not displaying

**Solution:** Make sure you've called `initialize()` before using other methods.

### Issue: JavaScript not working

**Solution:** Set `javaScriptEnabled: true` in `WebViewConfig`.

### Issue: HTTP URLs not loading (iOS)

**Solution:** Add NSAppTransportSecurity configuration to Info.plist.

### Issue: Network access not working (macOS)

**Solution:** Enable network client entitlement in entitlements file.

## 📄 License

This module is part of BUMA Core library.

