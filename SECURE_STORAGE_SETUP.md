# Secure Storage Setup Guide

This guide will help you set up and use the Secure Storage service in your Flutter app.

## 📋 Table of Contents

1. [Installation](#installation)
2. [Platform Setup](#platform-setup)
3. [Basic Setup](#basic-setup)
4. [Usage](#usage)
5. [Examples](#examples)
6. [Documentation](#documentation)

## 🚀 Installation

### 1. Add Dependency

```yaml
dependencies:
  app_core: ^x.x.x
```

### 2. Install

```bash
flutter pub get
```

## 🔧 Platform Setup

### iOS Setup (Required)

1. **Add Keychain Entitlements**

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

Replace `com.yourcompany.yourapp` with your app's bundle identifier.

### macOS Setup (Required)

Add to **both** files:
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

```xml
<key>keychain-access-groups</key>
<array/>
```

### Android Setup (Required)

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // For KeyStore support (API 18+)
        minSdkVersion 18
        
        // Or for EncryptedSharedPreferences (API 23+, recommended)
        minSdkVersion 23
    }
}
```

**Optional but Recommended**: Disable auto backup or exclude secure storage

In `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:allowBackup="false"
    android:fullBackupContent="false">
    <!-- ... -->
</application>
```

### Linux Setup

Install required libraries:

```bash
# Ubuntu/Debian
sudo apt-get install libsecret-1-dev libjsoncpp-dev

# Fedora
sudo dnf install libsecret-devel jsoncpp-devel
```

### Windows Setup

No setup required ✅

### Web Setup

1. Enable HTTPS
2. Add HSTS headers (recommended)

## 🎯 Basic Setup

### 1. Register in Dependency Injection

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupSecureStorage() {
  // Register with balanced security (recommended)
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(
      options: SecureStorageOptions.balanced(),
    ),
  );
}
```

### 2. Configuration Options

**Balanced (Recommended):**
```dart
SecureStorageOptions.balanced()
// - iOS/macOS: firstUnlock accessibility
// - Android: EncryptedSharedPreferences
// - No iCloud sync
```

**Maximum Security:**
```dart
SecureStorageOptions.maximumSecurity()
// - iOS/macOS: unlocked accessibility
// - Android: KeyStore with RSA+AES
// - No iCloud sync
```

**Custom:**
```dart
SecureStorageOptions(
  accessibility: KeychainAccessibility.firstUnlock,
  useEncryptedSharedPreferences: true,
  iCloudSync: false,
)
```

## 💻 Usage

### Basic Operations

```dart
import 'package:app_core/app_core.dart';

final secureStorage = getIt<SecureStorageService>();

// Write
await secureStorage.write(
  key: 'auth_token',
  value: 'your_token_here',
);

// Read
final result = await secureStorage.read(key: 'auth_token');
result.fold(
  (failure) => print('Error: $failure'),
  (token) => print('Token: $token'),
);

// Check if exists
final exists = await secureStorage.containsKey(key: 'auth_token');

// Delete
await secureStorage.delete(key: 'auth_token');

// Delete all
await secureStorage.deleteAll();
```

### Using Constants

```dart
// Use predefined constants
await secureStorage.write(
  key: SecureStorageConstants.authToken,
  value: token,
);

await secureStorage.write(
  key: SecureStorageConstants.refreshToken,
  value: refreshToken,
);

// Build custom keys
final customKey = SecureStorageConstants.buildAuthKey('custom');
await secureStorage.write(key: customKey, value: value);
```

### Authentication Example

```dart
class AuthService {
  final SecureStorageService _secureStorage;
  
  AuthService(this._secureStorage);
  
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(
      key: SecureStorageConstants.authToken,
      value: token,
    );
  }
  
  Future<String?> getAuthToken() async {
    final result = await _secureStorage.read(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }
  
  Future<bool> isLoggedIn() async {
    final result = await _secureStorage.containsKey(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }
  
  Future<void> logout() async {
    // Delete all auth keys
    for (final key in SecureStorageConstants.authKeys) {
      await _secureStorage.delete(key: key);
    }
  }
}
```

## 📚 Examples

### Example 1: Save User Credentials

```dart
Future<void> saveCredentials(String username, String password) async {
  await secureStorage.write(
    key: 'username',
    value: username,
  );
  
  await secureStorage.write(
    key: 'password',
    value: password,
  );
}
```

### Example 2: Get All Stored Keys

```dart
Future<void> listStoredKeys() async {
  final result = await secureStorage.getAllKeys();
  
  result.fold(
    (failure) => print('Error: $failure'),
    (keys) => print('Stored keys: $keys'),
  );
}
```

### Example 3: Platform-Specific Options

```dart
// iOS: Save with specific accessibility
await secureStorage.write(
  key: 'sensitive_data',
  value: 'data',
  options: SecureStorageOptions(
    accessibility: KeychainAccessibility.unlocked,
  ),
);

// Android: Use EncryptedSharedPreferences
await secureStorage.write(
  key: 'data',
  value: 'value',
  options: SecureStorageOptions(
    useEncryptedSharedPreferences: true,
  ),
);
```

### Example 4: Error Handling

```dart
Future<void> readWithErrorHandling() async {
  final result = await secureStorage.read(key: 'token');
  
  result.fold(
    (failure) {
      if (failure is SecureStorageKeyNotFoundFailure) {
        // Key not found
        navigateToLogin();
      } else if (failure is SecureStorageAccessDeniedFailure) {
        // Access denied
        showPermissionDialog();
      } else {
        // Other error
        showErrorDialog(failure.message);
      }
    },
    (token) {
      if (token != null) {
        useToken(token);
      }
    },
  );
}
```

## 📖 Documentation

For more detailed information:

- **Quick Start**: [lib/src/infrastructure/secure_storage/doc/QUICK_START.md](lib/src/infrastructure/secure_storage/doc/QUICK_START.md)
- **Complete Guide**: [lib/src/infrastructure/secure_storage/doc/README.md](lib/src/infrastructure/secure_storage/doc/README.md)
- **Usage Examples**: [lib/src/infrastructure/secure_storage/doc/USAGE_EXAMPLE.md](lib/src/infrastructure/secure_storage/doc/USAGE_EXAMPLE.md)
- **Example Code**: [example/secure_storage_example.dart](example/secure_storage_example.dart)

## ⚠️ Important Notes

### Android: Don't Mix Encryption Modes

**Important**: Choose one encryption method and use it consistently!

```dart
// ✅ GOOD: Use one method for all operations
final storage = FlutterSecureStorageServiceImpl(
  options: SecureStorageOptions(
    useEncryptedSharedPreferences: true, // or false
  ),
);

// ❌ BAD: Mixing both will cause errors!
await storage.write(
  key: 'key1',
  options: SecureStorageOptions(useEncryptedSharedPreferences: true),
);
await storage.write(
  key: 'key2',
  options: SecureStorageOptions(useEncryptedSharedPreferences: false),
);
```

### When to Use Secure Storage

**✅ Use Secure Storage For:**
- Authentication tokens (JWT, OAuth)
- API keys
- User passwords/PINs
- Encryption keys
- Sensitive user data

**❌ Don't Use Secure Storage For:**
- App settings
- User preferences
- Cache data
- Large datasets
- Non-sensitive data

### Security Best Practices

1. **Always handle failures** - Don't ignore error results
2. **Use constants for keys** - Avoid string literals
3. **Delete on logout** - Clear sensitive data
4. **Choose appropriate accessibility** - Balance security vs usability
5. **Don't log sensitive values** - Be careful in production

## 🐛 Troubleshooting

### iOS: "Keychain access denied"

**Solution**: Add keychain entitlements to `Runner.entitlements`

### Android: "Failed to unwrap key"

**Solution**: You're mixing EncryptedSharedPreferences and KeyStore. Pick one and use consistently.

### Linux: "org.freedesktop.secrets was not provided"

**Solution**: Install libsecret: `sudo apt-get install libsecret-1-0`

### Web: "SecurityError: The operation is insecure"

**Solution**: Enable HTTPS for your web server

## 🎓 Learn More

- [flutter_secure_storage package](https://pub.dev/packages/flutter_secure_storage)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Android KeyStore](https://developer.android.com/training/articles/keystore)

## 🚀 Quick Start Checklist

- [ ] Add dependency to `pubspec.yaml`
- [ ] Setup platform-specific configurations (iOS/macOS entitlements, Android minSdk)
- [ ] Register service in DI
- [ ] Import and use in your code
- [ ] Test on target platforms

## 💬 Need Help?

If you encounter issues:
1. Check the complete documentation in `lib/src/infrastructure/secure_storage/doc/`
2. Review the example code in `example/secure_storage_example.dart`
3. Read the troubleshooting section above

---

**That's it!** You're ready to use Secure Storage in your app. 🎉

