/// Secure Storage module exports
///
/// Provides secure storage service for sensitive data across all platforms:
/// - iOS: Keychain
/// - Android: KeyStore or EncryptedSharedPreferences
/// - Linux: libsecret
/// - macOS: Keychain
/// - Windows: Credential Manager
/// - Web: WebCrypto (experimental)
///
/// **Dependency Independence**: This module wraps flutter_secure_storage
/// but does NOT expose any third-party types in the public API.
///
/// Example usage:
/// ```dart
/// // 1. Register in DI
/// getIt.registerLazySingleton<SecureStorageService>(
///   () => FlutterSecureStorageServiceImpl(
///     options: SecureStorageOptions.balanced(),
///   ),
/// );
///
/// // 2. Use in your app
/// final secureStorage = getIt<SecureStorageService>();
///
/// // Save token
/// await secureStorage.write(
///   key: SecureStorageConstants.authToken,
///   value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
/// );
///
/// // Read token
/// final result = await secureStorage.read(
///   key: SecureStorageConstants.authToken,
/// );
///
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (token) => print('Token: $token'),
/// );
/// ```
library secure_storage;

// Contracts
export 'contract/contracts.dart';

// Models
export 'models/models.dart';

// Constants
export 'constants/constants.dart';

// Implementations
export 'impl/impl.dart';

