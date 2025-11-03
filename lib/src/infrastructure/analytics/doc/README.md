# Analytics Infrastructure

This module provides dependency-independent abstractions for analytics tracking and crash reporting in Flutter applications.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
  - [Analytics Service](#analytics-service)
  - [Crash Reporter Service](#crash-reporter-service)
- [Supported Providers](#supported-providers)
- [Setup Guide](#setup-guide)
- [Usage Examples](#usage-examples)
- [Dependency Independence](#dependency-independence)
- [Migration Guide](#migration-guide)
- [Best Practices](#best-practices)

## Overview

The Analytics infrastructure provides:

✅ **Dependency-independent abstractions** - Never tied to specific providers  
✅ **Easy provider switching** - Change providers with one line of code  
✅ **Multiple provider support** - Use multiple analytics services simultaneously  
✅ **Consistent error handling** - All methods return `Either<Failure, T>`  
✅ **Type-safe models** - Well-defined models for events, users, and crashes  
✅ **Comprehensive documentation** - Every method fully documented  

## Architecture

```
lib/src/infrastructure/analytics/
├── contract/           → Service interfaces (abstractions)
│   ├── analytics.service.dart
│   ├── crash_reporter.service.dart
│   └── contracts.dart
├── models/            → Data models
│   ├── analytics_event.model.dart
│   ├── analytics_user.model.dart
│   ├── crash_report.model.dart
│   └── models.dart
├── impl/              → Provider implementations
│   ├── posthog_analytics.service.impl.dart
│   ├── firebase_crashlytics.service.impl.dart
│   └── impl.dart
├── doc/               → Documentation
│   └── README.md
└── analytics.dart     → Main export file
```

## Services

### Analytics Service

The `AnalyticsService` interface provides:

- **Event Tracking** - Track user actions and system events
- **User Identification** - Associate events with users
- **Screen Tracking** - Track screen/page views
- **Super Properties** - Set global properties for all events
- **Enable/Disable** - Respect user privacy preferences
- **Event Batching** - Efficient network usage with flush control

**Interface**: `AnalyticsService`  
**Implementation**: `PostHogAnalyticsServiceImpl`

### Crash Reporter Service

The `CrashReporterService` interface provides:

- **Automatic Crash Reporting** - Capture uncaught exceptions
- **Manual Error Reporting** - Report caught exceptions
- **Custom Logging** - Add breadcrumb logs
- **Custom Keys** - Attach debugging context
- **User Identification** - Track which users experience crashes
- **Fatal/Non-Fatal** - Distinguish crash severity

**Interface**: `CrashReporterService`  
**Implementation**: `FirebaseCrashlyticsServiceImpl`

## Supported Providers

| Provider | Service | Status | Package |
|----------|---------|--------|---------|
| **PostHog** | Analytics | ✅ Implemented | `posthog_flutter: ^5.8.0` |
| **Firebase Crashlytics** | Crash Reporting | ✅ Implemented | `firebase_crashlytics: ^5.0.4` |
| **Mixpanel** | Analytics | 🔜 Planned | - |
| **Amplitude** | Analytics | 🔜 Planned | - |
| **Sentry** | Crash Reporting | 🔜 Planned | - |

## Setup Guide

### 1. Setup PostHog Analytics

**Step 1: Add dependency**
```yaml
dependencies:
  posthog_flutter: ^5.8.0
```

**Step 2: Create instance**
```dart
final analytics = PostHogAnalyticsServiceImpl(
  apiKey: 'YOUR_POSTHOG_API_KEY',
  host: 'https://app.posthog.com', // or self-hosted URL
  captureScreenViews: false, // optional
  debug: false, // optional
);
```

**Step 3: Initialize**
```dart
final result = await analytics.initialize();
result.fold(
  (failure) => print('Failed to initialize analytics: $failure'),
  (_) => print('Analytics initialized'),
);
```

**Step 4: Register in DI**
```dart
getIt.registerLazySingleton<AnalyticsService>(
  () => PostHogAnalyticsServiceImpl(
    apiKey: Env.posthogApiKey,
    host: Env.posthogHost,
  ),
);
```

### 2. Setup Firebase Crashlytics

**Step 1: Add dependencies**
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_crashlytics: ^5.0.4
```

**Step 2: Initialize Firebase**
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Step 3: Create crash reporter**
```dart
final crashReporter = FirebaseCrashlyticsServiceImpl(
  enableInDebugMode: false, // optional
);

await crashReporter.initialize();
```

**Step 4: Setup error handlers**
```dart
// Catch Flutter framework errors
FlutterError.onError = (FlutterErrorDetails details) {
  crashReporter.recordFlutterError(details);
};

// Catch async errors
PlatformDispatcher.instance.onError = (error, stack) {
  crashReporter.recordError(
    exception: error,
    stackTrace: stack,
    fatal: true,
  );
  return true;
};
```

**Step 5: Register in DI**
```dart
getIt.registerLazySingleton<CrashReporterService>(
  () => FirebaseCrashlyticsServiceImpl(),
);
```

## Usage Examples

### Analytics Examples

#### Track Simple Event
```dart
await analytics.trackEvent(
  AnalyticsEvent(name: 'button_clicked'),
);
```

#### Track Event with Properties
```dart
await analytics.trackEvent(
  AnalyticsEvent(
    name: 'purchase_completed',
    properties: {
      'product_id': '123',
      'amount': 99.99,
      'currency': 'USD',
      'payment_method': 'credit_card',
    },
  ),
);
```

#### Track Screen View
```dart
await analytics.trackScreenView(
  'Product Detail',
  properties: {'product_id': '123'},
);
```

#### Identify User
```dart
await analytics.identifyUser(
  AnalyticsUser(
    id: 'user_123',
    email: 'john@example.com',
    name: 'John Doe',
    properties: {
      'plan': 'premium',
      'signup_date': '2025-01-01',
    },
  ),
);
```

#### Set Super Properties
```dart
// Set single property
await analytics.setSuperProperty('app_version', '1.2.3');

// Set multiple properties
await analytics.setSuperProperties({
  'app_version': '1.2.3',
  'platform': 'mobile',
  'environment': 'production',
});
```

#### Reset User on Logout
```dart
await analytics.resetUser();
```

#### Using Predefined Events
```dart
// Login event
await analytics.trackEvent(
  CommonAnalyticsEvents.login(
    properties: {'method': 'email'},
  ),
);

// Purchase event
await analytics.trackEvent(
  CommonAnalyticsEvents.purchase(
    properties: {
      'amount': 99.99,
      'currency': 'USD',
    },
  ),
);
```

### Crash Reporting Examples

#### Report Caught Error
```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await crashReporter.recordError(
    exception: e,
    stackTrace: stackTrace,
    reason: 'Failed to complete risky operation',
    fatal: false,
  );
}
```

#### Report with Custom Data
```dart
await crashReporter.recordCrash(
  CrashReport(
    exception: exception,
    stackTrace: stackTrace,
    message: 'Payment processing failed',
    fatal: true,
    customData: {
      'transaction_id': '123',
      'amount': 99.99,
      'user_id': 'user_123',
    },
    logs: [
      'User initiated payment',
      'Payment gateway responded with error',
      'Retrying payment',
    ],
  ),
);
```

#### Add Breadcrumb Logs
```dart
await crashReporter.log('User navigated to checkout');
await crashReporter.log('Payment method selected: credit_card');
await crashReporter.log('Processing payment...');
```

#### Set Custom Keys
```dart
await crashReporter.setCustomKey('last_screen', 'checkout');
await crashReporter.setCustomKey('items_in_cart', 3);
await crashReporter.setCustomKey('is_premium', true);
```

#### Set User Information
```dart
await crashReporter.setUserIdentifier('user_123');
await crashReporter.setUserEmail('user@example.com');
await crashReporter.setUserName('John Doe');
```

## Dependency Independence

### Why It Matters

❌ **Bad: Tightly Coupled**
```dart
// Exposes Firebase types - hard to change!
abstract class CrashReporter {
  Future<void> report(FirebaseCrashReport report);
}
```

✅ **Good: Dependency Independent**
```dart
// Own types only - easy to change!
abstract class CrashReporterService {
  Future<Either<Failure, void>> recordCrash(CrashReport report);
}
```

### Switching Providers

Switching from PostHog to Mixpanel takes **< 5 minutes**:

**Step 1: Create new implementation**
```dart
class MixpanelAnalyticsServiceImpl implements AnalyticsService {
  // Implement interface with Mixpanel SDK
}
```

**Step 2: Update DI registration (ONE LINE!)**
```dart
// Old
getIt.registerLazySingleton<AnalyticsService>(
  () => PostHogAnalyticsServiceImpl(...),
);

// New
getIt.registerLazySingleton<AnalyticsService>(
  () => MixpanelAnalyticsServiceImpl(...),
);
```

**Step 3: Update pubspec.yaml**
```yaml
# Remove: posthog_flutter: ^5.8.0
# Add: mixpanel_flutter: ^2.0.0
```

**Done!** ✅ No business logic changes needed!

### Multiple Providers

You can even use multiple analytics providers simultaneously:

```dart
class CompositeAnalyticsService implements AnalyticsService {
  final PostHogAnalyticsServiceImpl posthog;
  final MixpanelAnalyticsServiceImpl mixpanel;

  CompositeAnalyticsService({
    required this.posthog,
    required this.mixpanel,
  });

  @override
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    // Send to both providers!
    await posthog.trackEvent(event);
    await mixpanel.trackEvent(event);
    return const Right(null);
  }

  // Implement other methods...
}
```

## Migration Guide

### From Firebase Analytics to PostHog

```dart
// Before: Firebase Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics.instance.logEvent(
  name: 'purchase',
  parameters: {'amount': 99.99},
);

// After: PostHog via our abstraction
import 'package:core/infrastructure/analytics.dart';

analytics.trackEvent(
  AnalyticsEvent(
    name: 'purchase',
    properties: {'amount': 99.99},
  ),
);
```

### From Sentry to Firebase Crashlytics

```dart
// Before: Sentry
import 'package:sentry_flutter/sentry_flutter.dart';

Sentry.captureException(exception, stackTrace: stackTrace);

// After: Firebase Crashlytics via our abstraction
import 'package:core/infrastructure/analytics.dart';

crashReporter.recordError(
  exception: exception,
  stackTrace: stackTrace,
);
```

## Best Practices

### 1. Use Dependency Injection

```dart
// ✅ Good: Inject via constructor
class CheckoutBloc {
  final AnalyticsService analytics;

  CheckoutBloc(this.analytics);

  Future<void> completePurchase() async {
    await analytics.trackEvent(
      AnalyticsEvent(name: 'purchase_completed'),
    );
  }
}
```

### 2. Handle Errors Gracefully

```dart
// ✅ Good: Handle both success and failure
final result = await analytics.trackEvent(event);
result.fold(
  (failure) => logger.warn('Failed to track event: $failure'),
  (_) => logger.debug('Event tracked successfully'),
);
```

### 3. Use Predefined Events

```dart
// ✅ Good: Use common events for consistency
await analytics.trackEvent(
  CommonAnalyticsEvents.login(properties: {'method': 'email'}),
);

// ❌ Bad: Inconsistent naming
await analytics.trackEvent(AnalyticsEvent(name: 'user_login'));
await analytics.trackEvent(AnalyticsEvent(name: 'signin'));
```

### 4. Set User Context Early

```dart
// After successful login
await analytics.identifyUser(
  AnalyticsUser(
    id: user.id,
    email: user.email,
    properties: {'plan': user.plan},
  ),
);

await crashReporter.setUserIdentifier(user.id);
await crashReporter.setUserEmail(user.email);
```

### 5. Reset on Logout

```dart
// On logout
await analytics.resetUser();
// Crash reporter keeps user ID for debugging
```

### 6. Add Context with Custom Keys

```dart
// Before important operations
await crashReporter.setCustomKey('operation', 'payment_processing');
await crashReporter.log('Starting payment process');

try {
  await processPayment();
} catch (e, stack) {
  await crashReporter.recordError(
    exception: e,
    stackTrace: stack,
    reason: 'Payment processing failed',
  );
}
```

### 7. Respect User Privacy

```dart
// Disable tracking based on user preference
if (!userConsents.analytics) {
  await analytics.setEnabled(false);
}

if (!userConsents.crashReporting) {
  await crashReporter.setCrashCollectionEnabled(false);
}
```

### 8. Flush Before Critical Points

```dart
// Before app termination
await analytics.flush();

// Before long background operation
await analytics.flush();
```

## Testing

### Mock Analytics Service

```dart
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> trackedEvents = [];

  @override
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    trackedEvents.add(event);
    return const Right(null);
  }

  // Implement other methods...
}

// In tests
test('should track purchase event', () async {
  final mockAnalytics = MockAnalyticsService();
  final bloc = CheckoutBloc(mockAnalytics);

  await bloc.completePurchase();

  expect(mockAnalytics.trackedEvents.length, 1);
  expect(mockAnalytics.trackedEvents.first.name, 'purchase_completed');
});
```

## FAQ

**Q: Can I use multiple analytics providers simultaneously?**  
A: Yes! Create a composite service that implements `AnalyticsService` and delegates to multiple providers.

**Q: How do I switch from PostHog to Mixpanel?**  
A: Create a Mixpanel implementation, update DI registration, update pubspec.yaml. No business logic changes needed!

**Q: Should I track analytics in debug mode?**  
A: Generally no, to avoid polluting your analytics data. Use environment variables or feature flags to control this.

**Q: How do I test code that uses analytics?**  
A: Create mock implementations of the service interfaces and verify method calls in tests.

**Q: Can I add custom methods to the interface?**  
A: Yes, but ensure they're provider-agnostic. If a method is specific to one provider, consider using extension methods instead.

**Q: What if a provider doesn't support a method?**  
A: Return a `Left(Failure)` with a "not_supported" code. Document limitations in the implementation class.

## Support

For issues, questions, or contributions related to the Analytics infrastructure:

1. Check this README and inline documentation
2. Review the example implementations
3. Create an issue in the repository

## License

This module is part of the BUMA Core library.

