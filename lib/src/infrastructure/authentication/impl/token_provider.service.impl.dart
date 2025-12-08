import 'package:dartz/dartz.dart';

import '../../../errors/errors.dart';
import '../../secure_storage/contract/contracts.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Token provider implementation using AuthenticationService and SecureStorageService.
///
/// **Responsibilities:**
/// - Retrieve access tokens from authentication service
/// - Cache tokens in secure storage for performance
/// - Validate token expiration
/// - Automatically refresh expired tokens
/// - Clear tokens on logout
///
/// **Storage Strategy:**
/// - Tokens are stored in platform-specific secure storage:
///   - iOS/macOS: Keychain (hardware-encrypted)
///   - Android: KeyStore (hardware-encrypted)
///   - Windows: Credential Manager
///   - Linux: libsecret
///
/// **Performance Optimization:**
/// - First token request: Fetches from auth service
/// - Subsequent requests: Returns from cache (fast)
/// - Token refresh: Only when expired or near expiry
///
/// **Token Expiry Strategy:**
/// - Tokens are considered expired if less than 5 minutes remaining
/// - This buffer ensures tokens don't expire during API requests
/// - Automatic refresh happens transparently
///
/// Example usage:
/// ```dart
/// // Register in DI
/// getIt.registerLazySingleton<TokenProviderService>(
///   () => TokenProviderServiceImpl(
///     authService: getIt<AuthenticationService>(),
///     secureStorage: getIt<SecureStorageService>(),
///   ),
/// );
///
/// // Use in app
/// final tokenProvider = getIt<TokenProviderService>();
/// final token = await tokenProvider.getAccessToken();
/// ```
class TokenProviderServiceImpl implements TokenProviderService {
  final AuthenticationService _authService;
  final SecureStorageService _secureStorage;

  /// Storage keys for tokens
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _idTokenKey = 'auth_id_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _tokenTypeKey = 'auth_token_type';

  /// Buffer time before token expiry to trigger refresh
  /// Tokens are considered expired if less than this time remaining
  static const Duration _expiryBufferTime = Duration(minutes: 5);

  TokenProviderServiceImpl({
    required AuthenticationService authService,
    required SecureStorageService secureStorage,
  })  : _authService = authService,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      // 1. Check if user is signed in
      final isSignedInResult = await _authService.isSignedIn();

      return await isSignedInResult.fold(
        (failure) => Left(failure),
        (isSignedIn) async {
          if (!isSignedIn) {
            return const Left(
              AuthenticationFailure('User not signed in'),
            );
          }

          // 2. Check if cached token is still valid
          final isValidResult = await _isTokenValid();
          final isValid = isValidResult.getOrElse(() => false);

          if (isValid) {
            // 3. Return cached token if valid
            final cachedTokenResult = await _secureStorage.read(
              key: _accessTokenKey,
            );

            return cachedTokenResult.fold(
              (failure) => _fetchAndCacheToken(),
              (token) {
                if (token != null && token.isNotEmpty) {
                  return Right(token);
                }
                return _fetchAndCacheToken();
              },
            );
          }

          // 4. Token expired or not cached, refresh it
          return await _refreshAndCacheToken();
        },
      );
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get access token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthToken>> getAuthToken() async {
    try {
      final tokenResult = await _authService.getAuthToken();

      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          // Cache token to secure storage for future use
          await _cacheToken(token);
          return Right(token);
        },
      );
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get auth token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> hasValidToken() async {
    try {
      // 1. Check if user is signed in
      final isSignedInResult = await _authService.isSignedIn();

      return isSignedInResult.fold(
        (failure) => Left(failure),
        (isSignedIn) async {
          if (!isSignedIn) return const Right(false);

          // 2. Check if token exists and is valid
          return await _isTokenValid();
        },
      );
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to check token validity: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      // Delete all tokens from secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _tokenExpiryKey);
      await _secureStorage.delete(key: _tokenTypeKey);

      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to clear tokens: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    try {
      final refreshResult = await _authService.refreshToken();

      return refreshResult.fold(
        (failure) => Left(failure),
        (token) async {
          // Cache refreshed token
          await _cacheToken(token);
          return Right(token);
        },
      );
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to refresh token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final tokenResult = await _secureStorage.read(
        key: _refreshTokenKey,
      );

      return tokenResult.fold(
        (failure) => Left(failure),
        (token) => Right(token),
      );
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get refresh token: $e'),
      );
    }
  }

  // ============== Private Helper Methods ==============

  /// Fetch new token from auth service and cache it
  Future<Either<Failure, String>> _fetchAndCacheToken() async {
    final tokenResult = await _authService.getAuthToken();

    return tokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        await _cacheToken(token);
        return Right(token.accessToken);
      },
    );
  }

  /// Refresh token and cache it
  Future<Either<Failure, String>> _refreshAndCacheToken() async {
    final refreshResult = await _authService.refreshToken();

    return refreshResult.fold(
      (failure) => Left(failure),
      (token) async {
        await _cacheToken(token);
        return Right(token.accessToken);
      },
    );
  }

  /// Cache token to secure storage
  ///
  /// Stores all token components securely:
  /// - Access token (required)
  /// - Refresh token (optional)
  /// - ID token (optional)
  /// - Token type (optional)
  /// - Expiry time (optional)
  Future<void> _cacheToken(AuthToken token) async {
    // Store access token (encrypted by SecureStorage)
    await _secureStorage.write(
      key: _accessTokenKey,
      value: token.accessToken,
    );

    // Store refresh token if available
    if (token.refreshToken != null) {
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: token.refreshToken!,
      );
    }

    // Store ID token if available
    if (token.idToken != null) {
      await _secureStorage.write(
        key: _idTokenKey,
        value: token.idToken!,
      );
    }

    // Store token type if available
    if (token.tokenType != null) {
      await _secureStorage.write(
        key: _tokenTypeKey,
        value: token.tokenType!,
      );
    }

    // Store expiry time if available
    if (token.expiresAt != null) {
      await _secureStorage.write(
        key: _tokenExpiryKey,
        value: token.expiresAt!.toIso8601String(),
      );
    }
  }

  /// Check if cached token is still valid
  ///
  /// Token is considered valid if:
  /// 1. Token exists in storage
  /// 2. Expiry time is set
  /// 3. Current time is before (expiry - buffer time)
  ///
  /// Buffer time ensures tokens don't expire during API requests.
  Future<Either<Failure, bool>> _isTokenValid() async {
    // Check if access token exists
    final tokenExistsResult = await _secureStorage.containsKey(
      key: _accessTokenKey,
    );

    final tokenExists = tokenExistsResult.getOrElse(() => false);
    if (!tokenExists) {
      return const Right(false);
    }

    // Check expiry time
    final expiryResult = await _secureStorage.read(
      key: _tokenExpiryKey,
    );

    return expiryResult.fold(
      (failure) => const Right(false),
      (expiryString) {
        if (expiryString == null || expiryString.isEmpty) {
          // No expiry time set, assume token is valid
          // (Some auth systems don't provide expiry time)
          return const Right(true);
        }

        try {
          final expiryDate = DateTime.parse(expiryString);
          final now = DateTime.now();

          // Token is valid if current time is before (expiry - buffer)
          // Buffer ensures we refresh before actual expiry
          final isValid = now.isBefore(expiryDate.subtract(_expiryBufferTime));

          return Right(isValid);
        } catch (e) {
          // Failed to parse expiry time, assume invalid
          return const Right(false);
        }
      },
    );
  }
}
