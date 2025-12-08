import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';
import '../models/models.dart';

/// Token provider service interface
///
/// Provides bearer tokens for authenticated HTTP requests.
/// This interface is independent of any specific authentication provider.
///
/// **Dependency Independence**:
/// - No third-party types exposed in public API
/// - Easy to implement with any auth system (Google, Azure, Firebase, Custom Backend)
/// - Can switch authentication providers without affecting HTTP client
/// - Multiple implementations can coexist
///
/// **Use Cases:**
/// - Inject bearer token to HTTP requests automatically
/// - Refresh expired tokens automatically
/// - Handle token expiration gracefully
/// - Cache tokens securely for performance
///
/// **Design Philosophy:**
/// This service acts as a bridge between authentication and networking layers:
/// - Authentication layer: Handles sign in/out, token generation
/// - Token Provider: Handles token retrieval, caching, refresh logic
/// - HTTP Client: Consumes tokens via interceptors
///
/// ## Usage Example
///
/// ```dart
/// // Get access token for API request
/// final tokenProvider = getIt<TokenProviderService>();
///
/// final tokenResult = await tokenProvider.getAccessToken();
/// tokenResult.fold(
///   (failure) => print('Not authenticated: $failure'),
///   (token) => print('Token: $token'),
/// );
///
/// // Check if user has valid token
/// final isValid = await tokenProvider.hasValidToken();
/// isValid.fold(
///   (failure) => print('Error: $failure'),
///   (valid) => print('Has valid token: $valid'),
/// );
///
/// // Clear tokens on logout
/// await tokenProvider.clearTokens();
/// ```
///
/// ## Implementation Examples
///
/// - [TokenProviderServiceImpl] - Default implementation using AuthenticationService
///
/// ## Error Handling
///
/// All methods return `Either<Failure, T>` for consistent error handling:
/// - Left(AuthenticationFailure) - When authentication operation fails
/// - Right(value) - When operation succeeds
abstract class TokenProviderService {
  /// Get current valid access token.
  ///
  /// Returns the current access token if available and valid.
  /// Automatically refreshes the token if it's expired or about to expire.
  ///
  /// **Behavior:**
  /// 1. Check if user is signed in
  /// 2. Try to get cached token from secure storage
  /// 3. Validate token expiration
  /// 4. If expired, automatically refresh token
  /// 5. Return valid token
  ///
  /// **Performance:**
  /// - First call: Fetches from auth service (slower)
  /// - Subsequent calls: Returns cached token from secure storage (fast)
  /// - Auto-refresh: Only when token is expired or near expiry
  ///
  /// Returns:
  /// - Right(String) - Valid access token (Bearer token value)
  /// - Left(AuthenticationFailure) - No token available or refresh failed
  /// - Left(NetworkFailure) - Network error during refresh
  ///
  /// Example:
  /// ```dart
  /// final result = await tokenProvider.getAccessToken();
  /// result.fold(
  ///   (failure) {
  ///     if (failure is AuthenticationFailure) {
  ///       // User not logged in, redirect to login
  ///       navigateToLogin();
  ///     }
  ///   },
  ///   (token) {
  ///     // Use token for API request
  ///     final headers = {'Authorization': 'Bearer $token'};
  ///   },
  /// );
  /// ```
  Future<Either<Failure, String>> getAccessToken();

  /// Get full authentication token information.
  ///
  /// Returns complete token data including:
  /// - Access token
  /// - Refresh token
  /// - ID token
  /// - Token type (usually "Bearer")
  /// - Expiration time
  /// - Scopes
  ///
  /// Use this when you need more than just the access token,
  /// for example to display token expiry time in UI or to manually
  /// refresh tokens.
  ///
  /// Returns:
  /// - Right(AuthToken) - Complete token data
  /// - Left(AuthenticationFailure) - No token available
  ///
  /// Example:
  /// ```dart
  /// final result = await tokenProvider.getAuthToken();
  /// result.fold(
  ///   (failure) => print('No token: $failure'),
  ///   (token) {
  ///     print('Access Token: ${token.accessToken}');
  ///     print('Expires At: ${token.expiresAt}');
  ///     print('Is Valid: ${token.isValid}');
  ///     print('Time Until Expiry: ${token.timeUntilExpiry}');
  ///   },
  /// );
  /// ```
  Future<Either<Failure, AuthToken>> getAuthToken();

  /// Check if user has a valid token.
  ///
  /// Quickly check authentication status without fetching the token.
  /// Useful for:
  /// - Showing/hiding UI elements based on auth state
  /// - Route guards
  /// - Conditional logic based on authentication
  ///
  /// **Performance:**
  /// This is a lightweight check that only validates:
  /// - User is signed in
  /// - Token exists in storage
  /// - Token is not expired
  ///
  /// It does NOT fetch or refresh the token.
  ///
  /// Returns:
  /// - Right(true) - User has valid token
  /// - Right(false) - No token or token expired
  /// - Left(Failure) - Error checking token status
  ///
  /// Example:
  /// ```dart
  /// final result = await tokenProvider.hasValidToken();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (hasToken) {
  ///     if (hasToken) {
  ///       // User is authenticated
  ///       showAuthenticatedContent();
  ///     } else {
  ///       // User needs to login
  ///       showLoginPrompt();
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<Failure, bool>> hasValidToken();

  /// Clear all cached tokens from storage.
  ///
  /// **IMPORTANT:** Call this when user logs out to:
  /// - Remove all authentication tokens from secure storage
  /// - Clear any in-memory token cache
  /// - Ensure user cannot make authenticated requests
  ///
  /// **Security:**
  /// - Tokens are permanently deleted from secure storage
  /// - Cannot be recovered after clearing
  /// - Should be called before or after AuthenticationService.signOut()
  ///
  /// Clears:
  /// - Access token
  /// - Refresh token
  /// - ID token
  /// - Token expiry time
  /// - Token type
  ///
  /// Returns:
  /// - Right(void) - Tokens cleared successfully
  /// - Left(Failure) - Failed to clear tokens (should log this error)
  ///
  /// Example:
  /// ```dart
  /// // On logout
  /// Future<void> logout() async {
  ///   final authService = getIt<AuthenticationService>();
  ///   final tokenProvider = getIt<TokenProviderService>();
  ///
  ///   // Sign out from auth provider
  ///   await authService.signOut();
  ///
  ///   // Clear cached tokens
  ///   await tokenProvider.clearTokens();
  ///
  ///   // Navigate to login
  ///   navigateToLogin();
  /// }
  /// ```
  Future<Either<Failure, void>> clearTokens();

  /// Refresh the current authentication token.
  ///
  /// Manually trigger token refresh. Usually you don't need to call this
  /// directly as [getAccessToken] automatically refreshes expired tokens.
  ///
  /// Use this when:
  /// - You want to proactively refresh token before expiry
  /// - You want to handle refresh errors explicitly
  /// - You're implementing custom token refresh logic
  ///
  /// Returns:
  /// - Right(AuthToken) - New refreshed token
  /// - Left(AuthenticationFailure) - Refresh failed, user needs to re-login
  ///
  /// Example:
  /// ```dart
  /// // Proactively refresh token
  /// final result = await tokenProvider.refreshToken();
  /// result.fold(
  ///   (failure) {
  ///     // Refresh failed, force re-login
  ///     await logout();
  ///     navigateToLogin();
  ///   },
  ///   (newToken) {
  ///     print('Token refreshed successfully');
  ///     print('New expiry: ${newToken.expiresAt}');
  ///   },
  /// );
  /// ```
  Future<Either<Failure, AuthToken>> refreshToken();

  /// Get the refresh token if available.
  ///
  /// Returns the refresh token for use in custom authentication flows.
  /// Most apps won't need this as token refresh is handled automatically.
  ///
  /// Returns:
  /// - Right(String) - Refresh token value
  /// - Right(null) - No refresh token available
  /// - Left(Failure) - Error retrieving refresh token
  ///
  /// Example:
  /// ```dart
  /// final result = await tokenProvider.getRefreshToken();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (refreshToken) {
  ///     if (refreshToken != null) {
  ///       print('Refresh token: $refreshToken');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<Failure, String?>> getRefreshToken();
}
