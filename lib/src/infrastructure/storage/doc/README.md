# Storage Service

A dependency-independent local storage service for Flutter applications.

## 📋 Overview

The Storage Service provides a standardized interface for local data persistence across different storage implementations. Currently supports **Hive** with the ability to easily swap to other providers like SharedPreferences, Isar, ObjectBox, etc.

### ✨ Key Features

- **🔄 Dependency Independent** - Easy to switch between storage providers
- **🎯 Type-Safe** - Generic type support for compile-time safety
- **⚡ Fast Operations** - Optimized for performance with Hive
- **🔐 Encryption Support** - Built-in support for encrypted storage
- **👀 Reactive** - Watch for real-time value changes
- **⏰ Expiration/TTL** - Auto-expire data after specified duration
- **📦 Batch Operations** - Efficient bulk save/delete operations
- **💾 Lazy Loading** - Support for large datasets without memory overhead
- **🧹 Auto-Cleanup** - Compaction and optimization support

---

## 🚀 Quick Start

### 1. Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  app_core: ^0.0.1
  hive_flutter: ^1.1.0  # Current implementation uses Hive
```

### 2. Initialize Storage

```dart
import 'package:app_core/app_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register storage service in DI
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.defaultBoxName,
    ),
  );
  
  // Initialize storage
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  runApp(MyApp());
}
```

### 3. Basic Usage

```dart
final storage = getIt<StorageService>();

// Save data
await storage.save('user_name', 'John Doe');
await storage.save('user_age', 25);
await storage.save('is_premium', true);

// Get data
final name = await storage.get<String>('user_name');
final age = await storage.get<int>('user_age');
final isPremium = await storage.get<bool>('is_premium', defaultValue: false);

// Delete data
await storage.delete('user_age');

// Clear all data
await storage.clear();
```

---

## 📚 Usage Guide

### Save Operations

#### Save Primitive Values

```dart
// String
await storage.save('token', 'abc123xyz');

// Numbers
await storage.save('count', 42);
await storage.save('price', 99.99);

// Boolean
await storage.save('is_logged_in', true);

// List
await storage.save('tags', ['flutter', 'dart', 'mobile']);

// Map
await storage.save('config', {'theme': 'dark', 'lang': 'en'});
```

#### Save Objects

```dart
// Save complex object (will be JSON serialized)
final user = UserModel(
  id: '123',
  name: 'John Doe',
  email: 'john@example.com',
);

await storage.saveObject('current_user', user);
```

#### Batch Save

```dart
// Save multiple values at once (more efficient)
await storage.saveAll({
  'token': 'abc123',
  'user_id': '456',
  'is_premium': true,
  'last_login': DateTime.now().toIso8601String(),
});
```

#### Save with Expiration (TTL)

```dart
// Save data that auto-expires
await storage.saveWithExpiration(
  'temp_token',
  'xyz789',
  expiresIn: Duration(hours: 1),
);

// Check if expired
final isExpired = await storage.isExpired('temp_token');
if (isExpired) {
  print('Token expired!');
}
```

### Get Operations

#### Get Primitive Values

```dart
// With null safety
final token = await storage.get<String>('token');
if (token != null) {
  print('Token: $token');
}

// With default value
final count = await storage.get<int>('count', defaultValue: 0);
final theme = await storage.get<String>('theme', defaultValue: 'light');
```

#### Get Objects

```dart
final user = await storage.getObject<UserModel>('current_user');
if (user != null) {
  print('User: ${user.name}');
}
```

#### Check Key Existence

```dart
if (await storage.containsKey('token')) {
  print('Token exists');
} else {
  print('Token not found');
}
```

### Delete Operations

#### Delete Single Key

```dart
await storage.delete('token');
```

#### Delete Multiple Keys

```dart
await storage.deleteAll([
  'token',
  'user_id',
  'session',
  'temp_data',
]);
```

#### Clear All Data

```dart
// ⚠️ Warning: This deletes ALL data!
await storage.clear();
```

### Query Operations

#### Get All Keys

```dart
final keys = await storage.getAllKeys();
print('Stored keys: $keys');
// Output: ['token', 'user_id', 'is_premium', ...]
```

#### Get All Entries

```dart
final allData = await storage.getAllEntries();
print('All data: $allData');
// Output: {'token': 'abc123', 'user_id': '456', ...}
```

### Reactive Operations

#### Watch for Changes

```dart
// Watch a specific key
storage.watch<String>('token').listen((newToken) {
  print('Token changed: $newToken');
});

// Watch multiple keys
storage.watch<bool>('is_premium').listen((isPremium) {
  if (isPremium == true) {
    print('User upgraded to premium!');
  }
});

storage.watch<int>('notification_count').listen((count) {
  print('Notifications: $count');
});
```

### Maintenance Operations

#### Get Storage Size

```dart
final sizeInBytes = await storage.getSize();
final sizeInKB = sizeInBytes / 1024;
print('Storage size: ${sizeInKB.toStringAsFixed(2)} KB');
```

#### Compact Storage

```dart
// Optimize storage (frees up space)
await storage.compact();
```

#### Close Storage

```dart
// Clean up resources when done
await storage.close();
```

---

## 🔐 Encrypted Storage

For storing sensitive data like tokens, passwords, API keys:

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Generate encryption key (store this securely!)
  // You should generate this once and store it securely
  // (e.g., in Flutter Secure Storage)
  final encryptionKey = Hive.generateSecureKey();
  
  // Register encrypted storage
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ),
  );
  
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  // Now all data is encrypted automatically
  await storage.save('api_key', 'super_secret_key');
  await storage.save('password', 'my_password');
  
  runApp(MyApp());
}
```

### Best Practices for Encryption

1. **Generate Key Once**: Generate encryption key once and store securely
2. **Use Secure Storage**: Store encryption key in `flutter_secure_storage`
3. **Separate Boxes**: Use different boxes for encrypted and non-encrypted data
4. **Key Rotation**: Implement key rotation for high-security apps

Example with secure key storage:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<List<int>> getOrCreateEncryptionKey() async {
  const secureStorage = FlutterSecureStorage();
  
  // Try to get existing key
  final existingKey = await secureStorage.read(key: 'hive_encryption_key');
  
  if (existingKey != null) {
    return base64Decode(existingKey);
  }
  
  // Generate new key
  final newKey = Hive.generateSecureKey();
  
  // Store securely
  await secureStorage.write(
    key: 'hive_encryption_key',
    value: base64Encode(newKey),
  );
  
  return newKey;
}

// Usage
final encryptionKey = await getOrCreateEncryptionKey();
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(
    boxName: StorageConstants.secureBoxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  ),
);
```

---

## 🎨 Multiple Storage Instances

You can use multiple storage instances for different purposes:

```dart
void setupStorage() {
  // Default storage
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.defaultBoxName,
    ),
    instanceName: 'default',
  );
  
  // User preferences
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.preferencesBoxName,
    ),
    instanceName: 'preferences',
  );
  
  // Cache storage
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.cacheBoxName,
    ),
    instanceName: 'cache',
  );
  
  // Secure storage (encrypted)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ),
    instanceName: 'secure',
  );
}

// Usage
final defaultStorage = getIt<StorageService>(instanceName: 'default');
final prefStorage = getIt<StorageService>(instanceName: 'preferences');
final cacheStorage = getIt<StorageService>(instanceName: 'cache');
final secureStorage = getIt<StorageService>(instanceName: 'secure');
```

---

## 💾 Lazy Box for Large Datasets

For apps with large amounts of data, use lazy boxes to avoid loading everything into memory:

```dart
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(
    boxName: 'large_data',
    useLazyBox: true,  // Enable lazy loading
  ),
);

// Now only requested keys are loaded into memory
final storage = getIt<StorageService>();
await storage.initialize();

// These operations don't load all data into memory
await storage.save('key_1', largeObject1);
await storage.save('key_2', largeObject2);
final value = await storage.get('key_1');
```

---

## 🧪 Testing

### Mock Storage for Tests

```dart
class MockStorageService implements StorageService {
  final Map<String, dynamic> _data = {};
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> save<T>(String key, T value) async {
    _data[key] = value;
  }

  @override
  Future<T?> get<T>(String key, {T? defaultValue}) async {
    return _data[key] as T? ?? defaultValue;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  // Implement other methods...
}

// In tests
void main() {
  late StorageService storage;

  setUp(() {
    storage = MockStorageService();
  });

  test('should save and retrieve value', () async {
    await storage.initialize();
    await storage.save('key', 'value');
    
    final result = await storage.get<String>('key');
    expect(result, 'value');
  });
}
```

---

## 🔄 Migration Guide

### Switching from SharedPreferences to Hive

Before (SharedPreferences):
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', 'abc123');
final token = prefs.getString('token');
```

After (Storage Service):
```dart
final storage = getIt<StorageService>();
await storage.save('token', 'abc123');
final token = await storage.get<String>('token');
```

### Switching Storage Provider

To switch from Hive to another provider (e.g., Isar):

1. Create new implementation:

```dart
class IsarStorageServiceImpl implements StorageService {
  // Implement all methods using Isar
}
```

2. Update DI registration (ONLY THIS CHANGES!):

```dart
// From:
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(),
);

// To:
getIt.registerLazySingleton<StorageService>(
  () => IsarStorageServiceImpl(),
);
```

3. Update pubspec.yaml:

```yaml
dependencies:
  # hive_flutter: ^1.1.0  # Remove
  isar: ^3.0.0            # Add new
  isar_flutter_libs: ^3.0.0
```

**That's it!** No changes needed in business logic or UI code. 🎉

---

## ⚙️ Configuration

### Storage Constants

Use provided constants for common box names:

```dart
// Default storage
StorageConstants.defaultBoxName      // 'app_storage'

// Secure/encrypted storage
StorageConstants.secureBoxName       // 'secure_storage'

// User preferences
StorageConstants.preferencesBoxName  // 'preferences'

// Cache storage
StorageConstants.cacheBoxName        // 'cache'

// Error codes
StorageConstants.errorCodeNotFound
StorageConstants.errorCodeWriteFailed
StorageConstants.errorCodeReadFailed
```

---

## 🎯 Best Practices

### 1. Initialize Early

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage before app starts
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  runApp(MyApp());
}
```

### 2. Use Typed Gets

```dart
// ✅ Good - Type-safe
final count = await storage.get<int>('count', defaultValue: 0);

// ❌ Bad - No type safety
final count = await storage.get('count');
```

### 3. Handle Null Values

```dart
// ✅ Good - Safe null handling
final token = await storage.get<String>('token');
if (token != null) {
  // Use token
}

// Or with default
final theme = await storage.get<String>('theme', defaultValue: 'light');
```

### 4. Use Batch Operations

```dart
// ✅ Good - One operation
await storage.saveAll({
  'key1': 'value1',
  'key2': 'value2',
  'key3': 'value3',
});

// ❌ Bad - Multiple operations
await storage.save('key1', 'value1');
await storage.save('key2', 'value2');
await storage.save('key3', 'value3');
```

### 5. Separate Sensitive Data

```dart
// Regular storage for normal data
final storage = getIt<StorageService>(instanceName: 'default');
await storage.save('user_name', 'John');

// Secure storage for sensitive data
final secureStorage = getIt<StorageService>(instanceName: 'secure');
await secureStorage.save('password', 'secret');
```

### 6. Clean Up Resources

```dart
// Close storage when app is terminating
await storage.close();
```

### 7. Use Expiration for Temporary Data

```dart
// Cache with auto-expiration
await storage.saveWithExpiration(
  'api_cache_users',
  userData,
  expiresIn: Duration(hours: 1),
);

// Check before use
if (!await storage.isExpired('api_cache_users')) {
  final cached = await storage.get('api_cache_users');
  return cached;
}
```

---

## 🐛 Troubleshooting

### Storage Not Initialized Error

**Error**: `StateError: Storage not initialized`

**Solution**: Call `initialize()` before using storage:
```dart
final storage = getIt<StorageService>();
await storage.initialize();  // Don't forget this!
```

### Encryption Key Error

**Error**: `HiveError: Invalid encryption key`

**Solution**: Ensure encryption key is 256 bits (32 bytes):
```dart
final key = Hive.generateSecureKey();  // Generates 32 bytes
```

### Box Already Open Error

**Error**: `HiveError: Box is already open`

**Solution**: Don't initialize storage multiple times:
```dart
if (!storage.isInitialized) {
  await storage.initialize();
}
```

### Type Mismatch Error

**Error**: `type 'int' is not a subtype of type 'String'`

**Solution**: Use correct generic type:
```dart
// If you saved as int
await storage.save('count', 42);

// Get as int, not String
final count = await storage.get<int>('count');  // ✅
// Not: await storage.get<String>('count');  ❌
```

---

## 📝 API Reference

See [StorageService](/lib/src/infrastructure/storage/contract/storage.service.dart) for complete API documentation.

### Core Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `initialize()` | Initialize storage | `Future<void>` |
| `save<T>(key, value)` | Save value | `Future<void>` |
| `get<T>(key)` | Get value | `Future<T?>` |
| `delete(key)` | Delete value | `Future<void>` |
| `clear()` | Clear all data | `Future<void>` |
| `containsKey(key)` | Check if key exists | `Future<bool>` |
| `watch<T>(key)` | Watch for changes | `Stream<T?>` |
| `close()` | Close storage | `Future<void>` |

---

## 🔗 Related Resources

- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [BUMA Core Architecture](../../../ARCHITECTURE.md)
- [Project Guidelines](../../../README.md)

---

## 💡 Examples

See [example/storage_example.dart](/example/storage_example.dart) for complete working examples.

---

**Questions or Issues?** Please open an issue on the project repository.

