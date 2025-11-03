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
///
/// Example usage:
/// ```dart
/// final storage = getIt<StorageService>();
///
/// // Save data
/// await storage.save('user_id', '123');
/// await storage.save('user_name', 'John Doe');
/// await storage.saveObject('user', userModel);
///
/// // Get data
/// final userId = await storage.get<String>('user_id');
/// final user = await storage.getObject<UserModel>('user');
///
/// // Delete data
/// await storage.delete('user_id');
///
/// // Clear all data
/// await storage.clear();
/// ```
abstract class StorageService {
  /// Initialize the storage.
  ///
  /// Must be called before using the storage service.
  /// Some implementations may require async initialization (e.g., opening database).
  ///
  /// Example:
  /// ```dart
  /// await storage.initialize();
  /// ```
  Future<void> initialize();

  /// Check if storage is initialized and ready to use.
  bool get isInitialized;

  /// Save a primitive value to storage.
  ///
  /// Supported types: String, int, double, bool, List<String>, Map<String, dynamic>
  ///
  /// [key] - The storage key
  /// [value] - The value to save
  ///
  /// Example:
  /// ```dart
  /// await storage.save('token', 'abc123');
  /// await storage.save('count', 42);
  /// await storage.save('is_logged_in', true);
  /// ```
  Future<void> save<T>(String key, T value);

  /// Save an object to storage.
  ///
  /// The object will be serialized before storage. For complex objects,
  /// you may need to provide a custom serializer.
  ///
  /// [key] - The storage key
  /// [value] - The object to save
  ///
  /// Example:
  /// ```dart
  /// await storage.saveObject('user', userModel);
  /// await storage.saveObject('settings', settingsModel);
  /// ```
  Future<void> saveObject<T>(String key, T value);

  /// Save multiple values in a batch operation.
  ///
  /// More efficient than calling [save] multiple times.
  ///
  /// [entries] - Map of key-value pairs to save
  ///
  /// Example:
  /// ```dart
  /// await storage.saveAll({
  ///   'token': 'abc123',
  ///   'user_id': '456',
  ///   'is_premium': true,
  /// });
  /// ```
  Future<void> saveAll(Map<String, dynamic> entries);

  /// Get a value from storage.
  ///
  /// Returns null if the key doesn't exist.
  ///
  /// [key] - The storage key
  /// [defaultValue] - Optional default value if key doesn't exist
  ///
  /// Example:
  /// ```dart
  /// final token = await storage.get<String>('token');
  /// final count = await storage.get<int>('count', defaultValue: 0);
  /// ```
  Future<T?> get<T>(String key, {T? defaultValue});

  /// Get an object from storage.
  ///
  /// Returns null if the key doesn't exist.
  /// You may need to provide a custom deserializer for complex objects.
  ///
  /// [key] - The storage key
  ///
  /// Example:
  /// ```dart
  /// final user = await storage.getObject<UserModel>('user');
  /// ```
  Future<T?> getObject<T>(String key);

  /// Check if a key exists in storage.
  ///
  /// [key] - The storage key to check
  ///
  /// Example:
  /// ```dart
  /// if (await storage.containsKey('token')) {
  ///   // Token exists
  /// }
  /// ```
  Future<bool> containsKey(String key);

  /// Delete a value from storage.
  ///
  /// [key] - The storage key to delete
  ///
  /// Example:
  /// ```dart
  /// await storage.delete('token');
  /// ```
  Future<void> delete(String key);

  /// Delete multiple keys from storage.
  ///
  /// [keys] - List of keys to delete
  ///
  /// Example:
  /// ```dart
  /// await storage.deleteAll(['token', 'user_id', 'session']);
  /// ```
  Future<void> deleteAll(List<String> keys);

  /// Clear all data from storage.
  ///
  /// ⚠️ Warning: This will delete ALL data. Use with caution!
  ///
  /// Example:
  /// ```dart
  /// await storage.clear();
  /// ```
  Future<void> clear();

  /// Get all keys in storage.
  ///
  /// Example:
  /// ```dart
  /// final keys = await storage.getAllKeys();
  /// print('Stored keys: $keys');
  /// ```
  Future<List<String>> getAllKeys();

  /// Get all values in storage as a map.
  ///
  /// Example:
  /// ```dart
  /// final allData = await storage.getAllEntries();
  /// print('All data: $allData');
  /// ```
  Future<Map<String, dynamic>> getAllEntries();

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
  /// Example:
  /// ```dart
  /// // Save token that expires in 1 hour
  /// await storage.saveWithExpiration(
  ///   'temp_token',
  ///   'xyz789',
  ///   expiresIn: Duration(hours: 1),
  /// );
  /// ```
  Future<void> saveWithExpiration<T>(
    String key,
    T value, {
    required Duration expiresIn,
  });

  /// Check if a key has expired.
  ///
  /// Returns true if the key has expired or doesn't exist.
  ///
  /// [key] - The storage key to check
  ///
  /// Example:
  /// ```dart
  /// if (await storage.isExpired('temp_token')) {
  ///   // Token has expired, need to refresh
  /// }
  /// ```
  Future<bool> isExpired(String key);

  /// Get storage size in bytes.
  ///
  /// Useful for monitoring storage usage.
  ///
  /// Example:
  /// ```dart
  /// final size = await storage.getSize();
  /// print('Storage size: ${size / 1024} KB');
  /// ```
  Future<int> getSize();

  /// Compact/optimize the storage.
  ///
  /// Some storage implementations may need periodic compaction
  /// to free up space and improve performance.
  ///
  /// Example:
  /// ```dart
  /// await storage.compact();
  /// ```
  Future<void> compact();

  /// Close the storage and release resources.
  ///
  /// Call this when the storage is no longer needed.
  ///
  /// Example:
  /// ```dart
  /// await storage.close();
  /// ```
  Future<void> close();
}
