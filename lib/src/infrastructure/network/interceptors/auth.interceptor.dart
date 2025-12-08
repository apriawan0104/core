import 'package:flutter/foundation.dart';

import '../../../foundation/domain/entities/network/entities.dart';
import '../../authentication/contract/contracts.dart';

/// Authentication interceptor for HTTP requests.
///
/// **Responsibility:**
/// - Automatically inject bearer tokens to HTTP request headers
/// - Skip authentication for public/excluded endpoints
/// - Handle token retrieval failures gracefully
///
/// **Dependency Independence:**
/// - Uses TokenProviderService interface (not tied to any auth provider)
/// - Returns generic RequestOptionsEntity (not Dio-specific types)
/// - Can be used with any HTTP client implementation
///
/// **Features:**
/// - ✅ Automatic token injection to all requests
/// - ✅ Automatic token refresh on expiration (via TokenProvider)
/// - ✅ Skip authentication for specific endpoints (login, register, etc.)
/// - ✅ Configurable excluded paths
/// - ✅ Graceful error handling
///
/// **Security:**
/// - Tokens are retrieved securely from TokenProviderService
/// - No token caching in-memory
/// - Failed token retrieval doesn't block requests (lets server handle 401)
///
/// ## Usage Example
///
/// ```dart
/// // 1. Create interceptor with excluded paths
/// final authInterceptor = AuthInterceptor(
///   tokenProvider: getIt<TokenProviderService>(),
///   excludedPaths: [
///     '/auth/login',
///     '/auth/register',
///     '/auth/forgot-password',
///     '/public',
///   ],
/// );
///
/// // 2. Register with HTTP client
/// final httpClient = DioHttpClient(
///   baseUrl: 'https://api.example.com',
/// );
/// httpClient.addRequestInterceptor(authInterceptor.onRequest);
///
/// // 3. Make requests - token automatically injected!
/// final result = await httpClient.get('/user/profile');
/// // Request header: "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// ```
///
/// ## Error Handling
///
/// If token retrieval fails:
/// - Request continues WITHOUT Authorization header
/// - Server will respond with 401 Unauthorized
/// - Client can handle 401 by redirecting to login
///
/// This approach ensures:
/// - Requests are not blocked by token errors
/// - Server is the source of truth for authentication
/// - Client handles auth errors consistently
class AuthInterceptor {
  final TokenProviderService _tokenProvider;
  final List<String> _excludedPaths;

  /// Create authentication interceptor.
  ///
  /// [tokenProvider] - Service to retrieve access tokens
  /// [excludedPaths] - List of URL paths that don't require authentication
  ///
  /// Example:
  /// ```dart
  /// final interceptor = AuthInterceptor(
  ///   tokenProvider: getIt<TokenProviderService>(),
  ///   excludedPaths: [
  ///     '/auth/login',        // Login endpoint
  ///     '/auth/register',     // Registration endpoint
  ///     '/auth/refresh',      // Token refresh endpoint
  ///     '/public',            // Public content
  ///     '/health',            // Health check
  ///   ],
  /// );
  /// ```
  AuthInterceptor({
    required TokenProviderService tokenProvider,
    List<String>? excludedPaths,
  })  : _tokenProvider = tokenProvider,
        _excludedPaths = excludedPaths ?? [];

  /// Request interceptor function.
  ///
  /// This function is called for every HTTP request before it's sent.
  ///
  /// **Process:**
  /// 1. Check if request URL is in excluded paths
  /// 2. If excluded, return request unchanged
  /// 3. If not excluded, get access token from TokenProvider
  /// 4. Inject token to Authorization header as "Bearer {token}"
  /// 5. Return modified request
  ///
  /// **Error Handling:**
  /// - If token retrieval fails, request continues without token
  /// - Error is logged but doesn't block the request
  /// - Server will handle authentication (401 response)
  ///
  /// [options] - The request options to modify
  ///
  /// Returns modified request options with Authorization header.
  ///
  /// Example:
  /// ```dart
  /// // Register as HTTP client interceptor
  /// httpClient.addRequestInterceptor(authInterceptor.onRequest);
  ///
  /// // For excluded paths (e.g., /auth/login):
  /// // Request: GET /auth/login
  /// // Headers: {} (no Authorization header)
  ///
  /// // For protected paths (e.g., /user/profile):
  /// // Request: GET /user/profile
  /// // Headers: {"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}
  /// ```
  Future<RequestOptionsEntity> onRequest(
    RequestOptionsEntity options,
  ) async {
    // Skip authentication for excluded paths
    if (_shouldSkipAuth(options.url)) {
      return options;
    }

    // Get access token from provider
    final tokenResult = await _tokenProvider.getAccessToken();

    return tokenResult.fold(
      // Token retrieval failed
      (failure) {
        // Log the error for debugging (only in debug mode)
        if (kDebugMode) {
          debugPrint('AuthInterceptor: Failed to get access token: $failure');
        }

        // Continue without Authorization header
        // Let server respond with 401, client will handle redirect to login
        return options;
      },
      // Token retrieved successfully
      (token) {
        // Add bearer token to headers
        final headers = Map<String, dynamic>.from(options.headers ?? {});
        headers['Authorization'] = 'Bearer $token';

        // Return request with updated headers
        return options.copyWith(headers: headers);
      },
    );
  }

  /// Check if authentication should be skipped for this URL.
  ///
  /// Authentication is skipped if the URL contains any of the excluded paths.
  ///
  /// **Matching Strategy:**
  /// - Simple substring matching
  /// - Case-sensitive
  /// - Checks if URL contains the excluded path
  ///
  /// [url] - The request URL to check
  ///
  /// Returns true if authentication should be skipped, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// // Excluded paths: ['/auth/login', '/public']
  ///
  /// _shouldSkipAuth('https://api.example.com/auth/login')
  /// // Returns: true (contains '/auth/login')
  ///
  /// _shouldSkipAuth('https://api.example.com/public/news')
  /// // Returns: true (contains '/public')
  ///
  /// _shouldSkipAuth('https://api.example.com/user/profile')
  /// // Returns: false (doesn't contain any excluded path)
  /// ```
  bool _shouldSkipAuth(String url) {
    return _excludedPaths.any((path) => url.contains(path));
  }

  /// Add a new path to the excluded list.
  ///
  /// Use this to dynamically add paths that shouldn't require authentication.
  ///
  /// [path] - The path pattern to exclude
  ///
  /// Example:
  /// ```dart
  /// authInterceptor.addExcludedPath('/new-public-endpoint');
  /// ```
  void addExcludedPath(String path) {
    if (!_excludedPaths.contains(path)) {
      _excludedPaths.add(path);
    }
  }

  /// Remove a path from the excluded list.
  ///
  /// [path] - The path pattern to remove
  ///
  /// Example:
  /// ```dart
  /// authInterceptor.removeExcludedPath('/no-longer-public');
  /// ```
  void removeExcludedPath(String path) {
    _excludedPaths.remove(path);
  }

  /// Get current list of excluded paths.
  ///
  /// Returns a copy of the excluded paths list.
  ///
  /// Example:
  /// ```dart
  /// final paths = authInterceptor.getExcludedPaths();
  /// print('Excluded: $paths');
  /// ```
  List<String> getExcludedPaths() {
    return List.unmodifiable(_excludedPaths);
  }
}
