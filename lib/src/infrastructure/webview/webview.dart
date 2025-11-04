/// WebView Infrastructure Module
///
/// This module provides a generic interface for webview functionality
/// that is independent of any specific webview implementation.
///
/// The implementation uses webview_flutter package but exposes a clean,
/// testable interface that can be easily swapped for other implementations.
///
/// ## Features
///
/// - **Generic Interface**: Not tied to any specific webview package
/// - **Easy to Test**: Mock-friendly design with dependency injection
/// - **Platform Support**: Android (API 21+), iOS (12.0+), macOS (10.14+)
/// - **Comprehensive**: URL loading, HTML loading, JavaScript execution, navigation, cookies, etc.
/// - **Type-Safe**: Strong typing with Either for error handling
/// - **Configurable**: Flexible configuration options
///
/// ## Usage
///
/// ```dart
/// // 1. Configure webview
/// final config = WebViewConfig(
///   javaScriptEnabled: true,
///   zoomEnabled: true,
///   userAgent: 'MyApp/1.0',
/// );
///
/// // 2. Initialize service
/// final webViewService = getIt<WebViewService>();
/// await webViewService.initialize(config);
///
/// // 3. Load URL
/// await webViewService.loadUrl('https://example.com');
///
/// // 4. Execute JavaScript
/// final result = await webViewService.runJavaScriptReturningResult(
///   'document.title',
/// );
/// ```
///
/// ## Dependency Injection Setup
///
/// ```dart
/// // Register in your DI container
/// getIt.registerLazySingleton<WebViewService>(
///   () => FlutterWebViewServiceImpl(),
/// );
///
/// getIt.registerLazySingleton<WebViewCookieService>(
///   () => FlutterWebViewCookieServiceImpl(),
/// );
/// ```
///
/// ## Platform Setup
///
/// ### Android
///
/// Minimum SDK: 21
///
/// In `android/app/build.gradle`:
/// ```gradle
/// android {
///   defaultConfig {
///     minSdkVersion 21
///   }
/// }
/// ```
///
/// ### iOS
///
/// Minimum iOS: 12.0
///
/// In `ios/Podfile`:
/// ```ruby
/// platform :ios, '12.0'
/// ```
///
/// Add to `ios/Runner/Info.plist` if loading HTTP URLs:
/// ```xml
/// <key>NSAppTransportSecurity</key>
/// <dict>
///   <key>NSAllowsArbitraryLoads</key>
///   <true/>
/// </dict>
/// ```
///
/// ### macOS
///
/// Minimum macOS: 10.14
///
/// Enable network access in `macos/Runner/DebugProfile.entitlements`:
/// ```xml
/// <key>com.apple.security.network.client</key>
/// <true/>
/// ```
///
/// ## Migration Guide
///
/// If you need to switch to a different webview package:
///
/// 1. Create new implementation class (e.g., `InAppWebViewServiceImpl`)
/// 2. Implement the `WebViewService` interface
/// 3. Update DI registration
/// 4. Update pubspec.yaml dependencies
///
/// **No changes needed in business logic or UI code!**
///
/// See [ARCHITECTURE.md] for more details on dependency independence.
library;

// Export contracts (interfaces)
export 'contract/contracts.dart';

// Export models
export 'models/models.dart';

// Export constants
export 'constants/constants.dart';

// Export implementations
export 'impl/impl.dart';

