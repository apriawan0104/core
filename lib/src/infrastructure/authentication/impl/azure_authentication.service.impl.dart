import 'dart:async';
import 'dart:convert';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:dartz/dartz.dart';

import '../../../errors/authentication_failure.dart';
import '../../../errors/failures.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Azure AD OAuth authentication service implementation.
///
/// This implementation uses the `aad_oauth` package to provide
/// Azure Active Directory authentication functionality.
///
/// ## Platform Support
///
/// - iOS
/// - Android
/// - Web
///
/// ## Setup
///
/// See the package documentation for setup:
/// https://pub.dev/packages/aad_oauth
///
/// ## Usage Example
///
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => AzureAuthenticationServiceImpl(
///     tenantId: 'your-tenant-id',
///     clientId: 'your-client-id',
///     redirectUri: 'your-redirect-uri',
///     scopes: ['User.Read', 'Mail.Read'],
///   ),
/// );
///
/// // Use in your app
/// final authService = getIt<AuthenticationService>();
/// await authService.initialize();
///
/// final result = await authService.signInWithAzure();
/// result.fold(
///   (failure) => print('Sign in failed: $failure'),
///   (credentials) => print('Signed in: ${credentials.user.email}'),
/// );
/// ```
class AzureAuthenticationServiceImpl implements AuthenticationService {
  final AadOAuth _aadOAuth;
  final StreamController<AuthUser?> _authStateController;

  AuthUser? _currentUser;

  /// Creates an Azure AD authentication service.
  ///
  /// [tenantId] - Azure AD tenant ID (or 'common', 'organizations', 'consumers')
  /// [clientId] - Azure AD application (client) ID
  /// [redirectUri] - Redirect URI configured in Azure AD
  /// [scopes] - OAuth scopes to request
  /// [navigatorKey] - Global navigator key for web authentication
  AzureAuthenticationServiceImpl({
    required String tenantId,
    required String clientId,
    required String redirectUri,
    List<String>? scopes,
    dynamic navigatorKey,
  })  : _aadOAuth = AadOAuth(
          Config(
            tenant: tenantId,
            clientId: clientId,
            scope: (scopes ?? ['User.Read']).join(' '),
            redirectUri: redirectUri,
            navigatorKey: navigatorKey,
          ),
        ),
        _authStateController = StreamController<AuthUser?>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      // Check if there's a cached token
      final hasCachedInfo = await _aadOAuth.hasCachedAccountInformation;

      if (hasCachedInfo) {
        // Try to get token silently
        try {
          final token = await _aadOAuth.getAccessToken();
          if (token != null) {
            // Get user info
            await _loadUserInfo();
          }
        } catch (e) {
          // Silent login failed, user needs to login again
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationConfigurationFailure(
          'Failed to initialize Azure AD OAuth: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithAzure({
    List<String>? scopes,
    String? tenantId,
  }) async {
    try {
      // Login
      await _aadOAuth.login();

      // Get access token
      final accessToken = await _aadOAuth.getAccessToken();
      if (accessToken == null) {
        return const Left(
          AuthenticationFailure('Failed to get access token from Azure AD'),
        );
      }

      // Get ID token
      final idToken = await _aadOAuth.getIdToken();

      // Load user information
      await _loadUserInfo();

      if (_currentUser == null) {
        return const Left(
          AuthenticationFailure('Failed to get user information from Azure AD'),
        );
      }

      // Create auth token
      final token = AuthToken(
        accessToken: accessToken,
        idToken: idToken,
        tokenType: 'Bearer',
      );

      // Create credentials
      final credentials = AuthCredentials(
        user: _currentUser!,
        token: token,
        provider: AuthProvider.azure,
        isNewUser: false,
      );

      _authStateController.add(_currentUser);

      return Right(credentials);
    } catch (e) {
      if (e.toString().contains('cancel')) {
        return const Left(AuthenticationCancelledFailure());
      }
      return Left(
        AuthenticationFailure('Azure AD sign in failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithGoogle({
    List<String>? scopes,
    String? hostedDomain,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Google Sign In is not supported by Azure authentication service',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithApple({
    List<String>? scopes,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Apple Sign In is not supported by Azure authentication service',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Direct email/password sign in is not supported. '
        'Use signInWithAzure() which will prompt for Azure AD credentials.',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthCredentials>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Sign up is not supported by Azure AD OAuth. '
        'Users must be created in Azure AD portal.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _aadOAuth.logout();
      _currentUser = null;
      _authStateController.add(null);
      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to sign out: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      return Right(_currentUser);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get current user: $e'),
      );
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    try {
      // Azure AD OAuth package handles token refresh automatically
      final accessToken = await _aadOAuth.getAccessToken();
      if (accessToken == null) {
        return const Left(
          TokenExpiredFailure('Failed to refresh token'),
        );
      }

      final idToken = await _aadOAuth.getIdToken();

      final token = AuthToken(
        accessToken: accessToken,
        idToken: idToken,
        tokenType: 'Bearer',
      );

      return Right(token);
    } catch (e) {
      return Left(
        TokenExpiredFailure('Failed to refresh token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthToken>> getAuthToken() async {
    try {
      final accessToken = await _aadOAuth.getAccessToken();
      if (accessToken == null) {
        return const Left(
          AuthenticationFailure('No valid token available'),
        );
      }

      final idToken = await _aadOAuth.getIdToken();

      final token = AuthToken(
        accessToken: accessToken,
        idToken: idToken,
        tokenType: 'Bearer',
      );

      return Right(token);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to get auth token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final hasCachedInfo = await _aadOAuth.hasCachedAccountInformation;
      return Right(hasCachedInfo);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to check sign in status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return const Left(
      AuthenticationFailure(
        'Account deletion is not supported by Azure AD OAuth. '
        'Accounts must be deleted through Azure AD portal.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    return const Left(
      AuthenticationFailure(
        'Profile update is not supported by Azure AD OAuth. '
        'Profile must be updated through Azure AD portal.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Password reset is not supported by Azure AD OAuth. '
        'Use Azure AD portal for password reset.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Left(
      ProviderNotAvailableFailure(
        'Email verification is managed by Azure AD',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUser>> reloadUser() async {
    try {
      await _loadUserInfo();

      if (_currentUser == null) {
        return const Left(
          AuthenticationFailure('Failed to reload user'),
        );
      }

      return Right(_currentUser!);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to reload user: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthUser>> linkWithProvider({
    required AuthProvider provider,
    required AuthCredentials credentials,
  }) async {
    return const Left(
      AuthenticationFailure(
        'Account linking is not supported by Azure AD OAuth. '
        'Use a backend service for multi-provider authentication.',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUser>> unlinkProvider(
    AuthProvider provider,
  ) async {
    return const Left(
      AuthenticationFailure(
        'Account unlinking is not supported by Azure AD OAuth',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await _authStateController.close();
      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to dispose: $e'),
      );
    }
  }

  /// Load user information from Azure AD
  Future<void> _loadUserInfo() async {
    try {
      // Get ID token which contains user claims
      final idToken = await _aadOAuth.getIdToken();

      if (idToken != null) {
        // Parse JWT token to get user info
        final userInfo = _parseJwtToken(idToken);

        _currentUser = AuthUser(
          id: userInfo['oid'] as String? ??
              userInfo['sub'] as String? ??
              userInfo['upn'] as String? ??
              '',
          email: userInfo['email'] as String? ?? userInfo['upn'] as String?,
          displayName: userInfo['name'] as String?,
          emailVerified: true, // Azure AD emails are verified
          isAnonymous: false,
          provider: AuthProvider.azure,
          providerUserId:
              userInfo['oid'] as String? ?? userInfo['sub'] as String?,
          metadata: userInfo,
        );
      }
    } catch (e) {
      // Failed to load user info
      _currentUser = null;
    }
  }

  /// Parse JWT token to extract claims
  Map<String, dynamic> _parseJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return {};
      }

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonData = json.decode(decoded) as Map<String, dynamic>;

      return jsonData;
    } catch (e) {
      return {};
    }
  }
}
