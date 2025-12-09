# Repository Error Handler

## 📚 Overview

`RepositoryErrorHandler` is a centralized error handling service for all repository operations across BUMA applications.

**Location**: `lib/src/helpers/repository_error_handler.dart`

**Package**: `buma_core_plus`

---

## 🎯 Features

### 1. **Dual-Path Error Handling**
- **Path 1**: All errors → Return `Failure` to UI (user feedback)
- **Path 2**: Filtered errors → Report to Crashlytics (monitoring)

### 2. **Smart Error Filtering**
- **DON'T report**: User errors (cancelled, invalid credentials, etc.)
- **DO report**: System errors (network, timeout, service down, etc.)

### 3. **Automatic User-Friendly Messages**
```
Technical: "SocketException: Network unreachable"
User sees: "Please check your internet connection"
```

### 4. **Highly Customizable**
- Custom error messages per operation
- Custom filtering logic per operation
- Extra context for Crashlytics
- Force reporting for critical operations

---

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:buma_core_plus/buma_core_plus.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final RepositoryErrorHandler errorHandler;

  AuthRepositoryImpl(this.remoteDataSource, this.errorHandler);

  @override
  Future<ValueGuard<void>> signOut() async {
    return errorHandler.execute(
      operation: () => remoteDataSource.signOut(),
      feature: 'authentication',
      operationName: 'signOut',
    );
  }
}
```

**That's it!** Error handling is automatic:
- ✅ Catches all errors
- ✅ Reports important ones to Crashlytics
- ✅ Returns user-friendly messages
- ✅ Consistent across all apps

---

## 📖 Usage Examples

### 1. Basic (Automatic Everything)

```dart
return errorHandler.execute(
  operation: () => dataSource.getData(),
  feature: 'profile',
  operationName: 'getData',
);
```

### 2. With Custom Message

```dart
return errorHandler.execute(
  operation: () => dataSource.signIn(email, password),
  feature: 'authentication',
  operationName: 'signIn',
  userMessageBuilder: (error) {
    if (error.toString().contains('banned')) {
      return 'Account suspended. Contact support';
    }
    return 'Sign in failed';
  },
);
```

### 3. With Extra Context

```dart
return errorHandler.execute(
  operation: () => dataSource.purchase(productId, amount),
  feature: 'payment',
  operationName: 'purchase',
  extras: {
    'productId': productId,
    'amount': amount.toString(),
    'currency': 'IDR',
  },
);
```

### 4. Force Reporting (Critical Operations)

```dart
return errorHandler.execute(
  operation: () => dataSource.initialize(),
  feature: 'app',
  operationName: 'initialize',
  forceReport: true,  // Always report initialization errors!
);
```

### 5. Custom Filtering

```dart
return errorHandler.execute(
  operation: () => dataSource.sendMoney(amount),
  feature: 'payment',
  operationName: 'sendMoney',
  shouldReport: (error) {
    // Only report if amount > 1 million
    return amount > 1000000;
  },
);
```

---

## 🔍 Smart Filtering

### Errors NOT Reported (User Errors)

```
❌ user cancelled
❌ invalid credentials
❌ user not found
❌ permission denied
```

### Errors REPORTED (System Errors)

```
✅ timeout
✅ network error
✅ service unavailable
✅ 500, 503, 502, 504
✅ configuration error
```

---

## 🎨 User-Friendly Messages

| Technical Error | User Message |
|----------------|--------------|
| `SocketException: Network unreachable` | "Please check your internet connection" |
| `503 Service Unavailable` | "Service temporarily unavailable. Please try again later" |
| `500 Internal Server Error` | "Something went wrong on our end. Please try again later" |
| `Invalid credentials` | "Invalid username or password" |
| `User cancelled` | "Operation cancelled" |

---

## 📊 Benefits

### Before (Without Error Handler)

```dart
// 15+ lines per method
@override
Future<ValueGuard<void>> signOut() async {
  try {
    await remoteDataSource.signOut();
    return ValueGuard.success(null);
  } catch (error, stackTrace) {
    // Manual error handling
    final shouldReport = _shouldReport(error);
    if (shouldReport && crashReporter != null) {
      await crashReporter.logError(...);
    }
    return ValueGuard.failure(...);
  }
}
```

### After (With Error Handler)

```dart
// 5 lines!
@override
Future<ValueGuard<void>> signOut() async {
  return errorHandler.execute(
    operation: () => remoteDataSource.signOut(),
    feature: 'authentication',
    operationName: 'signOut',
  );
}
```

**Result**: 70% less code, 100% consistency!

---

## 🌐 Multi-App Usage

### Shell V2

```dart
import 'package:buma_core_plus/buma_core_plus.dart';

class AuthRepositoryImpl {
  final RepositoryErrorHandler errorHandler;
  // Use error handler
}
```

### Admin Panel (Future App)

```dart
import 'package:buma_core_plus/buma_core_plus.dart';

class UserRepositoryImpl {
  final RepositoryErrorHandler errorHandler;
  // Same error handler, same pattern!
}
```

### Mobile App (Future App)

```dart
import 'package:buma_core_plus/buma_core_plus.dart';

class ProductRepositoryImpl {
  final RepositoryErrorHandler errorHandler;
  // Same error handler, consistent UX!
}
```

**All BUMA apps benefit from same error handling logic!** 🎉

---

## 🔧 Additional Methods

### Set User Identifier

```dart
// After sign in
await errorHandler.setUserIdentifier(user.id);

// All subsequent errors tagged with user ID
```

### Set Custom Data

```dart
await errorHandler.setCustomData({
  'environment': 'production',
  'appVersion': '1.0.0',
  'platform': Platform.operatingSystem,
});
```

### Clear User Data

```dart
// On sign out
await errorHandler.clearUserData();
```

---

## 🧪 Testing

### Mock Error Handler

```dart
class MockErrorHandler extends Mock implements RepositoryErrorHandler {}

void main() {
  test('repository handles errors', () async {
    final mockErrorHandler = MockErrorHandler();
    final repository = AuthRepositoryImpl(mockDataSource, mockErrorHandler);
    
    when(() => mockErrorHandler.execute(
      operation: any(named: 'operation'),
      feature: any(named: 'feature'),
      operationName: any(named: 'operationName'),
    )).thenAnswer((_) async => ValueGuard.failure(
      Failure(message: 'Test error'),
    ));
    
    final result = await repository.signOut();
    
    expect(result.isFailure, true);
  });
}
```

---

## 📈 Metrics

### Code Reduction

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Lines per method | ~15 | ~5 | **-67%** |
| Consistency | Different per repo | 100% | **Perfect** |
| Error reporting | Manual | Automatic | **Easy** |
| User messages | Technical | Friendly | **Professional** |

### Reusability

- ✅ One implementation for **ALL BUMA apps**
- ✅ Update once, **affect all apps**
- ✅ Standard pattern **across organization**

---

## 🎓 Best Practices

### ✅ DO

```dart
// DO: Use for all repository methods
return errorHandler.execute(...)

// DO: Add context for debugging
extras: {'userId': userId}

// DO: Force report critical operations
forceReport: true

// DO: Provide user-friendly messages
userMessageBuilder: (error) => 'Easy message'
```

### ❌ DON'T

```dart
// DON'T: Write manual try-catch
try { ... } catch (e) { }

// DON'T: Report all errors
shouldReport: (error) => true

// DON'T: Show technical errors
return Failure(message: error.toString())
```

---

## 📚 See Also

- [CrashReporterService](../infrastructure/analytics/contract/crash_reporter.service.dart) - Error reporting interface
- [ValueGuard](../foundation/domain/typedef/value_guard.typedef.dart) - Result type
- [ErrorHandlerHelper](error_handler.helper.dart) - Additional utilities
- [Failure](../foundation/domain/models/failure.model.dart) - Failure model

---

## ✅ Summary

**Key Features:**
- ✅ Dual-path error handling
- ✅ Smart filtering
- ✅ User-friendly messages
- ✅ Highly customizable
- ✅ Reusable across all apps
- ✅ 70% code reduction

**Location**: Part of `buma_core_plus` package

**Usage**: Import and inject via DI, then use in repositories

**Benefit**: Standard error handling for entire BUMA organization! 🎯

