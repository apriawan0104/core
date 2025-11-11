# Secure Storage Service

Platform-agnostic secure storage service for storing sensitive data in Flutter applications.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Platform Support](#platform-support)
- [Architecture](#architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Security Considerations](#security-considerations)
- [Platform-Specific Setup](#platform-specific-setup)
- [Troubleshooting](#troubleshooting)
- [Migration Guide](#migration-guide)

## 🎯 Overview

The Secure Storage Service provides a **platform-independent** interface for storing sensitive data securely. It uses platform-specific secure storage mechanisms:

- **iOS/macOS**: Keychain
- **Android**: KeyStore (or EncryptedSharedPreferences)
- **Linux**: libsecret
- **Windows**: Credential Manager
- **Web**: WebCrypto (experimental)

### Why Use Secure Storage?

**✅ DO Use Secure Storage For:**
- Authentication tokens (JWT, OAuth, etc.)
- API keys and secrets
- User credentials (passwords, PINs)
- Encryption keys
- Sensitive user data (SSN, credit cards, etc.)
- Biometric authentication keys
- Session tokens

**❌ DON'T Use Secure Storage For:**
- Non-sensitive app settings
- User preferences
- Cache data
- Large datasets (use regular storage instead)
- Frequently accessed data (performance overhead)

## ✨ Features

- ✅ **Platform Independent**: Works on iOS, Android, Linux, macOS, Windows, and Web
- ✅ **Type Safe**: Strong typing with Either<Failure, Success> pattern
- ✅ **Secure by Default**: Uses platform-specific secure storage mechanisms
- ✅ **Dependency Independent**: Easy to swap implementations
- ✅ **Testable**: Mock-friendly design with clear interfaces
- ✅ **Well Documented**: Comprehensive documentation and examples
- ✅ **Error Handling**: Detailed error types for all failure scenarios
- ✅ **Configurable**: Platform-specific options (iOS accessibility, Android encryption mode)

## 🖥️ Platform Support

| Platform | Storage Mechanism | Min SDK/OS |
|----------|------------------|------------|
| iOS | Keychain | iOS 9.0+ |
| macOS | Keychain | macOS 10.11+ |
| Android | KeyStore / EncryptedSharedPreferences | API 18+ / API 23+ |
| Linux | libsecret | - |
| Windows | Credential Manager | Windows 7+ |
| Web | WebCrypto (experimental) | Modern browsers |

## 🏗️ Architecture

This service follows the **Dependency Inversion Principle**:

```
┌─────────────────────────────────────┐
│   Your App (Business Logic)        │
└─────────────┬───────────────────────┘
              │ depends on
              ▼
┌─────────────────────────────────────┐
│  SecureStorageService (Interface)   │  ← Our abstraction
└─────────────┬───────────────────────┘
              │ implemented by
              ▼
┌─────────────────────────────────────┐
│ FlutterSecureStorageServiceImpl     │  ← Implementation
└─────────────┬───────────────────────┘
              │ uses
              ▼
┌─────────────────────────────────────┐
│   flutter_secure_storage package    │  ← Third-party
└─────────────────────────────────────┘
```

**Key Points:**
- Your app depends on the **interface**, not the implementation
- Easy to swap implementations (e.g., switch to different package)
- Easy to mock for testing
- No third-party types exposed in your business logic

## 📦 Installation

### 1. Add to pubspec.yaml

```yaml
dependencies:
  app_core: ^x.x.x  # This package
  
  # flutter_secure_storage is already included as dependency
  # No need to add it manually
```

### 2. Platform-Specific Setup

See [Platform-Specific Setup](#platform-specific-setup) section below.

## 🚀 Quick Start

See [QUICK_START.md](QUICK_START.md) for detailed quick start guide.

### Basic Usage

```dart
import 'package:app_core/app_core.dart';

// 1. Register in DI (in your app's DI setup)
getIt.registerLazySingleton<SecureStorageService>(
  () => FlutterSecureStorageServiceImpl(
    options: SecureStorageOptions.balanced(),
  ),
);

// 2. Use in your app
final secureStorage = getIt<SecureStorageService>();

// Write secure data
await secureStorage.write(
  key: 'auth_token',
  value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);

// Read secure data
final result = await secureStorage.read(key: 'auth_token');
result.fold(
  (failure) => print('Error: $failure'),
  (token) => print('Token: $token'),
);

// Delete secure data
await secureStorage.delete(key: 'auth_token');
```

## 📖 Usage Examples

See [USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) for comprehensive usage examples.

### Common Use Cases

#### 1. Storing Authentication Tokens

```dart
// Save token after login
final saveResult = await secureStorage.write(
  key: SecureStorageConstants.authToken,
  value: authResponse.token,
  options: SecureStorageOptions(
    accessibility: KeychainAccessibility.firstUnlock,
  ),
);

// Read token for API calls
final tokenResult = await secureStorage.read(
  key: SecureStorageConstants.authToken,
);

final token = tokenResult.fold(
  (failure) => null,
  (value) => value,
);

if (token != null) {
  // Use token in API request
}
```

#### 2. Check if User is Logged In

```dart
final isLoggedIn = await secureStorage.containsKey(
  key: SecureStorageConstants.authToken,
);

isLoggedIn.fold(
  (failure) => navigateToLogin(),
  (exists) {
    if (exists) {
      navigateToHome();
    } else {
      navigateToLogin();
    }
  },
);
```

#### 3. Logout (Clear All Secure Data)

```dart
Future<void> logout() async {
  // Delete all secure data
  await secureStorage.deleteAll();
  
  // Navigate to login
  navigateToLogin();
}
```

## 🎯 Best Practices

### 1. Use Constants for Keys

**✅ Good:**
```dart
await secureStorage.write(
  key: SecureStorageConstants.authToken,
  value: token,
);
```

**❌ Bad:**
```dart
await secureStorage.write(
  key: 'auth_token',  // String literal - prone to typos
  value: token,
);
```

### 2. Always Handle Failures

**✅ Good:**
```dart
final result = await secureStorage.read(key: 'token');
result.fold(
  (failure) {
    // Handle error
    logger.error('Failed to read token: $failure');
    navigateToLogin();
  },
  (token) {
    // Use token
    if (token != null) {
      useToken(token);
    }
  },
);
```

**❌ Bad:**
```dart
final result = await secureStorage.read(key: 'token');
final token = result.getOrElse(() => null);  // Ignoring failures!
```

### 3. Use Appropriate Accessibility Level

**For Most Apps** (Recommended):
```dart
SecureStorageOptions(
  accessibility: KeychainAccessibility.firstUnlock,
)
```

**For High Security Apps**:
```dart
SecureStorageOptions(
  accessibility: KeychainAccessibility.unlocked,
)
```

**For Development Only**:
```dart
SecureStorageOptions(
  accessibility: KeychainAccessibility.always,  // Deprecated, not secure!
)
```

### 4. Consistent Android Encryption Mode

**✅ Good (Pick One and Stick With It):**
```dart
// Option A: Use EncryptedSharedPreferences for all operations
final storage = FlutterSecureStorageServiceImpl(
  options: SecureStorageOptions(
    useEncryptedSharedPreferences: true,
  ),
);

// Option B: Use KeyStore for all operations (default)
final storage = FlutterSecureStorageServiceImpl(
  options: SecureStorageOptions(
    useEncryptedSharedPreferences: false,
  ),
);
```

**❌ Bad (Mixing Both):**
```dart
// This will cause errors!
await storage.write(
  key: 'key1',
  value: 'value1',
  options: SecureStorageOptions(useEncryptedSharedPreferences: true),
);

await storage.write(
  key: 'key2',
  value: 'value2',
  options: SecureStorageOptions(useEncryptedSharedPreferences: false),
);
```

### 5. Delete Sensitive Data on Logout

```dart
Future<void> logout() async {
  // Delete all auth-related keys
  for (final key in SecureStorageConstants.authKeys) {
    await secureStorage.delete(key: key);
  }
  
  // Or delete everything
  await secureStorage.deleteAll();
}
```

## 🔒 Security Considerations

### iOS/macOS Keychain

**Data Persistence:**
- Data persists across app uninstalls (unless using `ThisDeviceOnly` variants)
- Data can sync via iCloud (if `iCloudSync: true`)
- Data is encrypted at rest

**Accessibility Levels:**
- `unlocked`: Most secure, only accessible when device is unlocked
- `firstUnlock`: Accessible after first unlock (recommended for tokens)
- `always`: Least secure, not recommended

**Recommendations:**
- Use `firstUnlock` for auth tokens (allows background operations)
- Use `unlocked` for highly sensitive data (requires device unlock)
- Use `ThisDeviceOnly` variants to prevent iCloud backup
- Set `iCloudSync: false` for device-specific secrets

### Android KeyStore vs EncryptedSharedPreferences

**KeyStore (Traditional)**
- Available on Android 4.3+ (API 18)
- Uses RSA + AES encryption
- More complex but more control
- Data persists across app uninstalls

**EncryptedSharedPreferences (Modern)**
- Available on Android 6.0+ (API 23)
- Simpler encryption model
- Easier to use
- Better compatibility
- Data deleted on app uninstall

**Recommendations:**
- Use EncryptedSharedPreferences for new apps (API 23+)
- Use KeyStore only if you need API 18-22 support
- **Never mix both** in the same app!

### Linux

**Requirements:**
- Requires `libsecret-1-dev` (build time)
- Requires `libsecret-1-0` (runtime)
- Data stored in GNOME Keyring or KWallet

### Windows

- Uses Windows Credential Manager
- Data encrypted with user's Windows credentials
- Data persists across app uninstalls

### Web (Experimental)

**⚠️ WARNING**: Web implementation is experimental!

**Requirements:**
- HTTPS required (WebCrypto only works on secure contexts)
- HTTP Strict Transport Security (HSTS) strongly recommended
- Modern browser with WebCrypto support

**Limitations:**
- Private key stored in browser's localStorage
- Not portable across browsers or devices
- Domain-specific (doesn't work cross-domain)
- Can be cleared by user (clear browser data)

**Recommendations:**
- Enable HSTS headers
- Use only for non-critical data on web
- Have fallback authentication mechanism
- Don't rely solely on web secure storage

## 🔧 Platform-Specific Setup

### iOS

1. **Add Keychain Entitlements** (Required)

Edit `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Add this for keychain access -->
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.yourcompany.yourapp</string>
    </array>
</dict>
</plist>
```

2. **Enable Keychain Sharing** (if sharing between apps)

In Xcode:
- Select your project
- Go to "Signing & Capabilities"
- Click "+ Capability"
- Add "Keychain Sharing"

### macOS

Same as iOS - add keychain entitlements to both:
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

```xml
<key>keychain-access-groups</key>
<array/>
```

### Android

1. **Set Minimum SDK**

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 18  // For KeyStore
        // or
        minSdkVersion 23  // For EncryptedSharedPreferences
    }
}
```

2. **Disable Auto Backup** (Recommended)

In `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:allowBackup="false"
    android:fullBackupContent="false">
    <!-- ... -->
</application>
```

Or exclude secure storage from backup:

```xml
<application
    android:fullBackupContent="@xml/backup_rules">
    <!-- ... -->
</application>
```

Create `android/app/src/main/res/xml/backup_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="FlutterSecureStorage"/>
</full-backup-content>
```

### Linux

Install required libraries:

**Ubuntu/Debian:**
```bash
sudo apt-get install libsecret-1-dev libjsoncpp-dev
```

**Fedora:**
```bash
sudo dnf install libsecret-devel jsoncpp-devel
```

### Windows

No special setup required. Uses Windows Credential Manager.

### Web

1. **Enable HTTPS**
2. **Add HSTS Headers** (Recommended)

In your server configuration, add:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

## 🐛 Troubleshooting

### iOS: "Keychain access denied"

**Cause**: Missing keychain entitlements

**Solution**: Add keychain access groups to `Runner.entitlements` (see iOS setup above)

### Android: "Failed to unwrap key"

**Cause**: Mixed use of EncryptedSharedPreferences and KeyStore

**Solution**: 
1. Choose one encryption method
2. Use it consistently across all operations
3. Clear app data or reinstall if mixed data exists

```dart
// Pick one and use everywhere:
final storage = FlutterSecureStorageServiceImpl(
  options: SecureStorageOptions(
    useEncryptedSharedPreferences: true,  // or false
  ),
);
```

### Linux: "org.freedesktop.secrets was not provided"

**Cause**: libsecret not installed or keyring service not running

**Solution**:
1. Install libsecret: `sudo apt-get install libsecret-1-0`
2. Ensure keyring service is running

### Web: "SecurityError: The operation is insecure"

**Cause**: Not using HTTPS

**Solution**: Enable HTTPS for your web server

### Data Persists After Uninstall (iOS/Android KeyStore)

**Cause**: Platform behavior - iOS Keychain and Android KeyStore persist data

**Solution**: This is by design for security. To prevent:
- iOS: Use `ThisDeviceOnly` accessibility variants
- Android: Use EncryptedSharedPreferences instead of KeyStore

## 🔄 Migration Guide

### From SharedPreferences/Hive to SecureStorage

**Before:**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
final token = prefs.getString('auth_token');
```

**After:**
```dart
final secureStorage = getIt<SecureStorageService>();
await secureStorage.write(
  key: SecureStorageConstants.authToken,
  value: token,
);
final result = await secureStorage.read(
  key: SecureStorageConstants.authToken,
);
```

### Migration Script Example

```dart
Future<void> migrateToSecureStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = getIt<SecureStorageService>();
  
  // Migrate auth token
  final token = prefs.getString('auth_token');
  if (token != null) {
    await secureStorage.write(
      key: SecureStorageConstants.authToken,
      value: token,
    );
    await prefs.remove('auth_token');
  }
  
  // Mark migration complete
  await prefs.setBool('migrated_to_secure_storage', true);
}
```

## 📚 Related Documentation

- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) - Detailed usage examples
- [flutter_secure_storage package](https://pub.dev/packages/flutter_secure_storage)

## 📄 License

This is part of the BUMA Core library. See LICENSE file for details.

