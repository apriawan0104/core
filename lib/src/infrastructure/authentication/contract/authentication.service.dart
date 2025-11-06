import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';
import '../models/models.dart';

/// Abstract interface for authentication services.
///
/// This interface provides a dependency-independent abstraction for authentication.
/// It can be implemented by any authentication provider (Google, Apple, Azure, Firebase, etc.)
/// without exposing their specific APIs.
///
/// ## Design Philosophy
///
/// This service follows the Dependency Independence principle:
/// - No third-party types exposed in public API
/// - Easy to switch between authentication providers
/// - Multiple implementations can coexist
/// - Testable with mock implementations
///
/// ## Usage Example
///
/// ```dart
/// // Sign in with Google
/// final result = await authService.signInWithGoogle();
/// result.fold(
///   (failure) => print('Sign in failed: $failure'),
///   (credentials) => print('Signed in: ${credentials.user.email}'),
/// );
///
/// // Get current user
/// final userResult = await authService.getCurrentUser();
/// userResult.fold(
///   (failure) => print('Not signed in'),
///   (user) => print('Current user: ${user?.email}'),
/// );
///
/// // Sign out
/// await authService.signOut();
/// ```
///
/// ## Implementation Examples
///
/// - [GoogleAuthenticationServiceImpl] - Google Sign In implementation
/// - [AppleAuthenticationServiceImpl] - Apple Sign In implementation
/// - [AzureAuthenticationServiceImpl] - Azure AD OAuth implementation
///
/// ## Error Handling
///
/// All methods return `Either<Failure, T>` for consistent error handling:
/// - Left(AuthenticationFailure) - When authentication operation fails
/// - Right(value) - When operation succeeds
abstract class AuthenticationService {
  /// Initializes the authentication service.
  ///
  /// Must be called before any other methods. Configure the service with
  /// client IDs, redirect URIs, and other settings via constructor injection
  /// in the implementation.
  ///
  /// Returns:
  /// - Right(void) - Initialization successful
  /// - Left(AuthenticationFailure) - Initialization failed
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.initialize();
  /// result.fold(
  ///   (failure) => print('Failed to initialize: $failure'),
  ///   (_) => print('Auth service initialized'),
  /// );
  /// ```
  Future<Either<Failure, void>> initialize();

  /// Sign in with Google.
  ///
  /// Opens Google Sign In flow and returns user credentials on success.
  ///
  /// [scopes] - Optional list of OAuth scopes to request
  /// [hostedDomain] - Optional Google Workspace domain to restrict sign in
  ///
  /// Returns:
  /// - Right(AuthCredentials) - Sign in successful
  /// - Left(AuthenticationFailure) - Sign in failed or cancelled
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.signInWithGoogle(
  ///   scopes: ['email', 'profile'],
  /// );
  /// ```
  Future<Either<Failure, AuthCredentials>> signInWithGoogle({
    List<String>? scopes,
    String? hostedDomain,
  });

  /// Sign in with Apple.
  ///
  /// Opens Apple Sign In flow and returns user credentials on success.
  ///
  /// [scopes] - Optional list of scopes to request (email, fullName)
  ///
  /// Returns:
  /// - Right(AuthCredentials) - Sign in successful
  /// - Left(AuthenticationFailure) - Sign in failed or cancelled
  /// - Left(ProviderNotAvailableFailure) - Apple Sign In not available on platform
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.signInWithApple(
  ///   scopes: ['email', 'fullName'],
  /// );
  /// ```
  Future<Either<Failure, AuthCredentials>> signInWithApple({
    List<String>? scopes,
  });

  /// Sign in with Azure AD.
  ///
  /// Opens Azure AD OAuth flow and returns user credentials on success.
  ///
  /// [scopes] - Optional list of OAuth scopes to request
  /// [tenantId] - Optional tenant ID (defaults to 'common')
  ///
  /// Returns:
  /// - Right(AuthCredentials) - Sign in successful
  /// - Left(AuthenticationFailure) - Sign in failed or cancelled
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.signInWithAzure(
  ///   scopes: ['User.Read', 'Mail.Read'],
  ///   tenantId: 'your-tenant-id',
  /// );
  /// ```
  Future<Either<Failure, AuthCredentials>> signInWithAzure({
    List<String>? scopes,
    String? tenantId,
  });

  /// Sign in with email and password.
  ///
  /// This is a generic method that implementations can use for
  /// email/password authentication if their backend supports it.
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns:
  /// - Right(AuthCredentials) - Sign in successful
  /// - Left(InvalidCredentialsFailure) - Invalid email or password
  /// - Left(AccountNotFoundFailure) - No account with this email
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.signInWithEmailAndPassword(
  ///   email: 'user@example.com',
  ///   password: 'securePassword123',
  /// );
  /// ```
  Future<Either<Failure, AuthCredentials>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  ///
  /// Creates a new user account with email and password.
  ///
  /// [email] - User's email address
  /// [password] - User's password
  /// [displayName] - Optional display name for the user
  ///
  /// Returns:
  /// - Right(AuthCredentials) - Sign up successful
  /// - Left(AccountAlreadyExistsFailure) - Account already exists
  /// - Left(InvalidCredentialsFailure) - Invalid email or weak password
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.signUpWithEmailAndPassword(
  ///   email: 'newuser@example.com',
  ///   password: 'securePassword123',
  ///   displayName: 'John Doe',
  /// );
  /// ```
  Future<Either<Failure, AuthCredentials>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out the current user.
  ///
  /// Clears all authentication state and tokens.
  ///
  /// Returns:
  /// - Right(void) - Sign out successful
  /// - Left(AuthenticationFailure) - Sign out failed
  ///
  /// Example:
  /// ```dart
  /// await authService.signOut();
  /// ```
  Future<Either<Failure, void>> signOut();

  /// Get the currently signed-in user.
  ///
  /// Returns the current user if signed in, null otherwise.
  ///
  /// Returns:
  /// - Right(AuthUser?) - User if signed in, null if not
  /// - Left(AuthenticationFailure) - Error getting user
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.getCurrentUser();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (user) => print(user != null ? 'Signed in' : 'Not signed in'),
  /// );
  /// ```
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  /// Stream of authentication state changes.
  ///
  /// Emits the current user whenever authentication state changes.
  /// Emits null when user signs out.
  ///
  /// Example:
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User signed in: ${user.email}');
  ///   } else {
  ///     print('User signed out');
  ///   }
  /// });
  /// ```
  Stream<AuthUser?> get authStateChanges;

  /// Refresh the current authentication token.
  ///
  /// Gets a new access token using the refresh token.
  /// Useful when the current token has expired.
  ///
  /// Returns:
  /// - Right(AuthToken) - New token obtained
  /// - Left(TokenExpiredFailure) - Refresh token expired
  /// - Left(AuthenticationFailure) - Failed to refresh token
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.refreshToken();
  /// result.fold(
  ///   (failure) => print('Need to sign in again'),
  ///   (token) => print('Token refreshed'),
  /// );
  /// ```
  Future<Either<Failure, AuthToken>> refreshToken();

  /// Get the current authentication token.
  ///
  /// Returns the access token for the current user.
  /// Automatically refreshes if token is expired.
  ///
  /// Returns:
  /// - Right(AuthToken) - Current valid token
  /// - Left(AuthenticationFailure) - Not signed in or failed to get token
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.getAuthToken();
  /// result.fold(
  ///   (failure) => print('Not authenticated'),
  ///   (token) => print('Token: ${token.accessToken}'),
  /// );
  /// ```
  Future<Either<Failure, AuthToken>> getAuthToken();

  /// Check if user is currently signed in.
  ///
  /// Returns:
  /// - Right(true) - User is signed in
  /// - Right(false) - User is not signed in
  /// - Left(AuthenticationFailure) - Error checking status
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.isSignedIn();
  /// result.fold(
  ///   (failure) => print('Error checking status'),
  ///   (isSignedIn) => print(isSignedIn ? 'Signed in' : 'Not signed in'),
  /// );
  /// ```
  Future<Either<Failure, bool>> isSignedIn();

  /// Delete the current user's account.
  ///
  /// Permanently deletes the user's account and all associated data.
  /// User will be signed out after deletion.
  ///
  /// Returns:
  /// - Right(void) - Account deleted successfully
  /// - Left(AuthenticationFailure) - Failed to delete account
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.deleteAccount();
  /// result.fold(
  ///   (failure) => print('Failed to delete account'),
  ///   (_) => print('Account deleted'),
  /// );
  /// ```
  Future<Either<Failure, void>> deleteAccount();

  /// Update user profile information.
  ///
  /// [displayName] - New display name (null to keep unchanged)
  /// [photoUrl] - New photo URL (null to keep unchanged)
  ///
  /// Returns:
  /// - Right(void) - Profile updated successfully
  /// - Left(AuthenticationFailure) - Failed to update profile
  ///
  /// Example:
  /// ```dart
  /// await authService.updateProfile(
  ///   displayName: 'Jane Doe',
  ///   photoUrl: 'https://example.com/photo.jpg',
  /// );
  /// ```
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Send password reset email.
  ///
  /// Sends an email to the user with a link to reset their password.
  ///
  /// [email] - User's email address
  ///
  /// Returns:
  /// - Right(void) - Email sent successfully
  /// - Left(AccountNotFoundFailure) - No account with this email
  /// - Left(AuthenticationFailure) - Failed to send email
  ///
  /// Example:
  /// ```dart
  /// await authService.sendPasswordResetEmail(
  ///   email: 'user@example.com',
  /// );
  /// ```
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Verify email address.
  ///
  /// Sends a verification email to the current user.
  ///
  /// Returns:
  /// - Right(void) - Verification email sent
  /// - Left(AuthenticationFailure) - Failed to send verification email
  ///
  /// Example:
  /// ```dart
  /// await authService.sendEmailVerification();
  /// ```
  Future<Either<Failure, void>> sendEmailVerification();

  /// Reload user data from the server.
  ///
  /// Refreshes the current user's profile information.
  ///
  /// Returns:
  /// - Right(AuthUser) - Updated user data
  /// - Left(AuthenticationFailure) - Failed to reload user
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.reloadUser();
  /// result.fold(
  ///   (failure) => print('Failed to reload'),
  ///   (user) => print('User reloaded: ${user.email}'),
  /// );
  /// ```
  Future<Either<Failure, AuthUser>> reloadUser();

  /// Link current user with another provider.
  ///
  /// Allows a user to sign in with multiple providers.
  ///
  /// [provider] - Provider to link with
  /// [credentials] - Credentials from the other provider
  ///
  /// Returns:
  /// - Right(AuthUser) - Account linked successfully
  /// - Left(AuthenticationFailure) - Failed to link account
  ///
  /// Example:
  /// ```dart
  /// // First sign in with email
  /// // Then link with Google
  /// final googleCredentials = await authService.signInWithGoogle();
  /// googleCredentials.fold(
  ///   (failure) => print('Failed to get Google credentials'),
  ///   (creds) async {
  ///     final result = await authService.linkWithProvider(
  ///       provider: AuthProvider.google,
  ///       credentials: creds,
  ///     );
  ///   },
  /// );
  /// ```
  Future<Either<Failure, AuthUser>> linkWithProvider({
    required AuthProvider provider,
    required AuthCredentials credentials,
  });

  /// Unlink a provider from the current user.
  ///
  /// Removes the ability to sign in with a specific provider.
  /// User must have at least one other sign-in method.
  ///
  /// [provider] - Provider to unlink
  ///
  /// Returns:
  /// - Right(AuthUser) - Provider unlinked successfully
  /// - Left(AuthenticationFailure) - Failed to unlink provider
  ///
  /// Example:
  /// ```dart
  /// await authService.unlinkProvider(AuthProvider.google);
  /// ```
  Future<Either<Failure, AuthUser>> unlinkProvider(AuthProvider provider);

  /// Dispose resources used by the authentication service.
  ///
  /// Call this when the service is no longer needed to clean up resources.
  Future<Either<Failure, void>> dispose();
}
