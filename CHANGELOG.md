## Unreleased

### Removed

- **HTTP Inspector**: `HttpInspectorService`, `ChuckerHttpInspectorServiceImpl`, its config model, widgets, and `HttpInspectorFailure` are removed from core. Inspection tooling is app-specific, so apps should wire it up directly.
  - Migration: add `ChuckerDioInterceptor()` to your Dio instance and `ChuckerFlutter.navigatorObserver` to `MaterialApp.navigatorObservers` in the app, typically behind `kDebugMode`.
- **Dependency**: `chucker_flutter` removed from `pubspec.yaml`.
- **Chart**: `ChartService`, `SyncfusionChartServiceImpl`, chart entities, and `ChartFailure` are removed. Chart widgets belong in the app that renders them.
  - Migration: depend on `syncfusion_flutter_charts` (or another chart package) in the app and build the widget there.
- **AppDynamics**: `AppDynamicsService`, its models, and `AppDynamicsFailure` are removed. The interface was specific to the AppDynamics SDK.
  - Migration: initialize `appdynamics_agent` in the app that holds the AppDynamics license.
- **WebView**: `WebViewService`, `WebViewCookieService`, their Flutter implementations, and `WebViewFailure` are removed. The service still required `webview_flutter`'s `WebViewWidget` and `WebViewController` in the app.
  - Migration: use `webview_flutter` directly, or a shared widget such as `BaseWebViewWidget` where several screens share the same loading and error behavior.
- **In-app update**: `InAppUpdateService`, `AndroidInAppUpdateServiceImpl`, and `InAppUpdateFailure` are removed. The flow is Google Play only, and the prompt policy differs per app.
  - Migration: depend on `in_app_update` in the Android app and call `InAppUpdate.checkForUpdate()` there.
- **Dependencies**: `appdynamics_agent`, `syncfusion_flutter_charts`, `in_app_update`, `webview_flutter`, `webview_flutter_android`, and `webview_flutter_wkwebview` removed from `pubspec.yaml`.

## 0.0.1

* Initial release of BUMA Core library

### Features

#### Infrastructure Layer

- **Logging Service**: Console and Logger package implementations with multiple log levels
- **Notification Service**: Firebase Cloud Messaging and local notifications support
- **Storage Service**: Hive-based local storage with performance optimizations
- **Responsive Service**: Screen size utilities using flutter_screenutil
- **Network Service**: HTTP networking with Dio implementation
  - Generic `HttpClient` interface (dependency independent)
  - `DioHttpClient` implementation
  - Type-safe requests with `Either<Failure, Success>`
  - Request/Response/Error interceptors
  - File upload/download with progress tracking
  - Comprehensive error handling with specific failure types
  - Easy to switch HTTP client implementations

#### Domain Layer

- Domain entities for notifications
- Domain entities for network (HttpResponse, RequestOptions, HttpMethod)

#### Error Handling

- Base `Failure` class
- Network-specific failures:
  - `NetworkFailure` (base)
  - `ConnectionFailure`
  - `TimeoutFailure`
  - `ServerFailure`
  - `ClientFailure`
  - `UnauthorizedFailure`
  - `ForbiddenFailure`
  - `NotFoundFailure`
  - `ParseFailure`
  - `CancelFailure`
  - `UnknownNetworkFailure`

#### Configuration

- Dependency injection setup with get_it and injectable
- Modular registration system

### Documentation

- Complete project guidelines (GUIDELINES.md)
- Architecture documentation (ARCHITECTURE.md)
- Logging setup guide (LOGGING_SETUP.md)
- Storage setup guide (STORAGE_SETUP.md)
- Network setup guide (NETWORK_SETUP.md)
- Migration guides

### Examples

- Logging examples
- Notification examples
- Storage examples with performance benchmarks
- Network examples with complete repository pattern demo

### Dependencies

- dartz: ^0.10.1 (Functional programming)
- dio: ^5.7.0 (HTTP client)
- equatable: ^2.0.7
- firebase_messaging: ^16.0.3
- flutter_local_notifications: ^17.2.3
- flutter_screenutil: ^5.9.3
- get_it: ^8.2.0
- hive: ^2.2.3
- injectable: ^2.5.1
- logger: ^2.6.2
