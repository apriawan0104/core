# Secure Storage - Quick Start Guide

Get up and running with Secure Storage in 5 minutes! 🚀

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Register in DI](#register-in-di)
3. [Basic Operations](#basic-operations)
4. [Platform Setup](#platform-setup)
5. [Common Patterns](#common-patterns)
6. [Next Steps](#next-steps)

## 1. Basic Setup

### Add Dependency

```yaml
# pubspec.yaml
dependencies:
  app_core: ^x.x.x
```

### Import

```dart
import 'package:app_core/app_core.dart';
```

## 2. Register in DI

### Using GetIt (Recommended)

```dart
// In your app's DI setup (e.g., di/locator.dart)
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register secure storage with balanced security options
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(
      options: SecureStorageOptions.balanced(),
    ),
  );
}
```

### Configuration Options

**Balanced (Recommended for most apps):**
```dart
SecureStorageOptions.balanced()
// - iOS/macOS: firstUnlock accessibility
// - Android: EncryptedSharedPreferences
// - No iCloud sync
```

**Maximum Security (For high-security apps):**
```dart
SecureStorageOptions.maximumSecurity()
// - iOS/macOS: unlocked accessibility (most secure)
// - Android: KeyStore with RSA+AES
// - No iCloud sync
```

**Custom Configuration:**
```dart
SecureStorageOptions(
  accessibility: KeychainAccessibility.firstUnlock,
  useEncryptedSharedPreferences: true,
  iCloudSync: false,
)
```

## 3. Basic Operations

### Write Data

```dart
final secureStorage = getIt<SecureStorageService>();

// Simple write
final result = await secureStorage.write(
  key: 'auth_token',
  value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);

// Handle result
result.fold(
  (failure) => print('Error: $failure'),
  (_) => print('Token saved successfully'),
);
```

### Read Data

```dart
final result = await secureStorage.read(key: 'auth_token');

result.fold(
  (failure) => print('Error: $failure'),
  (token) {
    if (token != null) {
      print('Token: $token');
      // Use token
    } else {
      print('Token not found');
    }
  },
);
```

### Check if Key Exists

```dart
final result = await secureStorage.containsKey(key: 'auth_token');

result.fold(
  (failure) => print('Error: $failure'),
  (exists) {
    if (exists) {
      print('Token exists');
    } else {
      print('Token not found');
    }
  },
);
```

### Delete Data

```dart
// Delete single key
await secureStorage.delete(key: 'auth_token');

// Delete all data (use with caution!)
await secureStorage.deleteAll();
```

### Get All Keys

```dart
final result = await secureStorage.getAllKeys();

result.fold(
  (failure) => print('Error: $failure'),
  (keys) => print('Stored keys: $keys'),
);
```

### Read All Data

```dart
final result = await secureStorage.readAll();

result.fold(
  (failure) => print('Error: $failure'),
  (allData) {
    print('Total items: ${allData.length}');
    allData.forEach((key, value) {
      print('$key: $value');
    });
  },
);
```

## 4. Platform Setup

### iOS (Required)

Edit `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.yourcompany.yourapp</string>
    </array>
</dict>
</plist>
```

### macOS (Required)

Add to both files:
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

```xml
<key>keychain-access-groups</key>
<array/>
```

### Android (Required)

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 18  // For KeyStore support
        // or
        minSdkVersion 23  // For EncryptedSharedPreferences
    }
}
```

### Linux

Install required libraries:

```bash
sudo apt-get install libsecret-1-dev libjsoncpp-dev
```

### Windows

No setup required. ✅

### Web

Enable HTTPS. That's it! ✅

## 5. Common Patterns

### Pattern 1: Authentication Flow

```dart
class AuthService {
  final SecureStorageService _secureStorage;
  
  AuthService(this._secureStorage);
  
  // Save token after login
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(
      key: SecureStorageConstants.authToken,
      value: token,
    );
  }
  
  // Get token for API calls
  Future<String?> getAuthToken() async {
    final result = await _secureStorage.read(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final result = await _secureStorage.containsKey(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }
  
  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(
      key: SecureStorageConstants.authToken,
    );
  }
}
```

### Pattern 2: Using Constants

```dart
// Use predefined constants for common keys
await secureStorage.write(
  key: SecureStorageConstants.authToken,
  value: token,
);

await secureStorage.write(
  key: SecureStorageConstants.refreshToken,
  value: refreshToken,
);

await secureStorage.write(
  key: SecureStorageConstants.userId,
  value: userId,
);

// Or build custom keys with prefixes
final customKey = SecureStorageConstants.buildAuthKey('custom_token');
await secureStorage.write(
  key: customKey,  // Results in 'auth_custom_token'
  value: value,
);
```

### Pattern 3: Batch Delete on Logout

```dart
Future<void> logout() async {
  // Delete all auth-related keys
  for (final key in SecureStorageConstants.authKeys) {
    await secureStorage.delete(key: key);
  }
  
  // Or delete ALL secure data
  // await secureStorage.deleteAll();
}
```

### Pattern 4: Safe Read with Default Value

```dart
Future<String> getAuthToken({String defaultToken = ''}) async {
  final result = await secureStorage.read(
    key: SecureStorageConstants.authToken,
  );
  
  return result.fold(
    (failure) {
      // Log error
      logger.error('Failed to read token: $failure');
      return defaultToken;
    },
    (token) => token ?? defaultToken,
  );
}
```

### Pattern 5: Retry Pattern for Platform Errors

```dart
Future<Either<SecureStorageFailure, String?>> readWithRetry({
  required String key,
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    final result = await secureStorage.read(key: key);
    
    // If success, return
    if (result.isRight()) {
      return result;
    }
    
    // If error is not recoverable, return failure
    final failure = result.fold((f) => f, (_) => null);
    if (failure is SecureStorageInvalidKeyFailure ||
        failure is SecureStorageKeyNotFoundFailure) {
      return result;
    }
    
    // Wait before retry
    if (i < maxRetries - 1) {
      await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
    }
  }
  
  return await secureStorage.read(key: key);
}
```

## 6. Next Steps

### ✅ You're Ready!

You now know how to:
- ✅ Register secure storage in DI
- ✅ Write, read, and delete secure data
- ✅ Setup platform-specific configurations
- ✅ Use common patterns

### 📚 Learn More

- [README.md](README.md) - Complete documentation with security considerations
- [USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) - Advanced usage examples and patterns
- Check out constants: `SecureStorageConstants`
- Explore failure types: `SecureStorageFailure`
- Read about options: `SecureStorageOptions`, `KeychainAccessibility`

### 🎯 Best Practices to Follow

1. **Always handle failures** - Don't ignore the Either result
2. **Use constants for keys** - Avoid string literals
3. **Choose consistent encryption mode** on Android
4. **Delete sensitive data on logout**
5. **Use appropriate accessibility level** for your use case

### ⚠️ Common Mistakes to Avoid

1. ❌ Storing non-sensitive data (use regular storage instead)
2. ❌ Mixing Android encryption modes
3. ❌ Ignoring platform-specific setup (especially iOS entitlements)
4. ❌ Using string literals for keys
5. ❌ Not handling failures properly

## 💬 Need Help?

If you encounter issues:

1. Check [Troubleshooting section in README.md](README.md#troubleshooting)
2. Review [Platform-Specific Setup in README.md](README.md#platform-specific-setup)
3. See [USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) for more examples

Happy coding! 🎉

