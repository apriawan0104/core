# Logging Infrastructure

Dependency-independent logging service for BUMA Core.

## 🎯 Overview

The logging infrastructure provides a standardized way to log messages across different logging implementations. The design follows the **Dependency Inversion Principle (DIP)**, allowing you to easily switch between logging providers without changing your business logic.

## 🏗️ Architecture

```
logging/
├── contract/           # Abstract interfaces (stable, never changes)
│   └── log.service.dart
├── impl/              # Concrete implementations (can be added/removed)
│   ├── logger_package.service.impl.dart  # Using logger package
│   └── console_log.service.impl.dart     # Using debugPrint
├── constants/         # Configuration constants
│   └── log.constant.dart
└── doc/
    └── README.md      # This file
```

### Dependency Flow

```
Your App (Business Logic)
      ↓ depends on
  LogService (Interface) ← STABLE, never changes
      ↑ implemented by
Implementation (logger package, console, Sentry, etc.)
```

## 🚀 Quick Start

### 1. Add Dependency (Optional)

If using `LoggerPackageServiceImpl`:

```yaml
# pubspec.yaml
dependencies:
  logger: ^2.6.2
```

If using `ConsoleLogServiceImpl`, no dependency needed!

### 2. Register in DI Container

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLogging() {
  // Option A: Using logger package (recommended for development)
  getIt.registerLazySingleton<LogService>(
    () => LoggerPackageServiceImpl.defaultConfig(),
  );

  // Option B: Using simple console (zero dependencies)
  // getIt.registerLazySingleton<LogService>(
  //   () => ConsoleLogServiceImpl(),
  // );
}
```

### 3. Use in Your Code

```dart
class UserRepository {
  final LogService _logService;
  final ApiService _apiService;

  UserRepository(this._logService, this._apiService);

  Future<User> getUserProfile(String userId) async {
    _logService.info('Fetching user profile', metadata: {
      'userId': userId,
    });

    try {
      final response = await _apiService.get('/users/$userId');
      
      _logService.debug('User profile fetched successfully', metadata: {
        'userId': userId,
        'responseTime': response.duration,
      });

      return User.fromJson(response.data);
    } catch (e, st) {
      _logService.error(
        'Failed to fetch user profile',
        error: e,
        stackTrace: st,
        metadata: {
          'userId': userId,
          'endpoint': '/users/$userId',
        },
      );
      rethrow;
    }
  }
}
```

## 📊 Log Levels

### When to Use Each Level

| Level   | When to Use | Example |
|---------|-------------|---------|
| `trace` | Very detailed debugging, function entry/exit | `logService.trace('Entered getUserProfile method')` |
| `debug` | General debugging information | `logService.debug('API response received', metadata: {...})` |
| `info`  | Important application events | `logService.info('User logged in successfully')` |
| `warning` | Potentially harmful situations | `logService.warning('API response is slow', metadata: {'duration': '5s'})` |
| `error` | Error events (recoverable) | `logService.error('Failed to fetch data', error: e, stackTrace: st)` |
| `fatal` | Critical errors (unrecoverable) | `logService.fatal('Database connection lost', error: e, stackTrace: st)` |

## 🎨 Available Implementations

### 1. LoggerPackageServiceImpl

Uses the [logger package](https://pub.dev/packages/logger) for beautiful, colorful console logs.

**Features:**
- ✅ Colored output
- ✅ Emojis for log levels
- ✅ Pretty formatted stack traces
- ✅ Configurable formatting
- ✅ Method call stack traces

**Usage:**

```dart
// Default configuration (recommended)
getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl.defaultConfig(),
);

// Simple configuration (no colors, useful for CI/CD)
getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl.simpleConfig(),
);

// Custom configuration
import 'package:logger/logger.dart' as logger_pkg;

getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl(
    logger: logger_pkg.Logger(
      level: logger_pkg.Level.debug,
      printer: logger_pkg.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
      ),
    ),
  ),
);

// With custom filter
getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl.withFilter(
    level: logger_pkg.Level.warning, // Only show warnings and above
  ),
);
```

### 2. ConsoleLogServiceImpl

Simple console logging using Flutter's `debugPrint`.

**Features:**
- ✅ Zero dependencies
- ✅ Lightweight
- ✅ Simple and fast
- ✅ Works everywhere

**Limitations:**
- ❌ No colored output
- ❌ Limited formatting
- ❌ Only logs in debug mode (by default)

**Usage:**

```dart
// Default (only logs in debug mode)
getIt.registerLazySingleton<LogService>(
  () => ConsoleLogServiceImpl(),
);

// Log in production too
getIt.registerLazySingleton<LogService>(
  () => ConsoleLogServiceImpl(logInProduction: true),
);

// Without timestamps
getIt.registerLazySingleton<LogService>(
  () => ConsoleLogServiceImpl(includeTimestamp: false),
);
```

## 🔄 Switching Implementations

One of the key benefits of DIP: you can switch logging providers by changing ONLY the DI registration!

```dart
// Development: Pretty logs with logger package
if (kDebugMode) {
  getIt.registerLazySingleton<LogService>(
    () => LoggerPackageServiceImpl.defaultConfig(),
  );
} else {
  // Production: Simple console logs
  getIt.registerLazySingleton<LogService>(
    () => ConsoleLogServiceImpl(logInProduction: true),
  );
}
```

**No changes needed in:**
- ❌ Business logic
- ❌ Repositories
- ❌ Use cases
- ❌ UI widgets
- ❌ Tests

## 🧪 Testing

Create a mock implementation for testing:

```dart
class MockLogService implements LogService {
  final List<String> traceLogs = [];
  final List<String> debugLogs = [];
  final List<String> infoLogs = [];
  final List<String> warningLogs = [];
  final List<String> errorLogs = [];
  final List<String> fatalLogs = [];

  @override
  void trace(String message, {Map<String, dynamic>? metadata}) {
    traceLogs.add(message);
  }

  @override
  void debug(String message, {Map<String, dynamic>? metadata}) {
    debugLogs.add(message);
  }

  @override
  void info(String message, {Map<String, dynamic>? metadata}) {
    infoLogs.add(message);
  }

  @override
  void warning(String message, {Map<String, dynamic>? metadata}) {
    warningLogs.add(message);
  }

  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    errorLogs.add(message);
  }

  @override
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    fatalLogs.add(message);
  }

  @override
  void close() {}

  void reset() {
    traceLogs.clear();
    debugLogs.clear();
    infoLogs.clear();
    warningLogs.clear();
    errorLogs.clear();
    fatalLogs.clear();
  }
}

// In your test
void main() {
  late MockLogService mockLogService;
  late UserRepository repository;

  setUp(() {
    mockLogService = MockLogService();
    repository = UserRepository(mockLogService, mockApiService);
  });

  test('should log error when API fails', () async {
    // Arrange
    when(() => mockApiService.get(any())).thenThrow(Exception('Network error'));

    // Act
    try {
      await repository.getUserProfile('123');
    } catch (_) {}

    // Assert
    expect(mockLogService.errorLogs, isNotEmpty);
    expect(mockLogService.errorLogs.first, contains('Failed to fetch user profile'));
  });
}
```

## 📝 Best Practices

### 1. Use Appropriate Log Levels

```dart
// ❌ BAD: Everything as error
logService.error('Button clicked');
logService.error('API call started');

// ✅ GOOD: Use appropriate levels
logService.debug('Button clicked');
logService.info('API call started');
logService.error('API call failed', error: e, stackTrace: st);
```

### 2. Include Metadata for Context

```dart
// ❌ BAD: String interpolation only
logService.info('User logged in: ${user.email}');

// ✅ GOOD: Use metadata for structured logging
logService.info('User logged in', metadata: {
  'userId': user.id,
  'email': user.email,
  'loginMethod': 'email_password',
  'timestamp': DateTime.now().toIso8601String(),
});
```

### 3. Always Include Stack Traces for Errors

```dart
// ❌ BAD: Missing stack trace
try {
  await dangerousOperation();
} catch (e) {
  logService.error('Operation failed', error: e);
}

// ✅ GOOD: Include stack trace
try {
  await dangerousOperation();
} catch (e, st) {
  logService.error('Operation failed', error: e, stackTrace: st);
}
```

### 4. Don't Log Sensitive Information

```dart
// ❌ BAD: Logging passwords and tokens
logService.debug('Login attempt', metadata: {
  'email': email,
  'password': password, // NEVER log passwords!
});

// ✅ GOOD: Sanitize sensitive data
logService.debug('Login attempt', metadata: {
  'email': email,
  // Don't include password
});
```

### 5. Use Constants for Common Keys

```dart
import 'package:app_core/app_core.dart';

// ✅ GOOD: Use constants
logService.info('User action', metadata: {
  LogConstants.keyUserId: user.id,
  LogConstants.keyScreenName: 'home',
  LogConstants.keyAction: 'button_click',
});
```

## 🔮 Creating Custom Implementations

Want to use Sentry, Firebase Crashlytics, or your own backend?

```dart
// 1. Implement the interface
class SentryLogServiceImpl implements LogService {
  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    Sentry.captureException(
      error ?? message,
      stackTrace: stackTrace,
      hint: Hint.withMap(metadata ?? {}),
    );
  }

  @override
  void fatal(
    String message, {
    required dynamic error,
    required StackTrace stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap(metadata ?? {}),
      withScope: (scope) {
        scope.level = SentryLevel.fatal;
      },
    );
  }

  // ... implement other methods
}

// 2. Register in DI
getIt.registerLazySingleton<LogService>(
  () => SentryLogServiceImpl(),
);

// 3. Done! No changes needed anywhere else
```

## 🎯 Dependency Independence Checklist

✅ **Interface (contract) does NOT expose third-party types**
- `LogService` has no `Logger` or `Sentry` types

✅ **Easy to create alternative implementations**
- Just implement `LogService` interface

✅ **Can switch implementations in < 1 hour**
- Change DI registration only

✅ **Business logic doesn't know about implementation**
- Code uses `LogService`, not `LoggerPackageServiceImpl`

✅ **Testable without real dependencies**
- Easy to create `MockLogService`

## 📚 Related

- [Notification Infrastructure](../notification/doc/README.md)
- [Responsive Infrastructure](../responsive/doc/README.md)

## 💡 Common Use Cases

### Use Case 1: API Request Logging

```dart
class ApiService {
  final LogService _logService;

  Future<Response> get(String endpoint) async {
    final startTime = DateTime.now();
    
    _logService.debug('API request started', metadata: {
      LogConstants.keyEndpoint: endpoint,
      LogConstants.keyMethod: 'GET',
    });

    try {
      final response = await _httpClient.get(endpoint);
      final duration = DateTime.now().difference(startTime);

      _logService.info('API request completed', metadata: {
        LogConstants.keyEndpoint: endpoint,
        LogConstants.keyMethod: 'GET',
        LogConstants.keyStatusCode: response.statusCode,
        LogConstants.keyDuration: '${duration.inMilliseconds}ms',
      });

      return response;
    } catch (e, st) {
      _logService.error(
        'API request failed',
        error: e,
        stackTrace: st,
        metadata: {
          LogConstants.keyEndpoint: endpoint,
          LogConstants.keyMethod: 'GET',
        },
      );
      rethrow;
    }
  }
}
```

### Use Case 2: User Action Tracking

```dart
class HomeScreen extends StatelessWidget {
  final LogService _logService;

  void _onButtonPressed() {
    _logService.info('User action', metadata: {
      LogConstants.keyScreenName: 'home',
      LogConstants.keyAction: 'submit_button_pressed',
      LogConstants.keyUserId: currentUser.id,
      LogConstants.keyTimestamp: DateTime.now().toIso8601String(),
    });

    // Handle button press
  }
}
```

### Use Case 3: Background Task Monitoring

```dart
class SyncService {
  final LogService _logService;

  Future<void> syncData() async {
    _logService.info('Background sync started');

    try {
      final result = await performSync();
      
      _logService.info('Background sync completed', metadata: {
        'itemsSynced': result.itemCount,
        'duration': result.duration.toString(),
      });
    } catch (e, st) {
      _logService.fatal(
        'Background sync failed critically',
        error: e,
        stackTrace: st,
        metadata: {
          'lastSuccessfulSync': lastSyncTime.toIso8601String(),
        },
      );
    }
  }
}
```

## 🆘 Troubleshooting

### Issue: No logs appearing

**Solution:**
- Check if you're in release mode with `ConsoleLogServiceImpl` (default only logs in debug)
- Set `logInProduction: true` if needed
- Verify DI registration is correct

### Issue: Colors not working on iOS/macOS

**Solution:**
- This is a known Flutter issue with ANSI escape sequences
- Use `simpleConfig()` or set `colors: false`
- Or use JetBrains IDE with Grep Console plugin

### Issue: Too verbose logging

**Solution:**
```dart
// Set minimum log level
LoggerPackageServiceImpl.withFilter(
  level: logger_pkg.Level.warning, // Only show warnings and above
)
```

---

**Remember**: The interface (`LogService`) is STABLE and never changes. Only implementations can be added, removed, or modified! 🎯

