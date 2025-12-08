# Automatic Error Reporting Setup Guide

Complete guide for setting up automatic error reporting in your Flutter application using BUMA Core's error handling utilities.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Initial Setup](#initial-setup)
- [Network Error Auto-Reporting](#network-error-auto-reporting)
- [Global Error Handler](#global-error-handler)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

BUMA Core provides three levels of error handling:

1. **Flutter Framework Errors** - Catch all Flutter errors automatically
2. **Network Errors** - Auto-report network failures via interceptors
3. **Business Logic Errors** - Simplified error handling with ErrorHandler

### What Gets Reported

- ✅ Uncaught exceptions (fatal crashes)
- ✅ Flutter framework errors
- ✅ Platform-specific errors
- ✅ Network errors (configurable)
- ✅ Business logic errors (opt-in)

---

## 🚀 Initial Setup

### 1. Add Dependencies

Ensure these are in your `pubspec.yaml`:

```yaml
dependencies:
  # BUMA Core
  app_core:
    path: ../core  # or your path

  # Firebase (for Crashlytics)
  firebase_core: ^3.0.0
  firebase_crashlytics: ^5.0.4
```

### 2. Initialize Firebase & Crash Reporter

In your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:app_core/app_core.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup DI
  configureDependencies();
  
  // Setup error handling
  await _setupErrorHandling();
  
  // Run app in error zone
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      // Catch all uncaught async errors
      getIt<CrashReporterService>().recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    },
  );
}

Future<void> _setupErrorHandling() async {
  final crashReporter = getIt<CrashReporterService>();
  
  // Initialize crash reporter
  await crashReporter.initialize();
  
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    crashReporter.recordFlutterError(details);
  };
  
  // Catch platform errors (iOS/Android native crashes)
  PlatformDispatcher.instance.onError = (error, stack) {
    crashReporter.recordError(
      exception: error,
      stackTrace: stack,
      fatal: true,
    );
    return true;
  };
}
```

### 3. Register Services in DI

Register the required services:

```dart
// In your DI setup file (e.g., locator.dart or using injectable)

import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register CrashReporter
  getIt.registerLazySingleton<CrashReporterService>(
    () => FirebaseCrashlyticsServiceImpl(
      enableInDebugMode: false, // Don't send crashes during development
    ),
  );
  
  // Register Logger (if you have one)
  getIt.registerLazySingleton<LogService>(
    () => YourLogServiceImpl(),
  );
  
  // Register ErrorHandler
  getIt.registerLazySingleton<ErrorHandler>(
    () => ErrorHandler(
      crashReporter: getIt<CrashReporterService>(),
      logger: getIt<LogService>(),
    ),
  );
}
```

---

## 🌐 Network Error Auto-Reporting

Automatically report network errors to Firebase Crashlytics.

### Setup Network Interceptor

```dart
// In your DI setup or network configuration

import 'package:app_core/app_core.dart';

void setupHttpClient() {
  getIt.registerLazySingleton<HttpClient>(
    () {
      // Create HTTP client
      final client = DioHttpClient(
        baseUrl: 'https://api.example.com',
        enableLogging: kDebugMode,
      );
      
      // Add crash reporting interceptor
      final crashReporter = getIt<CrashReporterService>();
      final logger = getIt<LogService>();
      
      client.addErrorInterceptor(
        CrashReportingInterceptor(
          crashReporter: crashReporter,
          logger: logger,
          // Configuration
          reportClientErrors: false,     // Don't report 4xx errors
          reportServerErrors: true,      // Report 5xx errors
          reportTimeoutErrors: true,     // Report timeouts
          reportConnectionErrors: true,  // Report connection issues
          context: 'API Call',          // Optional context
        ).call,
      );
      
      return client;
    },
  );
}
```

### What Gets Reported

With the interceptor configured:

```dart
// Any network call that fails will be automatically reported
final result = await httpClient.get('/users');

result.fold(
  (failure) {
    // ✅ Failure already reported to Crashlytics automatically!
    // No manual reporting needed
    showErrorToUser(failure.message);
  },
  (response) {
    // Handle success
  },
);
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `reportClientErrors` | `false` | Report 4xx errors (usually user input issues) |
| `reportServerErrors` | `true` | Report 5xx errors (backend issues) |
| `reportTimeoutErrors` | `true` | Report timeout failures |
| `reportConnectionErrors` | `true` | Report connection failures |
| `context` | `null` | Custom context for all network errors |

---

## 🎯 Global Error Handler

Use `ErrorHandler` to simplify error handling in your business logic.

### Basic Usage

```dart
import 'package:app_core/app_core.dart';

class UserRepository {
  final AuthService authService;
  final ErrorHandler errorHandler;
  
  UserRepository(this.authService, this.errorHandler);
  
  Future<User?> getCurrentUser() async {
    // Simple one-liner error handling
    return errorHandler.handleResult(
      await authService.getCurrentUser(),
      reportToCrashlytics: true,
      context: 'Getting current user',
      onError: (failure) async {
        // Handle error in UI
        showSnackBar('Failed to get user: ${failure.message}');
      },
    );
  }
}
```

### Wrap Risky Operations

```dart
Future<Either<Failure, void>> saveUserProfile(User user) async {
  // Wrap operations that might throw exceptions
  return errorHandler.wrapAsync(
    () async {
      final response = await http.post('/users', body: user.toJson());
      return response.data;
    },
    context: 'Saving user profile',
    reportToCrashlytics: true,
    fatal: false,
  );
}
```

### With Success/Error Callbacks

```dart
Future<void> signIn(String email, String password) async {
  final result = await errorHandler.handleResult(
    await authService.signIn(email, password),
    reportToCrashlytics: true,
    context: 'User sign in',
    onError: (failure) async {
      // Track failed login
      analytics.trackEvent('login_failed', {
        'reason': failure.message,
      });
      
      // Show error
      showErrorDialog(failure.message);
    },
    onSuccess: (credentials) async {
      // Track successful login
      analytics.trackEvent('login_success');
      
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    },
  );
}
```

### Synchronous Operations

```dart
Either<Failure, Map<String, dynamic>> parseJson(String json) {
  return errorHandler.wrapSync(
    () => jsonDecode(json),
    context: 'Parsing JSON response',
  );
}
```

---

## ✅ Best Practices

### 1. Don't Report User Errors

❌ **Bad**: Report validation errors
```dart
// Don't do this!
if (email.isEmpty) {
  crashReporter.recordError(exception: 'Email is empty');
}
```

✅ **Good**: Only report unexpected errors
```dart
// Only report actual crashes
try {
  await riskyOperation();
} catch (e, stack) {
  crashReporter.recordError(exception: e, stackTrace: stack);
}
```

### 2. Add Context for Debugging

❌ **Bad**: Generic error reporting
```dart
crashReporter.recordError(exception: error);
```

✅ **Good**: Include context
```dart
crashReporter.recordError(
  exception: error,
  stackTrace: stackTrace,
  reason: 'Failed to sync offline data',
  information: [
    'User ID: ${user.id}',
    'Pending items: ${pendingItems.length}',
    'Last sync: ${lastSyncTime}',
  ],
);
```

### 3. Use ErrorHandler for Consistency

❌ **Bad**: Repetitive error handling
```dart
final result = await service.getData();
result.fold(
  (failure) {
    logger.error(failure.message);
    crashReporter.recordError(exception: failure);
    showError(failure.message);
  },
  (data) => processData(data),
);
```

✅ **Good**: Use ErrorHandler
```dart
final data = await errorHandler.handleResult(
  await service.getData(),
  reportToCrashlytics: true,
  context: 'Getting data',
  onError: (failure) => showError(failure.message),
);
```

### 4. Mark Fatal Errors Correctly

```dart
// Non-fatal - User can continue using app
errorHandler.wrapAsync(
  () => syncBackgroundData(),
  fatal: false,  // Background sync failure
);

// Fatal - App cannot continue
errorHandler.wrapAsync(
  () => initializeCriticalServices(),
  fatal: true,  // App initialization failure
);
```

### 5. Disable in Debug Mode

```dart
// Only report crashes in production
getIt.registerLazySingleton<CrashReporterService>(
  () => FirebaseCrashlyticsServiceImpl(
    enableInDebugMode: false, // ← Important!
  ),
);
```

---

## 📚 Examples

### Complete Repository Example

```dart
import 'package:app_core/app_core.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserRepository {
  final HttpClient httpClient;
  final ErrorHandler errorHandler;
  final LogService logger;
  
  UserRepository(
    this.httpClient,
    this.errorHandler,
    this.logger,
  );
  
  Future<User?> getUser(String id) async {
    return errorHandler.handleResult(
      await _fetchUser(id),
      reportToCrashlytics: true,
      context: 'Fetching user $id',
      onError: (failure) async {
        logger.warning('Failed to get user: ${failure.message}');
      },
    );
  }
  
  Future<Either<Failure, User>> _fetchUser(String id) async {
    final result = await httpClient.get('/users/$id');
    
    return result.fold(
      (failure) => Left(failure),
      (response) {
        try {
          final user = User.fromJson(response.data);
          return Right(user);
        } catch (e) {
          return Left(Failure(message: 'Failed to parse user data'));
        }
      },
    );
  }
  
  Future<Either<Failure, void>> updateUser(User user) async {
    return errorHandler.wrapAsync(
      () async {
        final result = await httpClient.put(
          '/users/${user.id}',
          data: user.toJson(),
        );
        
        return result.fold(
          (failure) => throw failure,
          (response) => null,
        );
      },
      context: 'Updating user ${user.id}',
      reportToCrashlytics: true,
    );
  }
}
```

### Complete Main.dart Example

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'dart:async';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup DI
  configureDependencies();
  
  // Setup error handling
  await _setupErrorHandling();
  
  // Run app with error zone
  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stackTrace) {
      debugPrint('Uncaught error: $error');
      getIt<CrashReporterService>().recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    },
  );
}

Future<void> _setupErrorHandling() async {
  final crashReporter = getIt<CrashReporterService>();
  
  // Initialize
  await crashReporter.initialize();
  
  // Set user info (optional)
  await crashReporter.setUserIdentifier('user_123');
  
  // Set custom keys (optional)
  await crashReporter.setCustomKeys({
    'app_version': '1.0.0',
    'environment': kDebugMode ? 'debug' : 'production',
  });
  
  // Catch Flutter errors
  FlutterError.onError = (details) {
    debugPrint('Flutter error: ${details.exception}');
    crashReporter.recordFlutterError(details);
  };
  
  // Catch platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform error: $error');
    crashReporter.recordError(
      exception: error,
      stackTrace: stack,
      fatal: true,
    );
    return true;
  };
}
```

---

## 🔧 Troubleshooting

### Errors Not Showing in Firebase Console

1. **Check initialization**
   ```dart
   await crashReporter.initialize();
   ```

2. **Verify Firebase config**
   - Ensure `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) are correct
   - Check Firebase project settings

3. **Check debug mode setting**
   ```dart
   FirebaseCrashlyticsServiceImpl(
     enableInDebugMode: true, // Enable for testing
   );
   ```

4. **Force send test crash**
   ```dart
   await crashReporter.recordError(
     exception: Exception('Test crash'),
     stackTrace: StackTrace.current,
     fatal: true,
   );
   await crashReporter.sendUnsentReports();
   ```

### Too Many Errors Being Reported

Adjust interceptor configuration:

```dart
CrashReportingInterceptor(
  crashReporter: crashReporter,
  reportClientErrors: false,     // ← Don't report 4xx
  reportTimeoutErrors: false,    // ← Don't report timeouts
  reportConnectionErrors: false, // ← Don't report connection issues
)
```

### Errors Missing Context

Always add context to your error reports:

```dart
errorHandler.handleResult(
  result,
  context: 'Operation name + important details', // ← Add this!
);
```

---

## 📊 Summary

### Quick Checklist

- ✅ Firebase initialized in main.dart
- ✅ CrashReporterService registered in DI
- ✅ ErrorHandler registered in DI
- ✅ FlutterError.onError configured
- ✅ PlatformDispatcher.onError configured
- ✅ runZonedGuarded wrapping runApp
- ✅ Network interceptor added to HttpClient
- ✅ ErrorHandler injected in repositories/services
- ✅ Debug mode disabled for crashlytics
- ✅ Tested with a sample crash

---

**You're all set! 🎉**

Your app now has comprehensive error reporting with automatic crash tracking, network error monitoring, and simplified error handling throughout your codebase.

