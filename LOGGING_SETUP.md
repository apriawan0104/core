# Logging Setup Guide

## ✅ What's Been Added

Logging infrastructure dengan **Dependency Inversion Principle (DIP)** telah ditambahkan ke BUMA Core!

### 📁 File Structure

```
lib/src/infrastructure/logging/
├── contract/
│   ├── contracts.dart          # Barrel file untuk exports
│   └── log.service.dart        # Interface (STABLE - never changes!)
├── impl/
│   ├── impl.dart               # Barrel file untuk exports
│   ├── logger_package.service.impl.dart  # Logger package implementation
│   └── console_log.service.impl.dart     # Console implementation (zero deps)
├── constants/
│   ├── constants.dart          # Barrel file
│   └── log.constant.dart       # Logging constants
├── doc/
│   └── README.md               # Detailed documentation
└── logging.dart                # Main export (use this!)
```

### 📦 Files Created

1. **Contract (Interface)**
   - `log.service.dart` - Abstract class untuk logging service

2. **Implementations**
   - `logger_package.service.impl.dart` - Menggunakan [logger package](https://pub.dev/packages/logger)
   - `console_log.service.impl.dart` - Menggunakan Flutter debugPrint (zero dependencies)

3. **Constants**
   - `log.constant.dart` - Common constants untuk logging

4. **Documentation**
   - `doc/README.md` - Complete documentation
   - `example/logging_example.dart` - Usage examples

5. **Exports**
   - `logging.dart` - Main barrel file
   - `app_core.dart` - Updated untuk export logging

---

## 🚀 Quick Start

### 1. Import Package

```dart
import 'package:app_core/app_core.dart';
```

### 2. Register in DI Container

#### Option A: Logger Package (Recommended)

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Simple - just use defaults
getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl.defaultConfig(),
);
```

#### Option B: Console (Zero Dependencies)

```dart
getIt.registerLazySingleton<LogService>(
  () => const ConsoleLogServiceImpl(),
);
```

### 3. Use in Your Code

```dart
class UserRepository {
  final LogService _logService;

  UserRepository(this._logService);

  Future<User> getUser(String id) async {
    _logService.info('Fetching user', metadata: {'userId': id});

    try {
      final user = await api.getUser(id);
      _logService.debug('User fetched successfully');
      return user;
    } catch (e, st) {
      _logService.error('Failed to fetch user', error: e, stackTrace: st);
      rethrow;
    }
  }
}
```

---

## 🎯 Key Features

### ✅ Dependency Independent

Interface **TIDAK** expose third-party types. Ganti provider dengan ubah DI registration saja!

```dart
// Ganti dari logger package ke console
// HANYA ubah ini:
getIt.registerLazySingleton<LogService>(
  () => const ConsoleLogServiceImpl(),
);

// Business logic TIDAK perlu diubah! ✨
```

### ✅ Multiple Log Levels

- `trace()` - Very detailed debugging
- `debug()` - General debugging
- `info()` - Important events
- `warning()` - Potentially harmful
- `error()` - Errors (recoverable)
- `fatal()` - Critical errors (unrecoverable)

### ✅ Structured Logging

```dart
logService.info('User logged in', metadata: {
  LogConstants.keyUserId: user.id,
  LogConstants.keyUserEmail: user.email,
  'loginMethod': 'email_password',
});
```

### ✅ Easy to Test

```dart
class MockLogService implements LogService {
  final List<String> errorLogs = [];
  
  @override
  void error(String message, {...}) {
    errorLogs.add(message);
  }
  
  // ... implement other methods
}

// In test
final mock = MockLogService();
final repository = UserRepository(mock);

await repository.getUser('123');

expect(mock.errorLogs, isEmpty);
```

---

## 📚 Documentation

### Detailed Docs

Lihat [doc/README.md](lib/src/infrastructure/logging/doc/README.md) untuk:
- Complete API reference
- Advanced configuration
- Best practices
- Troubleshooting
- Common use cases

### Examples

Lihat [example/logging_example.dart](example/logging_example.dart) untuk:
- Setup examples
- Usage patterns
- Testing strategies

---

## 🔄 Switching Implementations

### From Console to Logger Package

**Before:**
```dart
getIt.registerLazySingleton<LogService>(
  () => const ConsoleLogServiceImpl(),
);
```

**After:**
```dart
getIt.registerLazySingleton<LogService>(
  () => LoggerPackageServiceImpl.defaultConfig(),
);
```

**That's it!** Tidak perlu ubah business logic! 🎉

---

## 🎨 Available Implementations

### 1. LoggerPackageServiceImpl

✅ **Pros:**
- Beautiful colored output
- Emojis for log levels  
- Pretty formatted stack traces
- Highly configurable

❌ **Cons:**
- Requires logger package dependency

**Best for:** Development, debugging

### 2. ConsoleLogServiceImpl

✅ **Pros:**
- Zero dependencies
- Lightweight
- Simple and fast
- Works everywhere

❌ **Cons:**
- No colored output
- Limited formatting
- Only logs in debug mode (default)

**Best for:** Production, CI/CD, testing

---

## 📊 Dependency Independence Checklist

✅ Interface tidak expose third-party types  
✅ Easy to create alternative implementations  
✅ Can switch providers in < 1 hour  
✅ Business logic tidak tahu tentang implementation  
✅ Testable tanpa real dependencies  

**Result:** Dependency independence achieved! 🎯

---

## 🔮 Future Implementations

Want to add more providers? Easy!

```dart
// Sentry implementation
class SentryLogServiceImpl implements LogService {
  @override
  void error(String message, {...}) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
  // ... implement other methods
}

// Firebase Crashlytics implementation
class CrashlyticsLogServiceImpl implements LogService {
  @override
  void error(String message, {...}) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  // ... implement other methods
}

// Register
getIt.registerLazySingleton<LogService>(
  () => SentryLogServiceImpl(),
);
```

No changes needed in business logic! ✨

---

## 📝 Best Practices

1. **Use appropriate log levels**
   - Don't log everything as error
   - Use trace/debug for development only

2. **Include metadata for context**
   - Use structured logging
   - Prefer metadata over string interpolation

3. **Always include stack traces for errors**
   ```dart
   try {
     // ...
   } catch (e, st) {
     logService.error('Failed', error: e, stackTrace: st);
   }
   ```

4. **Don't log sensitive information**
   - Never log passwords, tokens, personal data
   - Sanitize user input

5. **Use constants for common keys**
   ```dart
   logService.info('Action', metadata: {
     LogConstants.keyUserId: user.id,
     LogConstants.keyAction: 'submit',
   });
   ```

---

## 🆘 Need Help?

- Read [doc/README.md](lib/src/infrastructure/logging/doc/README.md) for complete documentation
- Check [example/logging_example.dart](example/logging_example.dart) for usage examples
- Look at existing implementations for reference

---

## ✅ Summary

Logging infrastructure sudah **READY TO USE**! 🎉

**Key Points:**
1. ✅ Mengikuti DIP - dependency independent
2. ✅ Easy to switch implementations
3. ✅ Well documented dengan examples
4. ✅ Testable dengan mock implementations
5. ✅ Multiple implementations tersedia (logger package & console)
6. ✅ Structured logging dengan metadata support
7. ✅ Zero breaking changes untuk consumer apps

**Next Steps:**
1. Register LogService di DI container consumer app
2. Inject LogService di services/repositories yang perlu logging
3. Start logging! 🚀

Selamat menggunakan! 🎯

