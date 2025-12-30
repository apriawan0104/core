import 'package:dartz/dartz.dart';
import 'package:app_core/src/errors/errors.dart';
import 'package:app_core/src/infrastructure/secure_storage/models/models.dart';

/// Abstract contract for secure storage service.
///
/// This interface provides a standardized way to store sensitive data securely
/// across different platforms (iOS Keychain, Android KeyStore, etc.).
///
/// **Dependency Independence**: This interface does NOT depend on any
/// specific secure storage package (flutter_secure_storage, etc.).
/// Consumer apps can use any secure storage provider by creating
/// implementations of this interface.
///
/// **Use Cases:**
/// - Store authentication tokens
/// - Store API keys
/// - Store user credentials
/// - Store encryption keys
/// - Store sensitive user data
///
/// **Security Features:**
/// - Data encrypted at rest
/// - Platform-specific secure storage (Keychain/KeyStore)
/// - No plain-text storage
/// - Secure deletion
///
/// **Platform Support:**
/// - iOS: Keychain
/// - Android: KeyStore (or EncryptedSharedPreferences)
/// - Linux: libsecret
/// - macOS: Keychain
/// - Windows: Credential Manager
/// - Web: WebCrypto (experimental)
///
/// Example usage:
/// ```dart
/// final secureStorage = getIt<SecureStorageService>();
///
/// // Write secure data
/// final writeResult = await secureStorage.write(
///   key: 'auth_token',
///   value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
///   options: SecureStorageOptions(
///     accessibility: KeychainAccessibility.firstUnlock,
///   ),
/// );
///
/// writeResult.fold(
///   (failure) => print('Error: $failure'),
///   (_) => print('Token saved securely'),
/// );
///
/// // Read secure data
/// final readResult = await secureStorage.read(key: 'auth_token');
/// readResult.fold(
///   (failure) => print('Error: $failure'),
///   (token) => print('Token: $token'),
/// );
///
/// // Delete secure data
/// await secureStorage.delete(key: 'auth_token');
/// ```
abstract class SecureStorageService {
  /// Write a value to secure storage.
  ///
  /// Stores the value securely using platform-specific secure storage:
  /// - iOS/macOS: Keychain
  /// - Android: KeyStore or EncryptedSharedPreferences
  /// - Linux: libsecret
  /// - Windows: Credential Manager
  /// - Web: WebCrypto
  ///
  /// [key] - The storage key (must be non-empty)
  /// [value] - The value to store (will be stored as string)
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// // Simple write
  /// await secureStorage.write(
  ///   key: 'api_key',
  ///   value: 'sk_test_123456',
  /// );
  ///
  /// // Write with iOS accessibility options
  /// await secureStorage.write(
  ///   key: 'refresh_token',
  ///   value: 'refresh_xyz',
  ///   options: SecureStorageOptions(
  ///     accessibility: KeychainAccessibility.firstUnlockThisDeviceOnly,
  ///   ),
  /// );
  ///
  /// // Write with Android EncryptedSharedPreferences
  /// await secureStorage.write(
  ///   key: 'user_pin',
  ///   value: '1234',
  ///   options: SecureStorageOptions(
  ///     useEncryptedSharedPreferences: true,
  ///   ),
  /// );
  /// ```
  Future<Either<SecureStorageFailure, void>> write({
    required String key,
    required String value,
    SecureStorageOptions? options,
  });

  /// Read a value from secure storage.
  ///
  /// Retrieves the value associated with the key from secure storage.
  ///
  /// [key] - The storage key
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, String?> - null if key doesn't exist
  ///
  /// Example:
  /// ```dart
  /// final result = await secureStorage.read(key: 'api_key');
  /// result.fold(
  ///   (failure) => print('Error reading: $failure'),
  ///   (value) {
  ///     if (value != null) {
  ///       print('API Key: $value');
  ///     } else {
  ///       print('API Key not found');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<SecureStorageFailure, String?>> read({
    required String key,
    SecureStorageOptions? options,
  });

  /// Read all values from secure storage.
  ///
  /// Retrieves all key-value pairs stored in secure storage.
  ///
  /// ⚠️ Use with caution: may expose multiple sensitive values at once.
  ///
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, Map<String, String>>
  ///
  /// Example:
  /// ```dart
  /// final result = await secureStorage.readAll();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (allData) {
  ///     print('Total secure items: ${allData.length}');
  ///     allData.forEach((key, value) {
  ///       print('$key: ${value.substring(0, 10)}...');
  ///     });
  ///   },
  /// );
  /// ```
  Future<Either<SecureStorageFailure, Map<String, String>>> readAll({
    SecureStorageOptions? options,
  });

  /// Delete a value from secure storage.
  ///
  /// Securely removes the value associated with the key.
  ///
  /// [key] - The storage key to delete
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// // Delete after logout
  /// await secureStorage.delete(key: 'auth_token');
  /// await secureStorage.delete(key: 'refresh_token');
  /// ```
  Future<Either<SecureStorageFailure, void>> delete({
    required String key,
    SecureStorageOptions? options,
  });

  /// Delete all values from secure storage.
  ///
  /// ⚠️ WARNING: This will delete ALL secure data. Use with extreme caution!
  ///
  /// Typically used when:
  /// - User logs out completely
  /// - User deletes account
  /// - Factory reset / clear all data
  ///
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, void>
  ///
  /// Example:
  /// ```dart
  /// // Complete logout
  /// await secureStorage.deleteAll();
  /// print('All secure data cleared');
  /// ```
  Future<Either<SecureStorageFailure, void>> deleteAll({
    SecureStorageOptions? options,
  });

  /// Check if a key exists in secure storage.
  ///
  /// Useful to check if data exists without reading the actual value.
  ///
  /// [key] - The storage key to check
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, bool>
  ///
  /// Example:
  /// ```dart
  /// final result = await secureStorage.containsKey(key: 'auth_token');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (exists) {
  ///     if (exists) {
  ///       // User is logged in
  ///       navigateToHome();
  ///     } else {
  ///       // User is not logged in
  ///       navigateToLogin();
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<SecureStorageFailure, bool>> containsKey({
    required String key,
    SecureStorageOptions? options,
  });

  /// Get all keys stored in secure storage.
  ///
  /// Returns list of all keys (but not values) for inventory/debugging.
  ///
  /// [options] - Optional platform-specific options
  ///
  /// Returns Either<SecureStorageFailure, List<String>>
  ///
  /// Example:
  /// ```dart
  /// final result = await secureStorage.getAllKeys();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (keys) {
  ///     print('Secure storage contains: $keys');
  ///     // Example output: [auth_token, refresh_token, api_key]
  ///   },
  /// );
  /// ```
  Future<Either<SecureStorageFailure, List<String>>> getAllKeys({
    SecureStorageOptions? options,
  });
}
