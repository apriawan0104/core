import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../errors/authentication_failure.dart';
import '../../../errors/failures.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Apple Sign In authentication service implementation.
///
/// This implementation uses the `sign_in_with_apple` package to provide
/// Apple authentication functionality.
///
/// ## Platform Support
///
/// - iOS 13.0+
/// - macOS 10.15+
/// - Android (via web redirect)
/// - Web
///
/// ## Setup
///
/// See the package documentation for platform-specific setup:
/// https://pub.dev/packages/sign_in_with_apple
///
/// ## Usage Example
///
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => AppleAuthenticationServiceImpl(
///     clientId: 'your.bundle.id',
///     redirectUri: 'https://your-app.com/auth/callback',
///   ),
/// );
///
/// // Use in your app
/// final authService = getIt<AuthenticationService>();
/// await authService.initialize();
///
/// final result = await authService.signInWithApple();
/// result.fold(
///   (failure) => print('Sign in failed: $failure'),
///   (credentials) => print('Signed in: ${credentials.user.email}'),
/// );
/// ```
class AppleAuthenticationServiceImpl implements AuthenticationService {
  final String? _clientId;
  final String? _redirectUri;
  final StreamController<AuthUser?> _authStateController;

  AuthUser? _currentUser;

  /// Creates an Apple authentication service.
  ///
  /// [clientId] - Your app's bundle identifier (iOS) or service ID (web/Android)
  /// [redirectUri] - Redirect URI for web/Android authentication
  AppleAuthenticationServiceImpl({
    String? clientId,
    String? redirectUri,
  })  : _clientId = clientId,
        _redirectUri = redirectUri,
        _authStateController = StreamController<AuthUser?>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      // Check if Sign in with Apple is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return const Left(
          ProviderNotAvailableFailure(
            'Sign in with Apple is not available on this device',
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationConfigurationFailure(
          'Failed to initialize Apple Sign In: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithApple({
    List<String>? scopes,
  }) async {
    try {
      // Check if available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return const Left(
          ProviderNotAvailableFailure(
            'Sign in with Apple is not available on this device',
          ),
        );
      }

      // Parse scopes
      final appleScopes = _parseScopes(scopes);

      // Sign in
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: appleScopes,
        webAuthenticationOptions: _clientId != null && _redirectUri != null
            ? WebAuthenticationOptions(
                clientId: _clientId,
                redirectUri: Uri.parse(_redirectUri),
              )
            : null,
      );

      // Map to AuthUser
      final user = _mapAppleCredentialToAuthUser(credential);
      _currentUser = user;
      _authStateController.add(user);

      // Create auth token
      final token = AuthToken(
        accessToken: credential.identityToken ?? '',
        idToken: credential.identityToken,
      );

      // Create credentials
      final authCredentials = AuthCredentials(
        user: user,
        token: token,
        provider: AuthProvider.apple,
        serverAuthCode: credential.authorizationCode,
        isNewUser: false, // Apple doesn't provide this info directly
      );

      return Right(authCredentials);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(AuthenticationCancelledFailure());
      } else if (e.code == AuthorizationErrorCode.failed) {
        return Left(
          AuthenticationFailure('Apple sign in failed: ${e.message}'),
        );
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        return Left(
          AuthenticationFailure('Invalid response from Apple: ${e.message}'),
        );
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        return const Left(
          AuthenticationFailure('Apple sign in not handled'),
        );
      } else {
        return Left(
          AuthenticationFailure('Apple sign in error: ${e.message}'),
        );
      }
    } catch (e) {
      return Left(
        AuthenticationFailure('Apple sign in failed: $e'),
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
        'Google Sign In is not supported by Apple authentication service',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithAzure({
    List<String>? scopes,
    String? tenantId,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Azure Sign In is not supported by Apple authentication service',
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
        'Email/password sign in is not supported by Apple authentication service',
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
        'Email/password sign up is not supported by Apple authentication service',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
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
    return const Left(
      AuthenticationFailure(
        'Token refresh is not supported by Apple Sign In. '
        'You need to implement server-side token refresh using the authorization code.',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthToken>> getAuthToken() async {
    if (_currentUser == null) {
      return const Left(
        AuthenticationFailure('No user signed in'),
      );
    }

    return const Left(
      AuthenticationFailure(
        'Token retrieval is not supported by Apple Sign In. '
        'Store the token received during sign in.',
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      return Right(_currentUser != null);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to check sign in status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // Get credential state to revoke
      if (_currentUser?.providerUserId != null) {
        final credentialState = await SignInWithApple.getCredentialState(
          _currentUser!.providerUserId!,
        );

        if (credentialState == CredentialState.authorized) {
          // Note: Actual account deletion must be done server-side
          // This only clears local state
          _currentUser = null;
          _authStateController.add(null);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationFailure('Failed to delete account: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    return const Left(
      AuthenticationFailure(
        'Profile update is not supported by Apple Sign In. '
        'Profile is managed through Apple ID settings.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Password reset is not supported by Apple Sign In',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Left(
      ProviderNotAvailableFailure(
        'Email verification is managed by Apple',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUser>> reloadUser() async {
    if (_currentUser == null) {
      return const Left(
        AuthenticationFailure('No user signed in'),
      );
    }

    try {
      // Check credential state
      final credentialState = await SignInWithApple.getCredentialState(
        _currentUser!.providerUserId!,
      );

      if (credentialState == CredentialState.revoked) {
        _currentUser = null;
        _authStateController.add(null);
        return const Left(
          AuthenticationFailure('Apple credentials have been revoked'),
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
        'Account linking is not supported by Apple Sign In. '
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
        'Account unlinking is not supported by Apple Sign In',
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

  /// Parse scopes from string list to Apple scopes
  List<AppleIDAuthorizationScopes> _parseScopes(List<String>? scopes) {
    if (scopes == null || scopes.isEmpty) {
      return [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ];
    }

    final appleScopes = <AppleIDAuthorizationScopes>[];

    for (final scope in scopes) {
      switch (scope.toLowerCase()) {
        case 'email':
          appleScopes.add(AppleIDAuthorizationScopes.email);
          break;
        case 'fullname':
        case 'full_name':
        case 'name':
          appleScopes.add(AppleIDAuthorizationScopes.fullName);
          break;
      }
    }

    return appleScopes.isNotEmpty
        ? appleScopes
        : [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ];
  }

  /// Maps Apple credential to AuthUser model
  AuthUser _mapAppleCredentialToAuthUser(
      AuthorizationCredentialAppleID credential) {
    // Construct display name from givenName and familyName if available
    String? displayName;
    if (credential.givenName != null || credential.familyName != null) {
      final parts = [
        credential.givenName,
        credential.familyName,
      ].where((part) => part != null && part.isNotEmpty);
      displayName = parts.isNotEmpty ? parts.join(' ') : null;
    }

    return AuthUser(
      id: credential.userIdentifier ?? '',
      email: credential.email,
      displayName: displayName,
      emailVerified: credential.email != null,
      isAnonymous: false,
      provider: AuthProvider.apple,
      providerUserId: credential.userIdentifier,
      metadata: {
        'authorizationCode': credential.authorizationCode,
        'identityToken': credential.identityToken,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
      },
    );
  }
}
