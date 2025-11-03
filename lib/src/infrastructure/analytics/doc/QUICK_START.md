# Analytics Quick Start Guide

Get started with Analytics and Crash Reporting in 5 minutes!

## 📦 1. Install Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # For Analytics (PostHog)
  posthog_flutter: ^5.8.0
  
  # For Crash Reporting (Firebase Crashlytics)
  firebase_core: ^3.0.0
  firebase_crashlytics: ^5.0.4
```

## 🚀 2. Initialize (One-Time Setup)

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup services
  await _setupAnalytics();
  await _setupCrashReporter();
  
  // Run app with error handling
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      getIt<CrashReporterService>().recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    },
  );
}

Future<void> _setupAnalytics() async {
  // Register PostHog
  getIt.registerLazySingleton<AnalyticsService>(
    () => PostHogAnalyticsServiceImpl(
      apiKey: 'YOUR_POSTHOG_API_KEY',
      host: 'https://app.posthog.com',
    ),
  );
  
  // Initialize
  await getIt<AnalyticsService>().initialize();
}

Future<void> _setupCrashReporter() async {
  // Register Firebase Crashlytics
  getIt.registerLazySingleton<CrashReporterService>(
    () => FirebaseCrashlyticsServiceImpl(),
  );
  
  // Initialize
  final crashReporter = getIt<CrashReporterService>();
  await crashReporter.initialize();
  
  // Catch Flutter errors
  FlutterError.onError = (details) {
    crashReporter.recordFlutterError(details);
  };
}
```

## 📊 3. Start Tracking

### Track Events

```dart
import 'package:app_core/app_core.dart';

class MyWidget extends StatelessWidget {
  final analytics = getIt<AnalyticsService>();
  
  void _onButtonPressed() {
    // Simple event
    analytics.trackEvent(
      AnalyticsEvent(name: 'button_clicked'),
    );
    
    // Event with properties
    analytics.trackEvent(
      AnalyticsEvent(
        name: 'purchase',
        properties: {
          'amount': 99.99,
          'currency': 'USD',
        },
      ),
    );
  }
}
```

### Track Screens

```dart
class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final analytics = getIt<AnalyticsService>();
  
  @override
  void initState() {
    super.initState();
    analytics.trackScreenView('Product Screen');
  }
}
```

### Identify Users

```dart
// After login
void _onLoginSuccess(User user) {
  final analytics = getIt<AnalyticsService>();
  final crashReporter = getIt<CrashReporterService>();
  
  // Set user in analytics
  analytics.identifyUser(
    AnalyticsUser(
      id: user.id,
      email: user.email,
      name: user.name,
    ),
  );
  
  // Set user in crash reporter
  crashReporter.setUserIdentifier(user.id);
  crashReporter.setUserEmail(user.email);
}

// On logout
void _onLogout() {
  getIt<AnalyticsService>().resetUser();
}
```

## 🐛 4. Report Errors

### Automatic Error Reporting

Already set up in step 2! All uncaught errors are automatically reported.

### Manual Error Reporting

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  final crashReporter = getIt<CrashReporterService>();
  
  // Report error
  await crashReporter.recordError(
    exception: e,
    stackTrace: stackTrace,
    reason: 'Risky operation failed',
    fatal: false,
  );
}
```

### Add Debugging Context

```dart
final crashReporter = getIt<CrashReporterService>();

// Add breadcrumb logs
await crashReporter.log('User started checkout');
await crashReporter.log('Payment method selected');

// Add custom keys
await crashReporter.setCustomKey('cart_items', 3);
await crashReporter.setCustomKey('payment_method', 'credit_card');
```

## 🎯 5. Common Patterns

### Using Constants

```dart
import 'package:app_core/app_core.dart';

// Track with constants
analytics.trackEvent(
  AnalyticsEvent(
    name: AnalyticsEvents.purchase,
    properties: {
      AnalyticsProperties.amount: 99.99,
      AnalyticsProperties.currency: 'USD',
    },
  ),
);
```

### Using Predefined Events

```dart
// Login
analytics.trackEvent(
  CommonAnalyticsEvents.login(
    properties: {'method': 'email'},
  ),
);

// Purchase
analytics.trackEvent(
  CommonAnalyticsEvents.purchase(
    properties: {
      'amount': 99.99,
      'currency': 'USD',
    },
  ),
);

// Search
analytics.trackEvent(
  CommonAnalyticsEvents.search(
    properties: {
      'query': 'flutter',
      'results': 42,
    },
  ),
);
```

### Error Handling

```dart
// Always handle results
final result = await analytics.trackEvent(event);
result.fold(
  (failure) => print('Failed to track: $failure'),
  (_) => print('Tracked successfully'),
);
```

## 🎨 6. Best Practices

### ✅ DO

- Initialize services at app startup
- Identify users after login
- Reset user on logout
- Use constants for event names
- Handle analytics failures gracefully
- Add context before critical operations
- Respect user privacy preferences

### ❌ DON'T

- Track sensitive user data (passwords, credit cards)
- Track in every single widget (be selective)
- Ignore error handling
- Hardcode event names (use constants)
- Track without user consent (GDPR/privacy)

## 🔄 7. Switching Providers

Want to switch from PostHog to Mixpanel? It's easy!

```dart
// Step 1: Create Mixpanel implementation (when available)
// Step 2: Update registration (ONE LINE!)

// Before (PostHog)
getIt.registerLazySingleton<AnalyticsService>(
  () => PostHogAnalyticsServiceImpl(...),
);

// After (Mixpanel)
getIt.registerLazySingleton<AnalyticsService>(
  () => MixpanelAnalyticsServiceImpl(...),
);

// Step 3: That's it! No other code changes needed! ✨
```

## 📚 Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) for more examples
- Explore the API documentation in the contract files

## 🆘 Need Help?

Common issues:

**"Package not found" errors**
→ Make sure you added the packages to `pubspec.yaml` and ran `flutter pub get`

**"Not initialized" errors**
→ Call `initialize()` before using any analytics/crash reporter methods

**Events not showing in PostHog**
→ Check your API key and host URL are correct, and flush events before closing app

**Crashes not showing in Firebase**
→ Make sure Firebase is initialized and crash collection is enabled

---

Happy tracking! 📊 🚀

