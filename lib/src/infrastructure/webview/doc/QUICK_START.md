# WebView Quick Start Guide

Panduan cepat untuk memulai menggunakan WebView module di BUMA Core.

## 📦 Installation

### 1. Add Dependency

Jika menggunakan BUMA Core sebagai package:

```yaml
# pubspec.yaml
dependencies:
  app_core:
    git:
      url: https://github.com/your-org/core.git
      ref: main
```

Atau jika sudah di pub.dev:

```yaml
dependencies:
  app_core: ^x.x.x
```

### 2. Platform Setup

#### Android (Minimum SDK 21)

`android/app/build.gradle`:
```gradle
android {
  defaultConfig {
    minSdkVersion 21  // Required
  }
}
```

#### iOS (Minimum iOS 12.0)

`ios/Podfile`:
```ruby
platform :ios, '12.0'
```

**Optional** - Allow HTTP URLs (if needed):

`ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

#### macOS (Minimum 10.14)

`macos/Runner/DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

Also update `macos/Runner/Release.entitlements` with the same.

## 🚀 Basic Usage (5 Minutes)

### Step 1: Setup DI

Daftarkan service di dependency injection container:

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupWebView() {
  getIt.registerLazySingleton<WebViewService>(
    () => FlutterWebViewServiceImpl(),
  );
  
  getIt.registerLazySingleton<WebViewCookieService>(
    () => FlutterWebViewCookieServiceImpl(),
  );
}
```

### Step 2: Create WebView Widget

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
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  Future<void> _initializeWebView() async {
    // Get service from DI
    _webViewService = getIt<WebViewService>();
    
    // Configure
    final config = WebViewConfig(
      javaScriptEnabled: true,
      zoomEnabled: true,
    );
    
    // Initialize
    final initResult = await _webViewService.initialize(config);
    
    await initResult.fold(
      (failure) async {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (_) async {
        // Load URL
        final loadResult = await _webViewService.loadUrl(widget.url);
        
        loadResult.fold(
          (failure) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          },
          (_) {
            setState(() {
              _isLoading = false;
            });
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
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

### Step 3: Use It!

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

## 🎯 Common Use Cases

### Use Case 1: Load with Custom Headers (e.g., Auth Token)

```dart
await webViewService.loadUrl(
  'https://api.example.com/dashboard',
  headers: {
    'Authorization': 'Bearer your_token_here',
    'Custom-Header': 'value',
  },
);
```

### Use Case 2: Execute JavaScript

```dart
// Without return value
await webViewService.runJavaScript('''
  document.getElementById('username').value = 'John Doe';
''');

// With return value
final result = await webViewService.runJavaScriptReturningResult(
  'document.title',
);

result.fold(
  (failure) => print('Error'),
  (jsResult) => print('Title: ${jsResult.asString()}'),
);
```

### Use Case 3: Communication between Dart and JavaScript

**Dart side:**
```dart
// Add channel
final channel = WebViewJavaScriptChannel(
  name: 'DartChannel',
  onMessageReceived: (message) {
    print('Message from JS: $message');
    // Handle message here
  },
);

await webViewService.addJavaScriptChannel(channel);
```

**JavaScript side:**
```javascript
// Send message to Dart
DartChannel.postMessage('Hello from JavaScript!');

// Send JSON data
DartChannel.postMessage(JSON.stringify({
  action: 'login',
  username: 'john',
}));
```

### Use Case 4: Handle Navigation Events

```dart
await webViewService.setNavigationDelegate(
  onNavigationRequest: (request) {
    // Block external links
    if (!request.url.startsWith('https://myapp.com')) {
      return WebViewNavigationDecision.prevent;
    }
    return WebViewNavigationDecision.navigate;
  },
  onPageStarted: (url) {
    print('Loading: $url');
    // Show loading indicator
  },
  onPageFinished: (url) {
    print('Loaded: $url');
    // Hide loading indicator
  },
  onProgress: (progress) {
    print('Progress: $progress%');
    // Update progress bar
  },
  onWebResourceError: (error) {
    print('Error: ${error.description}');
    // Show error message
  },
);
```

### Use Case 5: Manage Cookies

```dart
final cookieService = getIt<WebViewCookieService>();

// Set authentication cookie
final authCookie = WebViewCookieData(
  name: 'auth_token',
  value: 'abc123xyz',
  domain: 'example.com',
  path: '/',
  isSecure: true,
  isHttpOnly: true,
);

await cookieService.setCookie(authCookie);

// Later, clear cookies on logout
await cookieService.clearAllCookies();
```

### Use Case 6: Load Local HTML

```dart
final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { 
      font-family: Arial, sans-serif;
      padding: 20px;
    }
  </style>
</head>
<body>
  <h1>Welcome!</h1>
  <p>This is local HTML content.</p>
  <button onclick="DartChannel.postMessage('Button clicked!')">
    Click Me
  </button>
</body>
</html>
''';

await webViewService.loadHtmlString(html);
```

## 🎨 Advanced Example: WebView with Progress Bar

```dart
class WebViewWithProgress extends StatefulWidget {
  final String url;
  
  const WebViewWithProgress({Key? key, required this.url}) : super(key: key);
  
  @override
  State<WebViewWithProgress> createState() => _WebViewWithProgressState();
}

class _WebViewWithProgressState extends State<WebViewWithProgress> {
  late final WebViewService _webViewService;
  double _progress = 0.0;
  bool _isLoading = true;
  String? _currentUrl;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  Future<void> _initializeWebView() async {
    _webViewService = getIt<WebViewService>();
    
    final config = WebViewConfig(
      javaScriptEnabled: true,
      zoomEnabled: true,
      backgroundColor: 0xFFFFFFFF,
    );
    
    await _webViewService.initialize(config);
    
    // Setup navigation delegate
    await _webViewService.setNavigationDelegate(
      onProgress: (progress) {
        setState(() {
          _progress = progress / 100.0;
        });
      },
      onPageStarted: (url) {
        setState(() {
          _isLoading = true;
          _currentUrl = url;
        });
      },
      onPageFinished: (url) {
        setState(() {
          _isLoading = false;
          _currentUrl = url;
        });
      },
    );
    
    // Load URL
    await _webViewService.loadUrl(widget.url);
    
    setState(() {});
  }
  
  Future<void> _goBack() async {
    final canGoBack = await _webViewService.canGoBack();
    canGoBack.fold(
      (failure) => null,
      (can) async {
        if (can) await _webViewService.goBack();
      },
    );
  }
  
  Future<void> _goForward() async {
    final canGoForward = await _webViewService.canGoForward();
    canGoForward.fold(
      (failure) => null,
      (can) async {
        if (can) await _webViewService.goForward();
      },
    );
  }
  
  Future<void> _reload() async {
    await _webViewService.reload();
  }
  
  @override
  Widget build(BuildContext context) {
    final controller = (_webViewService as FlutterWebViewServiceImpl).controller;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUrl ?? 'WebView'),
        bottom: _isLoading
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(value: _progress),
            )
          : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goForward,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: controller != null
        ? WebViewWidget(controller: controller)
        : const Center(child: CircularProgressIndicator()),
    );
  }
}
```

## ✅ Best Practices

1. **Always initialize before use**
   ```dart
   await webViewService.initialize(config);
   ```

2. **Handle errors properly**
   ```dart
   result.fold(
     (failure) => handleError(failure),
     (success) => handleSuccess(success),
   );
   ```

3. **Use DI for testability**
   ```dart
   final service = getIt<WebViewService>();
   ```

4. **Clean up resources**
   ```dart
   @override
   void dispose() {
     // WebView cleanup is handled automatically
     super.dispose();
   }
   ```

5. **Test with mock implementations**
   ```dart
   class MockWebViewService extends Mock implements WebViewService {}
   ```

## 🐛 Common Issues

### Issue: "WebView has not been initialized"

**Cause:** Trying to use WebView before calling `initialize()`.

**Solution:**
```dart
await webViewService.initialize(config);
// Now you can use other methods
```

### Issue: JavaScript not working

**Cause:** JavaScript is disabled by default.

**Solution:**
```dart
final config = WebViewConfig(
  javaScriptEnabled: true,  // Enable this
);
```

### Issue: HTTP URLs not loading on iOS

**Cause:** iOS blocks HTTP by default (App Transport Security).

**Solution:** Add NSAppTransportSecurity to Info.plist (see Platform Setup above).

## 📚 Next Steps

- Read [README.md](./README.md) for complete documentation
- Check [example/webview_example.dart](../../../../../../example/webview_example.dart) for full example
- Explore the API reference in the README

## 🆘 Need Help?

- Check [README.md](./README.md) for detailed documentation
- See [Troubleshooting section](./README.md#-troubleshooting) in README
- Review [webview_flutter documentation](https://pub.dev/packages/webview_flutter)

Happy coding! 🚀

