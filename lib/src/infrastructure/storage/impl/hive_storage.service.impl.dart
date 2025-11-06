import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_core/src/errors/errors.dart';
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
/// - Error handling with Either<Failure, Success>
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
/// final result = await storage.initialize();
/// result.fold(
///   (failure) => print('Init failed: $failure'),
///   (_) => print('Init successful'),
/// );
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
  Future<Either<StorageFailure, void>> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ Storage already initialized');
      return const Right(null);
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
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize storage: $e');
      return Left(
        StorageInitializationFailure(
          message: 'Failed to initialize storage: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'boxName': boxName},
        ),
      );
    }
  }

  /// Get the active box instance.
  Either<StorageFailure, dynamic> get _activeBox {
    if (!_isInitialized) {
      return const Left(
        StorageNotInitializedFailure(
          message: 'Storage not initialized. Call initialize() first.',
        ),
      );
    }
    return Right(useLazyBox ? _lazyBox : _box);
  }

  @override
  Future<Either<StorageFailure, void>> save<T>(String key, T value) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.put(key, value);
            _notifyWatchers(key, value);
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to save $key: $e');
            return Left(
              StorageSaveFailure(
                message: 'Failed to save data: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageSaveFailure(
          message: 'Failed to save data: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> saveObject<T>(
      String key, T value) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            // For complex objects, serialize to JSON
            final jsonString = jsonEncode(value);
            await box.put(key, jsonString);
            _notifyWatchers(key, value);
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to save object $key: $e');
            return Left(
              StorageSerializationFailure(
                message: 'Failed to serialize and save object: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageSaveFailure(
          message: 'Failed to save object: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> saveAll(
      Map<String, dynamic> entries) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.putAll(entries);
            // Notify all watchers
            for (final entry in entries.entries) {
              _notifyWatchers(entry.key, entry.value);
            }
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to save all entries: $e');
            return Left(
              StorageSaveFailure(
                message: 'Failed to save batch data: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageSaveFailure(
          message: 'Failed to save batch data: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, T?>> get<T>(String key,
      {T? defaultValue}) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            final value = await box.get(key, defaultValue: defaultValue);
            return Right(value as T?);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to get $key: $e');
            return Left(
              StorageReadFailure(
                message: 'Failed to read data: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageReadFailure(
          message: 'Failed to read data: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, T?>> getObject<T>(String key) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            final jsonString = await box.get(key);
            if (jsonString == null) return const Right(null);

            // For complex objects, deserialize from JSON
            final decoded = jsonDecode(jsonString as String);
            return Right(decoded as T?);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to get object $key: $e');
            return Left(
              StorageSerializationFailure(
                message: 'Failed to deserialize object: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageReadFailure(
          message: 'Failed to read object: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, bool>> containsKey(String key) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            final contains = await box.containsKey(key);
            return Right(contains);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to check key $key: $e');
            return Left(
              StorageReadFailure(
                message: 'Failed to check key existence: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageReadFailure(
          message: 'Failed to check key existence: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> delete(String key) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.delete(key);
            _notifyWatchers(key, null);
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to delete $key: $e');
            return Left(
              StorageDeleteFailure(
                message: 'Failed to delete data: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'key': key},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageDeleteFailure(
          message: 'Failed to delete data: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> deleteAll(List<String> keys) async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.deleteAll(keys);
            // Notify all watchers
            for (final key in keys) {
              _notifyWatchers(key, null);
            }
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to delete all keys: $e');
            return Left(
              StorageDeleteFailure(
                message: 'Failed to delete multiple keys: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace, 'keys': keys},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageDeleteFailure(
          message: 'Failed to delete multiple keys: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'keys': keys},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> clear() async {
    try {
      final keysResult = await getAllKeys();
      return keysResult.fold(
        (failure) => Left(failure),
        (keys) async {
          final boxResult = _activeBox;
          return boxResult.fold(
            (failure) => Left(failure),
            (box) async {
              try {
                await box.clear();
                // Notify all watchers
                for (final key in keys) {
                  _notifyWatchers(key, null);
                }
                return const Right(null);
              } catch (e, stackTrace) {
                debugPrint('❌ Failed to clear storage: $e');
                return Left(
                  StorageClearFailure(
                    message: 'Failed to clear storage: ${e.toString()}',
                    details: {'error': e, 'stackTrace': stackTrace},
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(
        StorageClearFailure(
          message: 'Failed to clear storage: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, List<String>>> getAllKeys() async {
    try {
      if (!_isInitialized) {
        return const Left(
          StorageNotInitializedFailure(
            message: 'Storage not initialized. Call initialize() first.',
          ),
        );
      }

      if (useLazyBox) {
        return Right(_lazyBox!.keys.cast<String>().toList());
      } else {
        return Right(_box!.keys.cast<String>().toList());
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to get all keys: $e');
      return Left(
        StorageReadFailure(
          message: 'Failed to get all keys: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, Map<String, dynamic>>> getAllEntries() async {
    try {
      final keysResult = await getAllKeys();
      return keysResult.fold(
        (failure) => Left(failure),
        (keys) async {
          final entries = <String, dynamic>{};

          for (final key in keys) {
            final valueResult = await get(key);
            valueResult.fold(
              (failure) {
                // Skip failed keys
                debugPrint('⚠️ Failed to get $key: $failure');
              },
              (value) {
                entries[key] = value;
              },
            );
          }

          return Right(entries);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to get all entries: $e');
      return Left(
        StorageReadFailure(
          message: 'Failed to get all entries: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
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
  Future<Either<StorageFailure, void>> saveWithExpiration<T>(
    String key,
    T value, {
    required Duration expiresIn,
  }) async {
    try {
      final expirationTime =
          DateTime.now().add(expiresIn).millisecondsSinceEpoch;

      // Save value
      final saveResult = await save(key, value);
      return saveResult.fold(
        (failure) => Left(failure),
        (_) async {
          // Save expiration time
          final expirationResult =
              await save('${key}_expiration', expirationTime);
          return expirationResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to save with expiration $key: $e');
      return Left(
        StorageSaveFailure(
          message: 'Failed to save with expiration: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, bool>> isExpired(String key) async {
    try {
      final expirationResult = await get<int>('${key}_expiration');
      return expirationResult.fold(
        (failure) => Left(failure),
        (expirationTime) async {
          if (expirationTime == null) {
            // No expiration set or key doesn't exist
            final containsResult = await containsKey(key);
            return containsResult.fold(
              (failure) => Left(failure),
              (contains) => Right(!contains), // true if key doesn't exist
            );
          }

          final isExpired =
              DateTime.now().millisecondsSinceEpoch > expirationTime;

          // Auto-delete if expired
          if (isExpired) {
            await delete(key);
            await delete('${key}_expiration');
          }

          return Right(isExpired);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to check expiration for $key: $e');
      return Left(
        StorageReadFailure(
          message: 'Failed to check expiration: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace, 'key': key},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, int>> getSize() async {
    try {
      if (!_isInitialized) {
        return const Left(
          StorageNotInitializedFailure(
            message: 'Storage not initialized. Call initialize() first.',
          ),
        );
      }

      if (useLazyBox) {
        // For lazy box, estimate size based on key count
        // (actual size calculation would require loading all values)
        final keyCount = _lazyBox!.keys.length;
        return Right(keyCount * 100); // Rough estimate
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

        return Right(totalSize);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to get storage size: $e');
      return Left(
        StorageReadFailure(
          message: 'Failed to get storage size: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> compact() async {
    try {
      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.compact();
            debugPrint('✅ Storage compacted successfully');
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to compact storage: $e');
            return Left(
              UnknownStorageFailure(
                message: 'Failed to compact storage: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        UnknownStorageFailure(
          message: 'Failed to compact storage: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, void>> close() async {
    try {
      // Close all watch controllers
      for (final controller in _watchControllers.values) {
        await controller.close();
      }
      _watchControllers.clear();

      final boxResult = _activeBox;
      return boxResult.fold(
        (failure) => Left(failure),
        (box) async {
          try {
            await box.close();
            _isInitialized = false;
            debugPrint('✅ Storage closed: $boxName');
            return const Right(null);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to close storage: $e');
            return Left(
              UnknownStorageFailure(
                message: 'Failed to close storage: ${e.toString()}',
                details: {'error': e, 'stackTrace': stackTrace},
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      return Left(
        UnknownStorageFailure(
          message: 'Failed to close storage: ${e.toString()}',
          details: {'error': e, 'stackTrace': stackTrace},
        ),
      );
    }
  }
}
