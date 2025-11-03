import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage.constant.dart';
import '../contract/storage.service.dart';

/// Hive-based implementation of [StorageService].
///
/// This implementation uses Hive for local storage. Hive is a lightweight
/// and blazing fast key-value database written in pure Dart.
///
/// **Features:**
/// - Fast read/write operations
/// - Type-safe storage
/// - Lazy loading
/// - Encryption support (via encryptionCipher)
/// - Watch for changes
/// - Automatic compaction
///
/// **Use cases:**
/// - General purpose local storage
/// - Caching API responses
/// - Storing user preferences
/// - Saving app state
///
/// Example usage:
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<StorageService>(
///   () => HiveStorageServiceImpl(
///     boxName: StorageConstants.defaultBoxName,
///   ),
/// );
///
/// // Initialize before use
/// final storage = getIt<StorageService>();
/// await storage.initialize();
/// ```
///
/// For encrypted storage:
/// ```dart
/// // Generate encryption key (store this securely!)
/// final encryptionKey = Hive.generateSecureKey();
///
/// getIt.registerLazySingleton<StorageService>(
///   () => HiveStorageServiceImpl(
///     boxName: StorageConstants.secureBoxName,
///     encryptionCipher: HiveAesCipher(encryptionKey),
///   ),
/// );
/// ```
class HiveStorageServiceImpl implements StorageService {
  /// The name of the Hive box to use.
  final String boxName;

  /// Optional encryption cipher for secure storage.
  ///
  /// If provided, all data will be encrypted before storage.
  final HiveCipher? encryptionCipher;

  /// Whether to use lazy box (recommended for large datasets).
  ///
  /// Lazy boxes don't load the complete box into memory when opened.
  final bool useLazyBox;

  /// The Hive box instance.
  Box? _box;

  /// The lazy Hive box instance.
  LazyBox? _lazyBox;

  /// Whether the storage is initialized.
  bool _isInitialized = false;

  /// Stream controllers for watching keys.
  final Map<String, StreamController<dynamic>> _watchControllers = {};

  /// Create Hive storage service.
  ///
  /// [boxName] - Name of the Hive box to use
  /// [encryptionCipher] - Optional encryption cipher for secure storage
  /// [useLazyBox] - Whether to use lazy box (default: false)
  HiveStorageServiceImpl({
    this.boxName = StorageConstants.defaultBoxName,
    this.encryptionCipher,
    this.useLazyBox = false,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ Storage already initialized');
      return;
    }

    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Open box (regular or lazy)
      if (useLazyBox) {
        _lazyBox = await Hive.openLazyBox(
          boxName,
          encryptionCipher: encryptionCipher,
        );
      } else {
        _box = await Hive.openBox(
          boxName,
          encryptionCipher: encryptionCipher,
        );
      }

      _isInitialized = true;
      debugPrint('✅ Storage initialized: $boxName');
    } catch (e, st) {
      debugPrint('❌ Failed to initialize storage: $e');
      debugPrint('Stack trace: $st');
      rethrow;
    }
  }

  /// Get the active box instance.
  dynamic get _activeBox {
    if (!_isInitialized) {
      throw StateError(
        'Storage not initialized. Call initialize() first.',
      );
    }
    return useLazyBox ? _lazyBox : _box;
  }

  @override
  Future<void> save<T>(String key, T value) async {
    try {
      await _activeBox.put(key, value);
      _notifyWatchers(key, value);
    } catch (e) {
      debugPrint('❌ Failed to save $key: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveObject<T>(String key, T value) async {
    try {
      // For complex objects, serialize to JSON
      final jsonString = jsonEncode(value);
      await _activeBox.put(key, jsonString);
      _notifyWatchers(key, value);
    } catch (e) {
      debugPrint('❌ Failed to save object $key: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAll(Map<String, dynamic> entries) async {
    try {
      await _activeBox.putAll(entries);
      // Notify all watchers
      for (final entry in entries.entries) {
        _notifyWatchers(entry.key, entry.value);
      }
    } catch (e) {
      debugPrint('❌ Failed to save all entries: $e');
      rethrow;
    }
  }

  @override
  Future<T?> get<T>(String key, {T? defaultValue}) async {
    try {
      final value = await _activeBox.get(key, defaultValue: defaultValue);
      return value as T?;
    } catch (e) {
      debugPrint('❌ Failed to get $key: $e');
      return defaultValue;
    }
  }

  @override
  Future<T?> getObject<T>(String key) async {
    try {
      final jsonString = await _activeBox.get(key);
      if (jsonString == null) return null;

      // For complex objects, deserialize from JSON
      final decoded = jsonDecode(jsonString as String);
      return decoded as T?;
    } catch (e) {
      debugPrint('❌ Failed to get object $key: $e');
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _activeBox.containsKey(key);
    } catch (e) {
      debugPrint('❌ Failed to check key $key: $e');
      return false;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _activeBox.delete(key);
      _notifyWatchers(key, null);
    } catch (e) {
      debugPrint('❌ Failed to delete $key: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    try {
      await _activeBox.deleteAll(keys);
      // Notify all watchers
      for (final key in keys) {
        _notifyWatchers(key, null);
      }
    } catch (e) {
      debugPrint('❌ Failed to delete all keys: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final keys = await getAllKeys();
      await _activeBox.clear();
      // Notify all watchers
      for (final key in keys) {
        _notifyWatchers(key, null);
      }
    } catch (e) {
      debugPrint('❌ Failed to clear storage: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      if (useLazyBox) {
        return _lazyBox!.keys.cast<String>().toList();
      } else {
        return _box!.keys.cast<String>().toList();
      }
    } catch (e) {
      debugPrint('❌ Failed to get all keys: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getAllEntries() async {
    try {
      final keys = await getAllKeys();
      final entries = <String, dynamic>{};

      for (final key in keys) {
        final value = await get(key);
        entries[key] = value;
      }

      return entries;
    } catch (e) {
      debugPrint('❌ Failed to get all entries: $e');
      return {};
    }
  }

  @override
  Stream<T?> watch<T>(String key) {
    // Create controller if not exists
    if (!_watchControllers.containsKey(key)) {
      _watchControllers[key] = StreamController<T?>.broadcast(
        onCancel: () {
          // Clean up controller when no more listeners
          _watchControllers[key]?.close();
          _watchControllers.remove(key);
        },
      );
    }

    return _watchControllers[key]!.stream as Stream<T?>;
  }

  /// Notify watchers when a value changes.
  void _notifyWatchers(String key, dynamic value) {
    if (_watchControllers.containsKey(key)) {
      if (!_watchControllers[key]!.isClosed) {
        _watchControllers[key]!.add(value);
      }
    }
  }

  @override
  Future<void> saveWithExpiration<T>(
    String key,
    T value, {
    required Duration expiresIn,
  }) async {
    try {
      final expirationTime =
          DateTime.now().add(expiresIn).millisecondsSinceEpoch;

      // Save value
      await save(key, value);

      // Save expiration time
      await save('${key}_expiration', expirationTime);
    } catch (e) {
      debugPrint('❌ Failed to save with expiration $key: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isExpired(String key) async {
    try {
      final expirationTime = await get<int>('${key}_expiration');

      if (expirationTime == null) {
        // No expiration set or key doesn't exist
        return await containsKey(key) == false;
      }

      final isExpired = DateTime.now().millisecondsSinceEpoch > expirationTime;

      // Auto-delete if expired
      if (isExpired) {
        await delete(key);
        await delete('${key}_expiration');
      }

      return isExpired;
    } catch (e) {
      debugPrint('❌ Failed to check expiration for $key: $e');
      return true; // Assume expired on error
    }
  }

  @override
  Future<int> getSize() async {
    try {
      if (useLazyBox) {
        // For lazy box, estimate size based on key count
        // (actual size calculation would require loading all values)
        final keyCount = _lazyBox!.keys.length;
        return keyCount * 100; // Rough estimate
      } else {
        // For regular box, we can calculate more accurately
        var totalSize = 0;

        for (final key in _box!.keys) {
          final value = _box!.get(key);
          if (value != null) {
            // Rough size estimation
            totalSize += key.toString().length;
            totalSize += value.toString().length;
          }
        }

        return totalSize;
      }
    } catch (e) {
      debugPrint('❌ Failed to get storage size: $e');
      return 0;
    }
  }

  @override
  Future<void> compact() async {
    try {
      await _activeBox.compact();
      debugPrint('✅ Storage compacted successfully');
    } catch (e) {
      debugPrint('❌ Failed to compact storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    try {
      // Close all watch controllers
      for (final controller in _watchControllers.values) {
        await controller.close();
      }
      _watchControllers.clear();

      // Close box
      await _activeBox.close();

      _isInitialized = false;
      debugPrint('✅ Storage closed: $boxName');
    } catch (e) {
      debugPrint('❌ Failed to close storage: $e');
      rethrow;
    }
  }
}
