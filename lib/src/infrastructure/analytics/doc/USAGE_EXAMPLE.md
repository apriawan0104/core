# Analytics Usage Examples

This document provides practical examples of using the Analytics infrastructure in your Flutter application.

## Table of Contents

- [Setup](#setup)
- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Complete Integration](#complete-integration)
- [Testing](#testing)

## Setup

### 1. Add Dependencies

Add the required packages to your `pubspec.yaml`:

```yaml
dependencies:
  # Core library
  app_core:
    path: ../core  # or your package location

  # Analytics provider (choose one or both)
  posthog_flutter: ^5.8.0

  # Crash reporting provider (choose one or both)
  firebase_core: ^3.0.0
  firebase_crashlytics: ^5.0.4
```

### 2. Initialize Firebase (if using Firebase Crashlytics)

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

### 3. Setup Dependency Injection

```dart
// lib/config/di.dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register Analytics Service
  getIt.registerLazySingleton<AnalyticsService>(
    () => PostHogAnalyticsServiceImpl(
      apiKey: const String.fromEnvironment('POSTHOG_API_KEY'),
      host: const String.fromEnvironment(
        'POSTHOG_HOST',
        defaultValue: 'https://app.posthog.com',
      ),
    ),
  );

  // Initialize analytics
  final analytics = getIt<AnalyticsService>();
  await analytics.initialize();

  // Register Crash Reporter Service
  getIt.registerLazySingleton<CrashReporterService>(
    () => FirebaseCrashlyticsServiceImpl(),
  );

  // Initialize crash reporter
  final crashReporter = getIt<CrashReporterService>();
  await crashReporter.initialize();
}
```

### 4. Setup Global Error Handlers

```dart
// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_core/app_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await setupDependencies();
  
  final crashReporter = getIt<CrashReporterService>();
  
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
  
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      crashReporter.recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    },
  );
}
```

## Basic Usage

### Track Simple Events

```dart
import 'package:app_core/app_core.dart';

class HomeScreen extends StatelessWidget {
  final AnalyticsService analytics;

  const HomeScreen({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ElevatedButton(
        onPressed: () async {
          // Track button click
          await analytics.trackEvent(
            AnalyticsEvent(name: 'home_button_clicked'),
          );
        },
        child: const Text('Click Me'),
      ),
    );
  }
}
```

### Track Events with Properties

```dart
// Track purchase event
await analytics.trackEvent(
  AnalyticsEvent(
    name: 'purchase_completed',
    properties: {
      'product_id': '123',
      'product_name': 'Premium Plan',
      'amount': 99.99,
      'currency': 'USD',
      'payment_method': 'credit_card',
    },
  ),
);

// Track search event
await analytics.trackEvent(
  AnalyticsEvent(
    name: 'search_performed',
    properties: {
      'query': 'flutter tutorial',
      'results_count': 42,
      'category': 'education',
    },
  ),
);
```

### Track Screen Views

```dart
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailScreen({required this.productId});
  
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final AnalyticsService _analytics;
  
  @override
  void initState() {
    super.initState();
    _analytics = getIt<AnalyticsService>();
    
    // Track screen view
    _analytics.trackScreenView(
      'Product Detail',
      properties: {
        'product_id': widget.productId,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Build UI...
  }
}
```

### Identify Users

```dart
// After successful login
Future<void> onLoginSuccess(User user) async {
  final analytics = getIt<AnalyticsService>();
  final crashReporter = getIt<CrashReporterService>();
  
  // Identify user in analytics
  await analytics.identifyUser(
    AnalyticsUser(
      id: user.id,
      email: user.email,
      name: user.name,
      properties: {
        'plan': user.subscriptionPlan,
        'signup_date': user.createdAt.toIso8601String(),
        'country': user.country,
      },
    ),
  );
  
  // Set user in crash reporter
  await crashReporter.setUserIdentifier(user.id);
  await crashReporter.setUserEmail(user.email);
  await crashReporter.setUserName(user.name);
}

// On logout
Future<void> onLogout() async {
  final analytics = getIt<AnalyticsService>();
  
  await analytics.resetUser();
}
```

### Report Errors

```dart
// In a repository or service
class PaymentRepository {
  final CrashReporterService crashReporter;
  
  PaymentRepository(this.crashReporter);
  
  Future<Either<Failure, Payment>> processPayment(
    String paymentMethodId,
    double amount,
  ) async {
    try {
      final result = await _paymentApi.charge(paymentMethodId, amount);
      return Right(result);
    } catch (e, stackTrace) {
      // Log error to crash reporter
      await crashReporter.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Payment processing failed',
        fatal: false,
      );
      
      return Left(PaymentFailure(e.toString()));
    }
  }
}
```

## Advanced Usage

### Using Constants

```dart
import 'package:app_core/app_core.dart';

// Track login with constants
await analytics.trackEvent(
  AnalyticsEvent(
    name: AnalyticsEvents.login,
    properties: {
      AnalyticsProperties.method: 'email',
      AnalyticsProperties.source: 'login_screen',
    },
  ),
);

// Set crash context with constants
await crashReporter.setCustomKey(
  CrashReporterKeys.lastScreen,
  'checkout',
);
await crashReporter.setCustomKey(
  CrashReporterKeys.cartItems,
  3,
);
```

### Using Predefined Events

```dart
// Sign up event
await analytics.trackEvent(
  CommonAnalyticsEvents.signUp(
    properties: {
      'method': 'google',
      'referrer': 'facebook_ad',
    },
  ),
);

// Purchase event
await analytics.trackEvent(
  CommonAnalyticsEvents.purchase(
    properties: {
      'amount': 99.99,
      'currency': 'USD',
      'items': 1,
    },
  ),
);

// Search event
await analytics.trackEvent(
  CommonAnalyticsEvents.search(
    properties: {
      'query': 'flutter',
      'results': 42,
    },
  ),
);
```

### Super Properties (Global Properties)

```dart
// Set app-level properties that will be sent with all events
Future<void> setupAnalytics() async {
  final analytics = getIt<AnalyticsService>();
  
  await analytics.setSuperProperties({
    'app_version': '1.2.3',
    'platform': 'mobile',
    'environment': 'production',
    'build_number': '42',
  });
}

// Update specific property
await analytics.setSuperProperty('theme', 'dark');

// Remove property
await analytics.removeSuperProperty('theme');
```

### Crash Context

```dart
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CrashReporterService crashReporter;
  
  CheckoutBloc(this.crashReporter) : super(CheckoutInitial()) {
    on<CheckoutStarted>(_onStarted);
    on<PaymentSubmitted>(_onPaymentSubmitted);
  }
  
  Future<void> _onPaymentSubmitted(
    PaymentSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    // Set context before critical operation
    await crashReporter.setCustomKey('operation', 'payment_processing');
    await crashReporter.setCustomKey('amount', event.amount);
    await crashReporter.setCustomKey('payment_method', event.methodId);
    await crashReporter.log('Starting payment processing');
    
    try {
      final result = await paymentRepository.processPayment(
        event.methodId,
        event.amount,
      );
      
      result.fold(
        (failure) {
          crashReporter.log('Payment failed: ${failure.message}');
          emit(CheckoutFailure(failure.message));
        },
        (payment) {
          crashReporter.log('Payment successful');
          emit(CheckoutSuccess(payment));
        },
      );
    } catch (e, stackTrace) {
      await crashReporter.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error during payment',
        fatal: false,
      );
      emit(CheckoutFailure(e.toString()));
    }
  }
}
```

### Detailed Crash Reports

```dart
try {
  await complexOperation();
} catch (e, stackTrace) {
  await crashReporter.recordCrash(
    CrashReport(
      exception: e,
      stackTrace: stackTrace,
      message: 'Complex operation failed',
      fatal: false,
      customData: {
        'user_id': currentUser.id,
        'operation_type': 'data_sync',
        'retry_count': retryCount,
        'network_status': isOnline ? 'online' : 'offline',
      },
      logs: [
        'Operation started at ${DateTime.now()}',
        'Step 1 completed',
        'Step 2 failed with error',
      ],
    ),
  );
}
```

## Complete Integration

### App-Level Analytics Wrapper

```dart
// lib/services/app_analytics.dart
import 'package:app_core/app_core.dart';

class AppAnalytics {
  final AnalyticsService _analytics;
  final CrashReporterService _crashReporter;
  
  AppAnalytics({
    required AnalyticsService analytics,
    required CrashReporterService crashReporter,
  })  : _analytics = analytics,
        _crashReporter = crashReporter;
  
  // Convenience methods
  Future<void> trackScreen(String name) {
    return _analytics.trackScreenView(name);
  }
  
  Future<void> trackAction(String action, {Map<String, dynamic>? data}) {
    return _analytics.trackEvent(
      AnalyticsEvent(
        name: action,
        properties: data,
      ),
    );
  }
  
  Future<void> setUser(User user) async {
    await _analytics.identifyUser(
      AnalyticsUser(
        id: user.id,
        email: user.email,
        name: user.name,
      ),
    );
    
    await _crashReporter.setUserIdentifier(user.id);
    await _crashReporter.setUserEmail(user.email);
  }
  
  Future<void> clearUser() {
    return _analytics.resetUser();
  }
  
  Future<void> reportError(dynamic error, StackTrace? stackTrace) {
    return _crashReporter.recordError(
      exception: error,
      stackTrace: stackTrace,
    );
  }
}
```

### Navigation Observer

```dart
// lib/observers/analytics_navigation_observer.dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class AnalyticsNavigationObserver extends NavigatorObserver {
  final AnalyticsService analytics;
  
  AnalyticsNavigationObserver(this.analytics);
  
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      analytics.trackScreenView(route.settings.name!);
    }
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      analytics.trackScreenView(previousRoute!.settings.name!);
    }
  }
}

// Usage in MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analytics = getIt<AnalyticsService>();
    
    return MaterialApp(
      navigatorObservers: [
        AnalyticsNavigationObserver(analytics),
      ],
      // ...
    );
  }
}
```

## Testing

### Mock Analytics Service

```dart
// test/mocks/mock_analytics_service.dart
import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';

class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> trackedEvents = [];
  final List<String> trackedScreens = [];
  AnalyticsUser? identifiedUser;
  bool isInitialized = false;
  
  @override
  Future<Either<Failure, void>> initialize() async {
    isInitialized = true;
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    trackedEvents.add(event);
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    trackedScreens.add(screenName);
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> identifyUser(AnalyticsUser user) async {
    identifiedUser = user;
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> resetUser() async {
    identifiedUser = null;
    return const Right(null);
  }
  
  // Implement other methods...
}
```

### Testing with Mock

```dart
// test/blocs/checkout_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_core/app_core.dart';

void main() {
  late MockAnalyticsService mockAnalytics;
  late CheckoutBloc bloc;
  
  setUp(() {
    mockAnalytics = MockAnalyticsService();
    bloc = CheckoutBloc(analytics: mockAnalytics);
  });
  
  test('should track purchase event on successful payment', () async {
    // Act
    await bloc.processPayment('pm_123', 99.99);
    
    // Assert
    expect(mockAnalytics.trackedEvents.length, 1);
    expect(mockAnalytics.trackedEvents.first.name, 'purchase_completed');
    expect(
      mockAnalytics.trackedEvents.first.properties?['amount'],
      99.99,
    );
  });
  
  test('should identify user after login', () async {
    // Arrange
    final user = User(id: '123', email: 'test@example.com');
    
    // Act
    await bloc.onLogin(user);
    
    // Assert
    expect(mockAnalytics.identifiedUser, isNotNull);
    expect(mockAnalytics.identifiedUser?.id, '123');
    expect(mockAnalytics.identifiedUser?.email, 'test@example.com');
  });
}
```

## Best Practices

1. **Always initialize services at app startup**
2. **Use constants for event names and property keys**
3. **Set user context after login**
4. **Reset user context on logout**
5. **Add crash context before critical operations**
6. **Use predefined events when possible**
7. **Test analytics calls with mocks**
8. **Respect user privacy preferences**
9. **Flush events before app termination**
10. **Handle analytics failures gracefully**

For more information, see the [README.md](README.md) documentation.

