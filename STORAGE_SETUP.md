# Storage Service Setup Guide

Complete guide for setting up and using the Storage Service in your Flutter application.

## 📦 Installation

### 1. Add Dependencies

The storage service uses `hive_flutter` by default. The dependencies are already included in `app_core`:

```yaml
dependencies:
  app_core: ^0.0.1  # Includes storage service
```

### 2. Run Flutter Pub Get

```bash
flutter pub get
```

That's it! The storage service is ready to use.

---

## 🚀 Quick Setup

### Minimal Setup (5 lines of code)

```dart
import 'package:app_core/app_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register storage in DI
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(),
  );
  
  // Initialize storage
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  runApp(MyApp());
}
```

### Using Storage

```dart
// Anywhere in your app
final storage = getIt<StorageService>();

// Save
await storage.save('key', 'value');

// Get
final value = await storage.get<String>('key');

// Delete
await storage.delete('key');
```

---

## 🎯 Recommended Setup

### Full Production Setup

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup storage services
  await setupStorage();
  
  runApp(MyApp());
}

/// Setup storage services with different instances for different purposes.
Future<void> setupStorage() async {
  // 1. Default storage - for general app data
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.defaultBoxName,
    ),
    instanceName: 'default',
  );
  
  // 2. Preferences storage - for user settings
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.preferencesBoxName,
    ),
    instanceName: 'preferences',
  );
  
  // 3. Cache storage - for temporary/cached data
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.cacheBoxName,
    ),
    instanceName: 'cache',
  );
  
  // 4. Secure storage - for sensitive data (encrypted)
  final encryptionKey = await getOrCreateEncryptionKey();
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ),
    instanceName: 'secure',
  );
  
  // Initialize all storages
  await getIt<StorageService>(instanceName: 'default').initialize();
  await getIt<StorageService>(instanceName: 'preferences').initialize();
  await getIt<StorageService>(instanceName: 'cache').initialize();
  await getIt<StorageService>(instanceName: 'secure').initialize();
}

/// Get or create encryption key for secure storage.
///
/// IMPORTANT: Store encryption key securely!
/// Use flutter_secure_storage in production.
Future<List<int>> getOrCreateEncryptionKey() async {
  // For demo purposes, generate a new key each time
  // In production, store this key securely and reuse it!
  return Hive.generateSecureKey();
}
```

### Using Multiple Storage Instances

```dart
// Default storage - general app data
final storage = getIt<StorageService>(instanceName: 'default');
await storage.save('last_sync', DateTime.now().toIso8601String());

// Preferences storage - user settings
final prefs = getIt<StorageService>(instanceName: 'preferences');
await prefs.save('theme', 'dark');
await prefs.save('language', 'en');

// Cache storage - temporary data
final cache = getIt<StorageService>(instanceName: 'cache');
await cache.saveWithExpiration(
  'api_response',
  apiData,
  expiresIn: Duration(hours: 1),
);

// Secure storage - sensitive data
final secure = getIt<StorageService>(instanceName: 'secure');
await secure.save('api_token', 'secret_token_here');
await secure.save('password', 'user_password');
```

---

## 🔐 Secure Storage with Encryption

### Production-Ready Encrypted Storage

For production apps, store encryption key securely using `flutter_secure_storage`:

#### 1. Add Dependency

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

#### 2. Implement Secure Key Storage

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureKeyStorage {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';
  
  /// Get or create encryption key.
  static Future<List<int>> getOrCreateEncryptionKey() async {
    try {
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: _keyName);
      
      if (existingKey != null) {
        // Key exists, decode and return
        return base64Decode(existingKey);
      }
      
      // Key doesn't exist, generate new one
      final newKey = Hive.generateSecureKey();
      
      // Store securely
      await _secureStorage.write(
        key: _keyName,
        value: base64Encode(newKey),
      );
      
      return newKey;
    } catch (e) {
      print('Error managing encryption key: $e');
      // Fallback: generate temporary key
      // In production, you might want to handle this differently
      return Hive.generateSecureKey();
    }
  }
  
  /// Delete encryption key (use when logging out or resetting app).
  static Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _keyName);
  }
}
```

#### 3. Use in Storage Setup

```dart
Future<void> setupStorage() async {
  // ... other storage setups ...
  
  // Secure storage with properly stored encryption key
  final encryptionKey = await SecureKeyStorage.getOrCreateEncryptionKey();
  
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ),
    instanceName: 'secure',
  );
  
  await getIt<StorageService>(instanceName: 'secure').initialize();
}
```

#### 4. Store Sensitive Data

```dart
final secureStorage = getIt<StorageService>(instanceName: 'secure');

// All data is encrypted automatically
await secureStorage.save('api_key', 'your_api_key_here');
await secureStorage.save('auth_token', 'bearer_token_xyz');
await secureStorage.save('user_password', 'user_password_hash');
await secureStorage.save('credit_card', 'encrypted_card_data');

// Retrieve (automatically decrypted)
final apiKey = await secureStorage.get<String>('api_key');
```

---

## 📱 Platform-Specific Configuration

### iOS Configuration

No additional configuration needed! Works out of the box.

### Android Configuration

No additional configuration needed! Works out of the box.

### Web Configuration

Hive Flutter works on web with IndexedDB. No additional configuration needed.

### Desktop (Windows/macOS/Linux)

No additional configuration needed! Works out of the box.

---

## 🔄 Migration Guide

### Migrating from SharedPreferences

Before:
```dart
final prefs = await SharedPreferences.getInstance();

// Save
await prefs.setString('key', 'value');
await prefs.setInt('count', 42);
await prefs.setBool('flag', true);

// Get
final value = prefs.getString('key');
final count = prefs.getInt('count') ?? 0;
final flag = prefs.getBool('flag') ?? false;

// Delete
await prefs.remove('key');
```

After:
```dart
final storage = getIt<StorageService>();

// Save
await storage.save('key', 'value');
await storage.save('count', 42);
await storage.save('flag', true);

// Get
final value = await storage.get<String>('key');
final count = await storage.get<int>('count', defaultValue: 0);
final flag = await storage.get<bool>('flag', defaultValue: false);

// Delete
await storage.delete('key');
```

### Migrating from get_storage

Before:
```dart
final box = GetStorage();

// Save
await box.write('key', 'value');

// Get
final value = box.read('key');

// Delete
await box.remove('key');
```

After:
```dart
final storage = getIt<StorageService>();

// Save
await storage.save('key', 'value');

// Get
final value = await storage.get('key');

// Delete
await storage.delete('key');
```

### Migrating from Hive (Direct Usage)

Before:
```dart
// Initialize
await Hive.initFlutter();
final box = await Hive.openBox('myBox');

// Save
await box.put('key', 'value');

// Get
final value = box.get('key');

// Delete
await box.delete('key');
```

After:
```dart
// Setup (once)
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(boxName: 'myBox'),
);
await getIt<StorageService>().initialize();

// Use anywhere
final storage = getIt<StorageService>();

// Save
await storage.save('key', 'value');

// Get
final value = await storage.get('key');

// Delete
await storage.delete('key');
```

**Benefits of using StorageService:**
- ✅ Dependency independence (easy to switch providers)
- ✅ Consistent API across implementations
- ✅ Type-safe operations
- ✅ Built-in expiration support
- ✅ Watch for changes
- ✅ Better error handling
- ✅ Testable with mocks

---

## 🧪 Testing

### Creating Mock Storage for Tests

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
    return (_data[key] as T?) ?? defaultValue;
  }

  @override
  Future<bool> containsKey(String key) async {
    return _data.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _data.keys.toList();
  }

  // Implement other methods as needed...
  
  @override
  Future<void> close() async {
    _initialized = false;
  }
}
```

### Using Mock in Tests

```dart
void main() {
  late StorageService storage;

  setUp(() {
    storage = MockStorageService();
  });

  test('should save and retrieve value', () async {
    await storage.initialize();
    
    await storage.save('test_key', 'test_value');
    
    final result = await storage.get<String>('test_key');
    expect(result, 'test_value');
  });

  test('should return default value when key not found', () async {
    await storage.initialize();
    
    final result = await storage.get<String>('non_existent', defaultValue: 'default');
    expect(result, 'default');
  });

  test('should delete value', () async {
    await storage.initialize();
    
    await storage.save('key', 'value');
    expect(await storage.containsKey('key'), true);
    
    await storage.delete('key');
    expect(await storage.containsKey('key'), false);
  });
}
```

### Using Mockito

```dart
@GenerateMocks([StorageService])
void main() {
  late MockStorageService storage;

  setUp(() {
    storage = MockStorageService();
  });

  test('should save user token', () async {
    when(storage.save('token', any)).thenAnswer((_) async {});
    when(storage.get<String>('token')).thenAnswer((_) async => 'abc123');
    
    await storage.save('token', 'abc123');
    final token = await storage.get<String>('token');
    
    expect(token, 'abc123');
    verify(storage.save('token', 'abc123')).called(1);
  });
}
```

---

## 🎨 Best Practices

### 1. Always Initialize Before Use

```dart
// ✅ Good
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = getIt<StorageService>();
  await storage.initialize();  // Initialize first!
  
  runApp(MyApp());
}

// ❌ Bad - might crash
void main() {
  runApp(MyApp());
}

// Later in app...
final storage = getIt<StorageService>();
await storage.save('key', 'value');  // Crash: not initialized!
```

### 2. Use Type-Safe Gets

```dart
// ✅ Good - explicit types
final name = await storage.get<String>('name');
final age = await storage.get<int>('age');
final isPremium = await storage.get<bool>('is_premium');

// ❌ Bad - no type safety
final name = await storage.get('name');  // dynamic type
```

### 3. Always Provide Default Values

```dart
// ✅ Good
final theme = await storage.get<String>('theme', defaultValue: 'light');
final count = await storage.get<int>('count', defaultValue: 0);

// ⚠️ Requires null check
final theme = await storage.get<String>('theme');
if (theme != null) {
  // use theme
}
```

### 4. Use Appropriate Storage for Data Type

```dart
// General app data
final storage = getIt<StorageService>(instanceName: 'default');
await storage.save('last_sync', timestamp);

// User preferences
final prefs = getIt<StorageService>(instanceName: 'preferences');
await prefs.save('theme', 'dark');

// Temporary cache
final cache = getIt<StorageService>(instanceName: 'cache');
await cache.saveWithExpiration('temp', data, expiresIn: Duration(hours: 1));

// Sensitive data
final secure = getIt<StorageService>(instanceName: 'secure');
await secure.save('token', secretToken);
```

### 5. Clean Up Cache Regularly

```dart
// Clear cache on app start or periodically
Future<void> clearOldCache() async {
  final cache = getIt<StorageService>(instanceName: 'cache');
  
  // Clear all cache
  await cache.clear();
  
  // Or compact to free up space
  await cache.compact();
}
```

### 6. Handle Initialization Errors

```dart
Future<void> setupStorage() async {
  try {
    final storage = getIt<StorageService>();
    await storage.initialize();
  } catch (e) {
    print('Failed to initialize storage: $e');
    // Handle error - maybe show error dialog or use fallback
  }
}
```

### 7. Use Batch Operations

```dart
// ✅ Good - one operation
await storage.saveAll({
  'key1': 'value1',
  'key2': 'value2',
  'key3': 'value3',
});

// ❌ Bad - multiple operations (slower)
await storage.save('key1', 'value1');
await storage.save('key2', 'value2');
await storage.save('key3', 'value3');
```

---

## 🐛 Troubleshooting

### Issue: "Storage not initialized"

**Cause**: Trying to use storage before calling `initialize()`.

**Solution**:
```dart
final storage = getIt<StorageService>();
await storage.initialize();  // Call this first!
```

### Issue: "Box is already open"

**Cause**: Trying to initialize the same storage multiple times.

**Solution**:
```dart
if (!storage.isInitialized) {
  await storage.initialize();
}
```

### Issue: Type mismatch errors

**Cause**: Saving data as one type, retrieving as another.

**Solution**: Use consistent types:
```dart
// Save as int
await storage.save('count', 42);

// Get as int (not String!)
final count = await storage.get<int>('count');
```

### Issue: Encrypted storage not working

**Cause**: Invalid encryption key or key lost.

**Solution**: Ensure encryption key is 32 bytes and stored securely:
```dart
final key = Hive.generateSecureKey();  // 32 bytes
// Store this key securely and reuse it!
```

### Issue: Data not persisting

**Cause**: Using wrong storage instance or not awaiting save operations.

**Solution**: Always await storage operations:
```dart
await storage.save('key', 'value');  // Don't forget await!
```

---

## 📚 Additional Resources

- [Storage Service Documentation](lib/src/infrastructure/storage/doc/README.md)
- [API Reference](lib/src/infrastructure/storage/contract/storage.service.dart)
- [Example Code](example/storage_example.dart)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Architecture Guide](ARCHITECTURE.md)

---

## 💡 Common Use Cases

### 1. User Authentication

```dart
final secure = getIt<StorageService>(instanceName: 'secure');

// Save auth token
await secure.save('auth_token', token);
await secure.save('refresh_token', refreshToken);
await secure.save('user_id', userId);

// Get auth token
final token = await secure.get<String>('auth_token');

// Clear on logout
await secure.deleteAll(['auth_token', 'refresh_token', 'user_id']);
```

### 2. App Settings

```dart
final prefs = getIt<StorageService>(instanceName: 'preferences');

// Save settings
await prefs.saveAll({
  'theme': 'dark',
  'language': 'en',
  'notifications_enabled': true,
  'font_size': 16.0,
});

// Get settings
final theme = await prefs.get<String>('theme', defaultValue: 'light');
final lang = await prefs.get<String>('language', defaultValue: 'en');
```

### 3. API Response Caching

```dart
final cache = getIt<StorageService>(instanceName: 'cache');

// Cache API response with 1 hour expiration
await cache.saveWithExpiration(
  'users_list',
  jsonEncode(usersData),
  expiresIn: Duration(hours: 1),
);

// Check and use cache
if (!await cache.isExpired('users_list')) {
  final cached = await cache.get<String>('users_list');
  return jsonDecode(cached!);
} else {
  // Fetch fresh data from API
  final freshData = await fetchFromAPI();
  await cache.saveWithExpiration(
    'users_list',
    jsonEncode(freshData),
    expiresIn: Duration(hours: 1),
  );
  return freshData;
}
```

### 4. Offline Data Sync

```dart
final storage = getIt<StorageService>(instanceName: 'default');

// Save offline changes
await storage.saveAll({
  'pending_sync': true,
  'offline_changes': jsonEncode(changes),
  'last_sync': DateTime.now().toIso8601String(),
});

// Sync when online
if (await isOnline()) {
  final pending = await storage.get<bool>('pending_sync');
  if (pending == true) {
    final changes = await storage.get<String>('offline_changes');
    await syncToServer(jsonDecode(changes!));
    await storage.delete('pending_sync');
    await storage.delete('offline_changes');
  }
}
```

---

## ❓ FAQ

### Q: Can I use multiple storage providers simultaneously?

**A:** Yes! You can create implementations for different providers and register them with different instance names:

```dart
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(),
  instanceName: 'hive',
);

getIt.registerLazySingleton<StorageService>(
  () => SharedPreferencesStorageImpl(),
  instanceName: 'shared_prefs',
);
```

### Q: How do I switch from Hive to another provider?

**A:** Just create a new implementation and update the DI registration. No changes needed in business logic!

```dart
// From:
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(),
);

// To:
getIt.registerLazySingleton<StorageService>(
  () => IsarStorageServiceImpl(),  // Different implementation
);
```

### Q: Is the data encrypted by default?

**A:** No. You need to explicitly use encrypted storage with `HiveAesCipher`:

```dart
getIt.registerLazySingleton<StorageService>(
  () => HiveStorageServiceImpl(
    encryptionCipher: HiveAesCipher(encryptionKey),  // Enable encryption
  ),
);
```

### Q: How much data can I store?

**A:** Hive has no theoretical limit, but consider:
- Mobile devices: Reasonable limit is a few hundred MB
- For large datasets, use `useLazyBox: true`
- Monitor with `storage.getSize()`

### Q: Can I use this on all platforms?

**A:** Yes! Works on iOS, Android, Web, Windows, macOS, and Linux.

---

Need help? Open an issue on the project repository!

