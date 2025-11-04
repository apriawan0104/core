# WebView Setup Guide

Panduan lengkap untuk setup dan menggunakan WebView module di BUMA Core.

## 📦 Installation

### 1. Add Dependencies to Your App

```yaml
# pubspec.yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
  
  # WebView dependencies (already included in app_core, but listed for reference)
  webview_flutter: ^4.13.0
  webview_flutter_android: ^3.16.0
  webview_flutter_wkwebview: ^3.13.0
```

### 2. Platform Configuration

#### Android Setup

**Minimum SDK: 21**

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Required for WebView
        targetSdkVersion 34
    }
}
```

**Optional - Internet Permission** (usually already added):

`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

#### iOS Setup

**Minimum iOS: 12.0**

Update `ios/Podfile`:

```ruby
platform :ios, '12.0'

# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
# use_frameworks!

target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

**For HTTP URLs** (optional, if you need to load non-HTTPS URLs):

Update `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add this if you need to allow HTTP URLs -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
        <!-- Or more secure, whitelist specific domains -->
        <!-- <key>NSExceptionDomains</key>
        <dict>
            <key>example.com</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
            </dict>
        </dict> -->
    </dict>
    
    <!-- Other keys... -->
</dict>
```

**For Camera/Microphone Access** (optional, if your WebView content needs these):

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to use web features</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to use web features</string>
```

#### macOS Setup

**Minimum macOS: 10.14**

Update `macos/Runner/DebugProfile.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Network access -->
    <key>com.apple.security.network.client</key>
    <true/>
    
    <!-- Optional: If you need to load local files -->
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
```

Also update `macos/Runner/Release.entitlements` with the same settings.

### 3. Register Services in DI Container

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  // Register WebView Service
  getIt.registerLazySingleton<WebViewService>(
    () => FlutterWebViewServiceImpl(),
  );
  
  // Register WebView Cookie Service
  getIt.registerLazySingleton<WebViewCookieService>(
    () => FlutterWebViewCookieServiceImpl(),
  );
}
```

### 4. Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  setupServices();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomePage(),
    );
  }
}
```

## 🚀 Basic Usage

### Simple WebView Page

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebViewPage extends StatefulWidget {
  final String url;
  
  const SimpleWebViewPage({
    Key? key,
    required this.url,
  }) : super(key: key);
  
  @override
  State<SimpleWebViewPage> createState() => _SimpleWebViewPageState();
}

class _SimpleWebViewPageState extends State<SimpleWebViewPage> {
  late final WebViewService _webViewService;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  Future<void> _initializeWebView() async {
    _webViewService = getIt<WebViewService>();
    
    // Configure
    final config = WebViewConfig(
      javaScriptEnabled: true,
      zoomEnabled: true,
      backgroundColor: 0xFFFFFFFF,
    );
    
    // Initialize
    await _webViewService.initialize(config);
    
    // Load URL
    await _webViewService.loadUrl(widget.url);
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Get controller from implementation
    final controller = (_webViewService as FlutterWebViewServiceImpl).controller;
    
    return Scaffold(
      appBar: AppBar(title: const Text('WebView')),
      body: controller != null 
        ? WebViewWidget(controller: controller)
        : const Center(child: Text('WebView not available')),
    );
  }
}
```

### Usage

```dart
// Navigate to WebView page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SimpleWebViewPage(
      url: 'https://flutter.dev',
    ),
  ),
);
```

## 📚 Features

### Load Content
- Load URLs with custom headers
- Load POST requests
- Load HTML strings

### JavaScript
- Execute JavaScript code
- Get return values from JavaScript
- JavaScript channels (Dart ↔ JS communication)

### Navigation
- Back/Forward navigation
- Reload
- Navigation events (onPageStarted, onPageFinished, etc.)
- Progress tracking
- Block/allow navigation

### Cookies
- Set cookies
- Remove cookies
- Clear all cookies

### Configuration
- Enable/disable JavaScript
- Zoom controls
- User agent
- Background color
- Platform-specific settings

### Scroll
- Get scroll position
- Scroll to position
- Scroll by offset

## 📖 Documentation

- **[Quick Start Guide](./lib/src/infrastructure/webview/doc/QUICK_START.md)** - Get started in 5 minutes
- **[Complete Documentation](./lib/src/infrastructure/webview/doc/README.md)** - Full API reference
- **[Example Code](./example/webview_example.dart)** - Complete working example

## 🔄 Dependency Independence

WebView module dirancang dengan prinsip **Dependency Independence**:

✅ Interface tidak expose `webview_flutter` types  
✅ Mudah diganti ke package lain (misal `flutter_inappwebview`)  
✅ Testable dengan mock implementations  
✅ Business logic tidak perlu diubah saat ganti dependency

### Ganti Dependency (< 1 Jam)

Jika perlu ganti dari `webview_flutter` ke package lain:

1. Create new implementation:
```dart
class InAppWebViewServiceImpl implements WebViewService {
  // Implement with flutter_inappwebview
}
```

2. Update DI registration:
```dart
getIt.registerLazySingleton<WebViewService>(
  () => InAppWebViewServiceImpl(), // Changed!
);
```

3. Update `pubspec.yaml`
4. **Done!** ✅

## ⚠️ Troubleshooting

### Issue: WebView not displaying

**Cause:** Missing initialization

**Solution:**
```dart
await webViewService.initialize(config);
```

### Issue: JavaScript not working

**Cause:** JavaScript disabled

**Solution:**
```dart
final config = WebViewConfig(
  javaScriptEnabled: true, // Enable this
);
```

### Issue: HTTP URLs not loading (iOS)

**Cause:** App Transport Security blocks HTTP

**Solution:** Add NSAppTransportSecurity to Info.plist (see iOS Setup above)

### Issue: Compilation error on Android

**Cause:** minSdkVersion < 21

**Solution:** Set `minSdkVersion 21` in build.gradle

### Issue: WebView crashes on macOS

**Cause:** Missing network entitlements

**Solution:** Enable network client in entitlements (see macOS Setup above)

## 🆘 Support

- Check [Quick Start](./lib/src/infrastructure/webview/doc/QUICK_START.md)
- Read [Full Documentation](./lib/src/infrastructure/webview/doc/README.md)
- See [Example](./example/webview_example.dart)
- Review [webview_flutter docs](https://pub.dev/packages/webview_flutter)

## ✅ Platform Support Matrix

| Feature | Android | iOS | macOS | Web |
|---------|---------|-----|-------|-----|
| Load URL | ✅ | ✅ | ✅ | ❌ |
| JavaScript | ✅ | ✅ | ✅ | ❌ |
| JS Channels | ✅ | ✅ | ✅ | ❌ |
| Cookies | ✅ | ✅ | ✅ | ❌ |
| Navigation | ✅ | ✅ | ✅ | ❌ |
| Scroll Control | ✅ | ✅ | ✅ | ❌ |

Note: Web platform not supported by webview_flutter.

## 🎯 Next Steps

1. Follow [Quick Start Guide](./lib/src/infrastructure/webview/doc/QUICK_START.md)
2. Check [Complete Example](./example/webview_example.dart)
3. Read [API Documentation](./lib/src/infrastructure/webview/doc/README.md)
4. Build your feature! 🚀

Happy coding! 🎉

