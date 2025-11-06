import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../errors/authentication_failure.dart';
import '../../../errors/failures.dart';
import '../contract/contracts.dart';
import '../models/models.dart';

/// Google Sign In authentication service implementation.
///
/// This implementation uses the `google_sign_in` package to provide
/// Google authentication functionality.
///
/// Compatible with google_sign_in: ^6.2.1
///
/// ## Setup
///
/// See the package documentation for platform-specific setup:
/// https://pub.dev/packages/google_sign_in
///
/// ## Usage Example
///
/// ```dart
/// // Register in DI container
/// getIt.registerLazySingleton<AuthenticationService>(
///   () => GoogleAuthenticationServiceImpl(
///     scopes: ['email', 'profile'],
///   ),
/// );
///
/// // Use in your app
/// final authService = getIt<AuthenticationService>();
/// await authService.initialize();
///
/// final result = await authService.signInWithGoogle();
/// result.fold(
///   (failure) => print('Sign in failed: $failure'),
///   (credentials) => print('Signed in: ${credentials.user.email}'),
/// );
/// ```
class GoogleAuthenticationServiceImpl implements AuthenticationService {
  final GoogleSignIn _googleSignIn;
  final StreamController<AuthUser?> _authStateController;

  GoogleSignInAccount? _currentUser;

  /// Creates a Google authentication service.
  ///
  /// [hostedDomain] - Restrict to specific Google Workspace domain
  /// [scopes] - OAuth scopes to request
  GoogleAuthenticationServiceImpl({
    String? hostedDomain,
    List<String>? scopes,
  })  : _googleSignIn = GoogleSignIn(
          scopes: scopes ?? <String>['email', 'profile'],
          hostedDomain: hostedDomain,
        ),
        _authStateController = StreamController<AuthUser?>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      // Listen to auth state changes
      _googleSignIn.onCurrentUserChanged.listen((account) {
        _currentUser = account;
        if (account != null) {
          _authStateController.add(_mapGoogleUserToAuthUser(account));
        } else {
          _authStateController.add(null);
        }
      });

      // Try silent sign in
      try {
        await _googleSignIn.signInSilently();
      } catch (_) {
        // Silent sign in failed, user needs to sign in explicitly
      }

      return const Right(null);
    } catch (e) {
      return Left(
        AuthenticationConfigurationFailure(
          'Failed to initialize Google Sign In: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithGoogle({
    List<String>? scopes,
    String? hostedDomain,
  }) async {
    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        return const Left(AuthenticationCancelledFailure());
      }

      _currentUser = account;

      // Get authentication details
      final auth = await account.authentication;

      // Create auth user
      final user = _mapGoogleUserToAuthUser(account);

      // Create auth token
      final token = AuthToken(
        accessToken: auth.accessToken ?? auth.idToken ?? '',
        idToken: auth.idToken,
      );

      // Create credentials
      final credentials = AuthCredentials(
        user: user,
        token: token,
        provider: AuthProvider.google,
        isNewUser: false,
      );

      return Right(credentials);
    } catch (e) {
      return Left(
        AuthenticationFailure('Google sign in failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> signInWithApple({
    List<String>? scopes,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Apple Sign In is not supported by Google authentication service',
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
        'Azure Sign In is not supported by Google authentication service',
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
        'Email/password sign in is not supported by Google authentication service',
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
        'Email/password sign up is not supported by Google authentication service',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
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
      final account = _currentUser;
      if (account == null) {
        return const Right(null);
      }
      return Right(_mapGoogleUserToAuthUser(account));
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
      final account = _currentUser;
      if (account == null) {
        return const Left(
          AuthenticationFailure('No user signed in'),
        );
      }

      // Clear auth cache and get fresh token
      await account.clearAuthCache();
      final auth = await account.authentication;

      final token = AuthToken(
        accessToken: auth.accessToken ?? auth.idToken ?? '',
        idToken: auth.idToken,
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
      final account = _currentUser;
      if (account == null) {
        return const Left(
          AuthenticationFailure('No user signed in'),
        );
      }

      final auth = await account.authentication;

      final token = AuthToken(
        accessToken: auth.accessToken ?? auth.idToken ?? '',
        idToken: auth.idToken,
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
      await _googleSignIn.disconnect();
      _currentUser = null;
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
        'Profile update is not supported by Google Sign In. '
        'Profile is managed through Google account.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return const Left(
      ProviderNotAvailableFailure(
        'Password reset is not supported by Google Sign In',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Left(
      ProviderNotAvailableFailure(
        'Email verification is managed by Google',
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUser>> reloadUser() async {
    try {
      final account = _currentUser;
      if (account == null) {
        return const Left(
          AuthenticationFailure('No user signed in'),
        );
      }

      // Get fresh user data
      return Right(_mapGoogleUserToAuthUser(account));
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
        'Account linking is not supported by Google Sign In. '
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
        'Account unlinking is not supported by Google Sign In',
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

  /// Maps Google Sign In account to AuthUser model
  AuthUser _mapGoogleUserToAuthUser(GoogleSignInAccount account) {
    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      emailVerified: true,
      isAnonymous: false,
      provider: AuthProvider.google,
      providerUserId: account.id,
    );
  }
}
