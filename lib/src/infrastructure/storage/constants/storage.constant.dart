/// Constants for storage service.
///
/// Contains default values and configuration constants used by storage
/// implementations.
class StorageConstants {
  StorageConstants._();

  /// Default box name for Hive storage.
  ///
  /// Used when no custom box name is provided.
  static const String defaultBoxName = 'app_storage';

  /// Box name for secure storage (encrypted).
  ///
  /// Used for storing sensitive data like tokens, passwords, etc.
  static const String secureBoxName = 'secure_storage';

  /// Box name for user preferences.
  ///
  /// Used for storing user settings and preferences.
  static const String preferencesBoxName = 'preferences';

  /// Box name for cache data.
  ///
  /// Used for temporary cached data that can be cleared.
  static const String cacheBoxName = 'cache';

  /// Maximum cache age in milliseconds (7 days).
  ///
  /// Data older than this will be considered stale.
  static const int maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7 days

  /// Encryption key length for secure storage (256 bits).
  static const int encryptionKeyLength = 32;

  /// Storage error codes.
  static const String errorCodeNotFound = 'STORAGE_NOT_FOUND';
  static const String errorCodeWriteFailed = 'STORAGE_WRITE_FAILED';
  static const String errorCodeReadFailed = 'STORAGE_READ_FAILED';
  static const String errorCodeDeleteFailed = 'STORAGE_DELETE_FAILED';
  static const String errorCodeInitFailed = 'STORAGE_INIT_FAILED';
  static const String errorCodeEncryptionFailed = 'STORAGE_ENCRYPTION_FAILED';
}
