import 'package:dartz/dartz.dart';
import 'package:app_core/src/errors/errors.dart';

/// Abstract contract for local storage service.
///
/// This interface provides a standardized way to interact with local storage
/// across different storage implementations (Hive, SharedPreferences, Isar, etc.).
///
/// **Dependency Independence**: This interface does NOT depend on any
/// specific storage package. Consumer apps can use any storage provider
/// by creating implementations of this interface.
///
/// **Features:**
/// - Generic key-value storage
/// - Type-safe operations
/// - Batch operations
/// - Query support
/// - Encryption support (optional)
/// - Expiration/TTL support
/// - Error handling with Either<Failure, Success>
///
/// Example usage:
/// ```dart
/// final storage = getIt<StorageService>();
///
/// // Initialize
/// await storage.initialize();
///
/// // Save data
/// final saveResult = await storage.save('user_id', '123');
/// saveResult.fold(
///   (failure) => print('Error: $failure'),
///   (_) => print('Saved successfully'),
/// );
///
/// // Get data
/// final getResult = await storage.get<String>('user_id');
/// getResult.fold(
///   (failure) => print('Error: $failure'),
///   (value) => print('Value: $value'),
/// );
/// ```
abstract class StorageService {
  /// Initialize the storage.
  ///
  /// Must be called before using the storage service.
  /// Some implementations may require async initialization (e.g., opening database).
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.initialize();
  /// result.fold(
  ///   (failure) => print('Init failed: $failure'),
  ///   (_) => print('Init successful'),
  /// );
  /// ```
  Future<Either<StorageFailure, void>> initialize();

  /// Check if storage is initialized and ready to use.
  bool get isInitialized;

  /// Save a primitive value to storage.
  ///
  /// Supported types: String, int, double, bool, List<String>, Map<String, dynamic>
  ///
  /// [key] - The storage key
  /// [value] - The value to save
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.save('token', 'abc123');
  /// await storage.save('count', 42);
  /// await storage.save('is_logged_in', true);
  /// ```
  Future<Either<StorageFailure, void>> save<T>(String key, T value);

  /// Save an object to storage.
  ///
  /// The object will be serialized before storage. For complex objects,
  /// you may need to provide a custom serializer.
  ///
  /// [key] - The storage key
  /// [value] - The object to save
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.saveObject('user', userModel);
  /// await storage.saveObject('settings', settingsModel);
  /// ```
  Future<Either<StorageFailure, void>> saveObject<T>(String key, T value);

  /// Save multiple values in a batch operation.
  ///
  /// More efficient than calling [save] multiple times.
  ///
  /// [entries] - Map of key-value pairs to save
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.saveAll({
  ///   'token': 'abc123',
  ///   'user_id': '456',
  ///   'is_premium': true,
  /// });
  /// ```
  Future<Either<StorageFailure, void>> saveAll(Map<String, dynamic> entries);

  /// Get a value from storage.
  ///
  /// Returns Either<StorageFailure, T?> - null if key doesn't exist
  ///
  /// [key] - The storage key
  /// [defaultValue] - Optional default value if key doesn't exist
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.get<String>('token');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (token) => print('Token: $token'),
  /// );
  /// ```
  Future<Either<StorageFailure, T?>> get<T>(String key, {T? defaultValue});

  /// Get an object from storage.
  ///
  /// Returns Either<StorageFailure, T?> - null if key doesn't exist
  /// You may need to provide a custom deserializer for complex objects.
  ///
  /// [key] - The storage key
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.getObject<UserModel>('user');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (user) => print('User: $user'),
  /// );
  /// ```
  Future<Either<StorageFailure, T?>> getObject<T>(String key);

  /// Check if a key exists in storage.
  ///
  /// [key] - The storage key to check
  ///
  /// Returns Either<StorageFailure, bool>
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.containsKey('token');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (exists) => print('Exists: $exists'),
  /// );
  /// ```
  Future<Either<StorageFailure, bool>> containsKey(String key);

  /// Delete a value from storage.
  ///
  /// [key] - The storage key to delete
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.delete('token');
  /// ```
  Future<Either<StorageFailure, void>> delete(String key);

  /// Delete multiple keys from storage.
  ///
  /// [keys] - List of keys to delete
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.deleteAll(['token', 'user_id', 'session']);
  /// ```
  Future<Either<StorageFailure, void>> deleteAll(List<String> keys);

  /// Clear all data from storage.
  ///
  /// ⚠️ Warning: This will delete ALL data. Use with caution!
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.clear();
  /// ```
  Future<Either<StorageFailure, void>> clear();

  /// Get all keys in storage.
  ///
  /// Returns Either<StorageFailure, List<String>>
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.getAllKeys();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (keys) => print('Keys: $keys'),
  /// );
  /// ```
  Future<Either<StorageFailure, List<String>>> getAllKeys();

  /// Get all values in storage as a map.
  ///
  /// Returns Either<StorageFailure, Map<String, dynamic>>
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.getAllEntries();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (data) => print('Data: $data'),
  /// );
  /// ```
  Future<Either<StorageFailure, Map<String, dynamic>>> getAllEntries();

  /// Watch for changes to a specific key.
  ///
  /// Returns a stream that emits new values whenever the key changes.
  ///
  /// [key] - The storage key to watch
  ///
  /// Example:
  /// ```dart
  /// storage.watch<String>('token').listen((newToken) {
  ///   print('Token changed: $newToken');
  /// });
  /// ```
  Stream<T?> watch<T>(String key);

  /// Save a value with expiration time.
  ///
  /// The value will be automatically deleted after the specified duration.
  ///
  /// [key] - The storage key
  /// [value] - The value to save
  /// [expiresIn] - Duration until the value expires
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// // Save token that expires in 1 hour
  /// await storage.saveWithExpiration(
  ///   'temp_token',
  ///   'xyz789',
  ///   expiresIn: Duration(hours: 1),
  /// );
  /// ```
  Future<Either<StorageFailure, void>> saveWithExpiration<T>(
    String key,
    T value, {
    required Duration expiresIn,
  });

  /// Check if a key has expired.
  ///
  /// Returns Either<StorageFailure, bool> - true if expired or doesn't exist
  ///
  /// [key] - The storage key to check
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.isExpired('temp_token');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (expired) {
  ///     if (expired) {
  ///       // Token has expired, need to refresh
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<StorageFailure, bool>> isExpired(String key);

  /// Get storage size in bytes.
  ///
  /// Useful for monitoring storage usage.
  ///
  /// Returns Either<StorageFailure, int>
  ///
  /// Example:
  /// ```dart
  /// final result = await storage.getSize();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (size) => print('Storage size: ${size / 1024} KB'),
  /// );
  /// ```
  Future<Either<StorageFailure, int>> getSize();

  /// Compact/optimize the storage.
  ///
  /// Some storage implementations may need periodic compaction
  /// to free up space and improve performance.
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.compact();
  /// ```
  Future<Either<StorageFailure, void>> compact();

  /// Close the storage and release resources.
  ///
  /// Call this when the storage is no longer needed.
  ///
  /// Returns Either<StorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// await storage.close();
  /// ```
  Future<Either<StorageFailure, void>> close();
}
