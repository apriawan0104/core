# AppDynamics Infrastructure

Dependency-independent AppDynamics Mobile Real User Monitoring (RUM) service for BUMA Core.

## 🎯 Overview

The AppDynamics infrastructure provides a standardized way to integrate AppDynamics Mobile Real User Monitoring with your Flutter applications. The design follows the **Dependency Inversion Principle (DIP)**, allowing you to easily switch between AppDynamics SDK versions or implementations without changing your business logic.

## 🏗️ Architecture

```
appdynamics/
├── contract/           # Abstract interfaces (stable, never changes)
│   └── appdynamics.service.dart
├── impl/              # Concrete implementations (can be added/removed)
│   └── appdynamics_agent.service.impl.dart  # Using appdynamics_agent package
├── models/            # Data models
│   ├── appdynamics_config.model.dart
│   ├── appdynamics_session_frame.model.dart
│   ├── appdynamics_breadcrumb.model.dart
│   └── appdynamics_timer.model.dart
├── constants/         # Configuration constants
│   └── appdynamics.constant.dart
└── doc/
    ├── README.md      # This file
    └── QUICK_START.md # Quick start guide
```

### Dependency Flow

```
Your App (Business Logic)
      ↓ depends on
  AppDynamicsService (Interface) ← STABLE, never changes
      ↑ implemented by
Implementation (appdynamics_agent package)
```

## 🚀 Quick Start

See [QUICK_START.md](QUICK_START.md) for detailed setup instructions.

### Basic Usage

```dart
import 'package:app_core/app_core.dart';

// Initialize AppDynamics
final appDynamics = AppDynamicsAgentServiceImpl();
final config = AppDynamicsConfig(
  appKey: 'YOUR_EUM_APP_KEY',
  loggingLevel: AppDynamicsLoggingLevel.verbose,
);

await appDynamics.initialize(config);

// Track errors
await appDynamics.reportError('Something went wrong');

// Track custom metrics
await appDynamics.reportMetric('checkout_duration', 1250.5);
```

## 📋 Features

### ✅ Automatic Features

- **Network Request Tracking** - Automatically tracks HTTP requests via TrackedHTTPClient
- **Crash Reporting** - Automatically captures and reports crashes
- **Screen Tracking** - Automatically tracks screen views (via NavigationObserver/WidgetTracker)
- **ANR Detection** - Automatically detects App Not Responding cases (Android only)
- **Device Metrics** - Automatically reports device metrics (memory, storage, battery)

### ✅ Manual Features

- **Session Frames** - Track custom user flows (checkout, onboarding, etc.)
- **Breadcrumbs** - Track user interactions and UI events
- **Timers** - Track performance of operations spanning multiple methods
- **Custom Metrics** - Report business metrics and KPIs
- **Error Reporting** - Manually report errors and exceptions
- **Custom User Data** - Associate custom data with sessions
- **Info Points** - Mark important methods for monitoring

## 🔧 Configuration

### Configuration Models

#### AppDynamicsConfig

Main configuration model for AppDynamics initialization:

```dart
final config = AppDynamicsConfig(
  appKey: 'YOUR_EUM_APP_KEY', // Required
  loggingLevel: AppDynamicsLoggingLevel.verbose, // Optional
  collectorURL: 'https://your-collector-url.com', // Optional, for on-premises
  screenshotURL: 'https://your-screenshot-url.com', // Optional, for on-premises
  enableNetworkRequestTracking: true, // Optional, default: true
  enableCrashReporting: true, // Optional, default: true
  enableScreenTracking: true, // Optional, default: true
  enableAnrDetection: true, // Optional, default: true (Android only)
  enableScreenshotCapture: false, // Optional, default: false (iOS only)
  enableTouchPointCapture: false, // Optional, default: false (iOS only)
  enableDeviceMetrics: true, // Optional, default: true
);
```

#### Predefined Configurations

**Production Configuration:**
```dart
final config = AppDynamicsConfig.production(
  appKey: 'YOUR_EUM_APP_KEY',
  collectorURL: 'https://your-collector-url.com', // Optional
);
```

**Development Configuration:**
```dart
final config = AppDynamicsConfig.development(
  appKey: 'YOUR_EUM_APP_KEY',
  collectorURL: 'https://your-collector-url.com', // Optional
);
```

**Minimal Configuration:**
```dart
final config = AppDynamicsConfig.minimal(
  appKey: 'YOUR_EUM_APP_KEY',
);
```

## 📖 Usage Examples

### Error Reporting

```dart
try {
  // Your code
} catch (e, stackTrace) {
  await appDynamics.reportError(
    'Failed to process payment',
    stackTrace: stackTrace,
    severity: 'error',
    properties: {
      'order_id': '12345',
      'payment_method': 'credit_card',
    },
  );
}
```

### Custom Metrics

```dart
// Track business metrics
await appDynamics.reportMetric(
  'checkout_duration',
  1250.5,
  unit: 'ms',
  properties: {
    'payment_method': 'credit_card',
    'items_count': 3,
  },
);

// Track conversion rates
await appDynamics.reportMetric(
  'conversion_rate',
  0.75,
  unit: 'percentage',
);
```

### Session Frames

Session frames allow you to track multi-step user flows:

```dart
// Start tracking checkout process
final frame = await appDynamics.startSessionFrame(
  'checkout_process',
  properties: {'user_id': '123'},
);

try {
  // Step 1: Add items to cart
  await addToCart();
  await appDynamics.updateSessionFrame(frame, {
    'step': 'cart',
    'items_count': 3,
  });

  // Step 2: Select payment method
  await selectPaymentMethod();
  await appDynamics.updateSessionFrame(frame, {
    'step': 'payment',
    'payment_method': 'credit_card',
  });

  // Step 3: Complete purchase
  await completePurchase();
  await appDynamics.updateSessionFrame(frame, {
    'step': 'complete',
    'total_amount': 99.99,
  });
} catch (e) {
  await appDynamics.updateSessionFrame(frame, {
    'step': 'error',
    'error_message': e.toString(),
  });
  rethrow;
} finally {
  // Always end the frame
  await appDynamics.endSessionFrame(frame);
}
```

### Breadcrumbs

Track user interactions and UI events:

```dart
// Track button clicks
await appDynamics.leaveBreadcrumb(
  AppDynamicsBreadcrumb(
    message: 'User clicked submit button',
    level: AppDynamicsBreadcrumbLevel.info,
    category: 'user_action',
    properties: {
      'button_id': 'submit',
      'screen': 'checkout',
    },
  ),
);

// Track navigation events
await appDynamics.leaveBreadcrumb(
  AppDynamicsBreadcrumb(
    message: 'Navigated to profile screen',
    level: AppDynamicsBreadcrumbLevel.info,
    category: 'navigation',
  ),
);

// Track errors
await appDynamics.leaveBreadcrumb(
  AppDynamicsBreadcrumb(
    message: 'API request failed',
    level: AppDynamicsBreadcrumbLevel.error,
    category: 'api_error',
    properties: {'endpoint': '/api/users'},
  ),
);
```

### Timers

Track performance of operations spanning multiple methods:

```dart
// Start timer
final timer = await appDynamics.startTimer(
  'data_processing',
  properties: {'data_size': '1000'},
);

try {
  // Perform async operations
  await fetchData();
  await processData();
  await saveData();
} finally {
  // Stop timer
  await appDynamics.stopTimer(timer);
}
```

### Custom User Data

Associate custom data with the current user session:

```dart
// Set user data
await appDynamics.setUserData('user_id', '12345');
await appDynamics.setUserData('email', 'user@example.com');
await appDynamics.setUserData('plan', 'premium');

// Remove user data
await appDynamics.removeUserData('plan');

// Clear all user data (e.g., on logout)
await appDynamics.clearUserData();
```

### Network Request Data

Add custom data to network requests:

```dart
// Set data that will be included with all network requests
await appDynamics.setNetworkRequestData('api_version', 'v2');
await appDynamics.setNetworkRequestData('client_id', 'mobile_app');

// Remove network request data
await appDynamics.removeNetworkRequestData('api_version');

// Clear all network request data
await appDynamics.clearNetworkRequestData();
```

### Crash Report Data

Add custom data to crash reports:

```dart
// Set data that will be included with crash reports
await appDynamics.setCrashReportData('user_id', '12345');
await appDynamics.setCrashReportData('app_version', '1.2.3');

// Remove crash report data
await appDynamics.removeCrashReportData('user_id');

// Clear all crash report data
await appDynamics.clearCrashReportData();
```

### Info Points

Mark important methods for monitoring:

```dart
await appDynamics.markInfoPoint(
  'processPayment',
  properties: {
    'payment_method': 'credit_card',
    'amount': 99.99,
  },
);
```

### Session Splitting

Split app instrumentation into multiple sessions:

```dart
// Split session (useful for multi-step processes)
await appDynamics.splitSession();
```

## 🔄 Dependency Independence

### Why Dependency Independence Matters

The AppDynamics infrastructure is designed to be **dependency-independent**, meaning:

- ✅ **No third-party types in public API** - All interfaces use our own types
- ✅ **Easy to switch implementations** - Change providers with one line of code
- ✅ **Testable** - Easy to create mock implementations for testing
- ✅ **Future-proof** - Can add new implementations without changing existing code

### Switching Implementations

To switch from AppDynamics Agent to another implementation:

1. Create new implementation class:
```dart
class NewAppDynamicsServiceImpl implements AppDynamicsService {
  // New implementation
}
```

2. Update DI registration:
```dart
// Old:
// getIt.registerLazySingleton<AppDynamicsService>(
//   () => AppDynamicsAgentServiceImpl(),
// );

// New:
getIt.registerLazySingleton<AppDynamicsService>(
  () => NewAppDynamicsServiceImpl(),
);
```

3. No changes needed in business logic!

## 🧪 Testing

### Mock Implementation

Create a mock implementation for testing:

```dart
class MockAppDynamicsService implements AppDynamicsService {
  bool _isInitialized = false;
  final List<String> _reportedErrors = [];
  final List<AppDynamicsSessionFrame> _activeFrames = [];

  @override
  Future<Either<Failure, void>> initialize(AppDynamicsConfig config) async {
    _isInitialized = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> reportError(
    String message, {
    StackTrace? stackTrace,
    String? severity,
    Map<String, dynamic>? properties,
  }) async {
    _reportedErrors.add(message);
    return const Right(null);
  }

  // ... implement other methods
}
```

### Usage in Tests

```dart
void main() {
  late MockAppDynamicsService mockAppDynamics;

  setUp(() {
    mockAppDynamics = MockAppDynamicsService();
  });

  test('should report error when operation fails', () async {
    final result = await mockAppDynamics.reportError('Test error');
    expect(result.isRight(), true);
    expect(mockAppDynamics._reportedErrors, contains('Test error'));
  });
}
```

## 📚 API Reference

See the [AppDynamicsService](contract/appdynamics.service.dart) interface for complete API documentation.

## 🔗 Related Documentation

- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [AppDynamics Official Docs](https://docs.appdynamics.com/)
- [AppDynamics Flutter Plugin](https://pub.dev/packages/appdynamics_agent)

## ⚠️ Important Notes

1. **Initialization**: Always call `initialize()` before using any other methods
2. **Error Handling**: All methods return `Either<Failure, T>` - always handle failures
3. **Session Frames**: Always end session frames in `finally` blocks to ensure cleanup
4. **Timers**: Always stop timers in `finally` blocks to ensure cleanup
5. **Thread Safety**: AppDynamics SDK handles thread safety internally

## 🐛 Troubleshooting

### Common Issues

1. **AppDynamics Not Initializing**
   - Check that `appKey` is correct
   - Verify Android permissions are added
   - Ensure `WidgetsFlutterBinding.ensureInitialized()` is called

2. **No Data in Dashboard**
   - Wait a few minutes (data may take time to appear)
   - Check network connectivity
   - Verify app key is correct

3. **Android Build Errors**
   - Ensure Gradle plugin version matches
   - Verify `apply plugin: 'adeum'` is at bottom of `build.gradle`
   - Clean and rebuild: `flutter clean && flutter pub get`

## 📝 License

This infrastructure module follows the same license as the BUMA Core library.

