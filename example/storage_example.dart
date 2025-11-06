// ignore_for_file: avoid_print

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Example demonstrating storage service usage.
///
/// This example shows:
/// - Basic storage operations (save, get, delete)
/// - Working with different data types
/// - Batch operations
/// - Expiration/TTL
/// - Watch for changes
/// - Multiple storage instances
/// - Encrypted storage
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup storage services
  await setupStorage();

  // Run examples
  print('=== Storage Service Examples ===\n');

  await basicStorageExample();
  await batchOperationsExample();
  await expirationExample();
  await watchExample();
  await multipleInstancesExample();
  await encryptedStorageExample();

  print('\n=== All Examples Completed ===');
}

/// Setup storage services in DI container.
Future<void> setupStorage() async {
  // Default storage
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.defaultBoxName,
    ),
    instanceName: 'default',
  );

  // User preferences storage
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
  final encryptionKey = Hive.generateSecureKey();
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: StorageConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ),
    instanceName: 'secure',
  );

  // Initialize all storages with error handling
  final defaultInit = await getIt<StorageService>(instanceName: 'default').initialize();
  defaultInit.fold(
    (failure) => print('❌ Failed to initialize default storage: $failure'),
    (_) => print('✅ Default storage initialized'),
  );

  final prefInit = await getIt<StorageService>(instanceName: 'preferences').initialize();
  prefInit.fold(
    (failure) => print('❌ Failed to initialize preferences storage: $failure'),
    (_) => print('✅ Preferences storage initialized'),
  );

  final cacheInit = await getIt<StorageService>(instanceName: 'cache').initialize();
  cacheInit.fold(
    (failure) => print('❌ Failed to initialize cache storage: $failure'),
    (_) => print('✅ Cache storage initialized'),
  );

  final secureInit = await getIt<StorageService>(instanceName: 'secure').initialize();
  secureInit.fold(
    (failure) => print('❌ Failed to initialize secure storage: $failure'),
    (_) => print('✅ Secure storage initialized'),
  );
}

/// Example 1: Basic storage operations with Either pattern.
Future<void> basicStorageExample() async {
  print('--- Example 1: Basic Storage Operations (with Either) ---');

  final storage = getIt<StorageService>(instanceName: 'default');

  // Save different types of data with error handling
  await storage.save('user_name', 'John Doe');
  await storage.save('user_age', 25);
  await storage.save('is_premium', true);
  await storage.save('user_tags', ['flutter', 'dart', 'mobile']);

  print('✅ Saved user data');

  // Get data with type safety and error handling
  final nameResult = await storage.get<String>('user_name');
  nameResult.fold(
    (failure) => print('   ❌ Failed to get name: $failure'),
    (name) => print('   Name: $name'),
  );

  final ageResult = await storage.get<int>('user_age');
  ageResult.fold(
    (failure) => print('   ❌ Failed to get age: $failure'),
    (age) => print('   Age: $age'),
  );

  final isPremiumResult = await storage.get<bool>('is_premium');
  isPremiumResult.fold(
    (failure) => print('   ❌ Failed to get premium status: $failure'),
    (isPremium) => print('   Premium: $isPremium'),
  );

  // Get with default value
  final themeResult = await storage.get<String>('theme', defaultValue: 'light');
  themeResult.fold(
    (failure) => print('   ❌ Failed to get theme: $failure'),
    (theme) => print('   Theme: $theme (default)'),
  );

  // Check if key exists
  final hasTokenResult = await storage.containsKey('token');
  hasTokenResult.fold(
    (failure) => print('   ❌ Failed to check token: $failure'),
    (hasToken) => print('   Has token: $hasToken'),
  );

  // Delete a key
  final deleteResult = await storage.delete('user_age');
  deleteResult.fold(
    (failure) => print('🗑️ ❌ Failed to delete user_age: $failure'),
    (_) => print('🗑️ Deleted user_age'),
  );

  // Verify deletion
  final deletedAgeResult = await storage.get<int>('user_age');
  deletedAgeResult.fold(
    (failure) => print('   ❌ Failed to get deleted age: $failure'),
    (deletedAge) => print('   Age after deletion: $deletedAge (should be null)'),
  );

  print('');
}

/// Example 2: Batch operations with Either pattern.
Future<void> batchOperationsExample() async {
  print('--- Example 2: Batch Operations (with Either) ---');

  final storage = getIt<StorageService>(instanceName: 'default');

  // Save multiple values at once
  final saveAllResult = await storage.saveAll({
    'app_version': '1.0.0',
    'last_login': DateTime.now().toIso8601String(),
    'login_count': 42,
    'notifications_enabled': true,
  });

  saveAllResult.fold(
    (failure) => print('❌ Batch save failed: $failure'),
    (_) => print('✅ Batch saved multiple values'),
  );

  // Get all keys
  final allKeysResult = await storage.getAllKeys();
  allKeysResult.fold(
    (failure) => print('❌ Failed to get all keys: $failure'),
    (allKeys) => print('📖 All keys: $allKeys'),
  );

  // Get all entries
  final allEntriesResult = await storage.getAllEntries();
  allEntriesResult.fold(
    (failure) => print('❌ Failed to get all entries: $failure'),
    (allEntries) => print('📖 All entries: $allEntries'),
  );

  // Get storage size
  final sizeResult = await storage.getSize();
  sizeResult.fold(
    (failure) => print('❌ Failed to get storage size: $failure'),
    (size) => print('💾 Storage size: $size bytes (${(size / 1024).toStringAsFixed(2)} KB)'),
  );

  // Delete multiple keys
  final deleteResult = await storage.deleteAll(['app_version', 'last_login']);
  deleteResult.fold(
    (failure) => print('❌ Failed to delete keys: $failure'),
    (_) => print('🗑️ Deleted multiple keys'),
  );

  print('');
}

/// Example 3: Expiration/TTL.
Future<void> expirationExample() async {
  print('--- Example 3: Expiration/TTL ---');

  final storage = getIt<StorageService>(instanceName: 'cache');

  // Save with expiration (expires in 2 seconds)
  await storage.saveWithExpiration(
    'temp_token',
    'xyz789abc',
    expiresIn: const Duration(seconds: 2),
  );

  print('✅ Saved temp_token with 2 second expiration');

  // Check immediately
  var isExpired = await storage.isExpired('temp_token');
  var token = await storage.get<String>('temp_token');
  print('📖 Immediately: expired=$isExpired, token=$token');

  // Wait 3 seconds
  print('⏳ Waiting 3 seconds...');
  await Future.delayed(const Duration(seconds: 3));

  // Check after expiration
  isExpired = await storage.isExpired('temp_token');
  token = await storage.get<String>('temp_token');
  print('📖 After 3 seconds: expired=$isExpired, token=$token (should be null)');

  print('');
}

/// Example 4: Watch for changes.
Future<void> watchExample() async {
  print('--- Example 4: Watch for Changes ---');

  final storage = getIt<StorageService>(instanceName: 'default');

  // Setup watcher
  final subscription = storage.watch<int>('counter').listen((value) {
    print('🔔 Counter changed: $value');
  });

  print('👀 Watching "counter" key...');

  // Make changes
  await storage.save('counter', 1);
  await Future.delayed(const Duration(milliseconds: 100));

  await storage.save('counter', 2);
  await Future.delayed(const Duration(milliseconds: 100));

  await storage.save('counter', 3);
  await Future.delayed(const Duration(milliseconds: 100));

  await storage.delete('counter');
  await Future.delayed(const Duration(milliseconds: 100));

  // Cancel subscription
  await subscription.cancel();
  print('🛑 Stopped watching');

  print('');
}

/// Example 5: Multiple storage instances.
Future<void> multipleInstancesExample() async {
  print('--- Example 5: Multiple Storage Instances ---');

  final defaultStorage = getIt<StorageService>(instanceName: 'default');
  final prefStorage = getIt<StorageService>(instanceName: 'preferences');
  final cacheStorage = getIt<StorageService>(instanceName: 'cache');

  // Save to different storages
  await defaultStorage.save('app_data', 'general data');
  await prefStorage.save('theme', 'dark');
  await cacheStorage.save('api_cache', {'users': []});

  print('✅ Saved to different storage instances');

  // Retrieve from different storages
  final appData = await defaultStorage.get<String>('app_data');
  final theme = await prefStorage.get<String>('theme');
  final cache = await cacheStorage.get('api_cache');

  print('📖 Retrieved from different storages:');
  print('   Default: $appData');
  print('   Preferences: $theme');
  print('   Cache: $cache');

  print('');
}

/// Example 6: Encrypted storage.
Future<void> encryptedStorageExample() async {
  print('--- Example 6: Encrypted Storage ---');

  final secureStorage = getIt<StorageService>(instanceName: 'secure');

  // Save sensitive data (automatically encrypted)
  await secureStorage.save('api_key', 'super_secret_key_12345');
  await secureStorage.save('password', 'my_secure_password');
  await secureStorage.save('credit_card', '1234-5678-9012-3456');

  print('✅ Saved sensitive data (encrypted)');

  // Retrieve encrypted data (automatically decrypted)
  final apiKey = await secureStorage.get<String>('api_key');
  final password = await secureStorage.get<String>('password');
  final creditCard = await secureStorage.get<String>('credit_card');

  print('📖 Retrieved encrypted data:');
  print('   API Key: $apiKey');
  print('   Password: $password');
  print('   Credit Card: $creditCard');

  print('🔐 All data is encrypted at rest in Hive!');

  print('');
}

/// Example 7: Cleanup operations.
Future<void> cleanupExample() async {
  print('--- Example 7: Cleanup Operations ---');

  final storage = getIt<StorageService>(instanceName: 'cache');

  // Add some data
  await storage.saveAll({
    'item1': 'value1',
    'item2': 'value2',
    'item3': 'value3',
  });

  print('✅ Added cache data');

  // Compact storage (optimize and free space)
  await storage.compact();
  print('🧹 Compacted storage');

  // Clear all cache data
  await storage.clear();
  print('🗑️ Cleared all cache data');

  // Verify
  final keys = await storage.getAllKeys();
  print('📖 Keys after clear: $keys (should be empty)');

  // Close storage
  await storage.close();
  print('🚪 Closed storage');

  print('');
}

/// Example model for demonstrating object storage.
class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        age: json['age'] as int,
      );

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, age: $age)';
}

/// Example 8: Storing complex objects.
Future<void> objectStorageExample() async {
  print('--- Example 8: Complex Object Storage ---');

  final storage = getIt<StorageService>(instanceName: 'default');

  // Create user model
  final user = UserModel(
    id: '123',
    name: 'John Doe',
    email: 'john@example.com',
    age: 25,
  );

  // Save object (will be serialized to JSON)
  final saveResult = await storage.saveObject('current_user', user.toJson());
  saveResult.fold(
    (failure) => print('❌ Failed to save user object: $failure'),
    (_) => print('✅ Saved user object'),
  );

  // Retrieve object (will be deserialized from JSON)
  final savedUserResult =
      await storage.getObject<Map<String, dynamic>>('current_user');

  savedUserResult.fold(
    (failure) => print('❌ Failed to retrieve user object: $failure'),
    (savedUser) {
      if (savedUser != null) {
        final retrievedUser = UserModel.fromJson(savedUser);
        print('📖 Retrieved user: $retrievedUser');
      } else {
        print('⚠️ User object not found');
      }
    },
  );

  print('');
}

