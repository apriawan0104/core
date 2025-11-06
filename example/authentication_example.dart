import 'package:app_core/app_core.dart';

/// Example demonstrating authentication service usage with multiple providers.
///
/// This example shows how to:
/// 1. Set up authentication with different providers
/// 2. Sign in with Google, Apple, or Azure
/// 3. Handle authentication state
/// 4. Get auth tokens
/// 5. Sign out
void main() async {
  print('=== Authentication Service Example ===\n');

  // Example 1: Google Sign In
  await _googleSignInExample();

  print('\n---\n');

  // Example 2: Apple Sign In
  await _appleSignInExample();

  print('\n---\n');

  // Example 3: Azure AD Sign In
  await _azureSignInExample();

  print('\n---\n');

  // Example 4: Auth State Management
  await _authStateExample();
}

/// Example 1: Google Sign In
Future<void> _googleSignInExample() async {
  print('Example 1: Google Sign In\n');

  // Initialize service
  final authService = GoogleAuthenticationServiceImpl(
    scopes: ['email', 'profile'],
  );

  await authService.initialize();
  print('✓ Service initialized');

  // Sign in with Google
  print('\nAttempting to sign in with Google...');
  final result = await authService.signInWithGoogle();

  result.fold(
    (failure) {
      print('✗ Sign in failed: ${failure.message}');

      if (failure is AuthenticationCancelledFailure) {
        print('  → User cancelled the sign in flow');
      } else if (failure is AuthenticationNetworkFailure) {
        print('  → Network error occurred');
      }
    },
    (credentials) {
      print('✓ Sign in successful!');
      print('  User ID: ${credentials.user.id}');
      print('  Email: ${credentials.user.email}');
      print('  Name: ${credentials.user.displayName}');
      print('  Provider: ${credentials.user.provider.displayName}');
      print('  Email Verified: ${credentials.user.emailVerified}');

      if (credentials.token != null) {
        print('\n  Token Info:');
        print('  - Has Access Token: ${credentials.token!.accessToken.isNotEmpty}');
        print('  - Has ID Token: ${credentials.token!.idToken != null}');
        print('  - Token Valid: ${credentials.token!.isValid}');
      }
    },
  );

  // Get current user
  print('\nGetting current user...');
  final userResult = await authService.getCurrentUser();

  userResult.fold(
    (failure) => print('✗ Failed to get user: ${failure.message}'),
    (user) {
      if (user != null) {
        print('✓ Current user: ${user.email}');
      } else {
        print('  No user signed in');
      }
    },
  );

  // Sign out
  print('\nSigning out...');
  final signOutResult = await authService.signOut();

  signOutResult.fold(
    (failure) => print('✗ Sign out failed: ${failure.message}'),
    (_) => print('✓ Signed out successfully'),
  );

  await authService.dispose();
}

/// Example 2: Apple Sign In
Future<void> _appleSignInExample() async {
  print('Example 2: Apple Sign In\n');

  // Initialize service
  final authService = AppleAuthenticationServiceImpl(
    clientId: 'com.example.app',
    redirectUri: 'https://example.com/auth/callback',
  );

  final initResult = await authService.initialize();

  initResult.fold(
    (failure) {
      print('✗ Initialization failed: ${failure.message}');
      if (failure is ProviderNotAvailableFailure) {
        print('  → Apple Sign In is not available on this platform');
        print('  → Requires iOS 13+, macOS 10.15+, or web');
      }
      return;
    },
    (_) => print('✓ Service initialized'),
  );

  // Sign in with Apple
  print('\nAttempting to sign in with Apple...');
  final result = await authService.signInWithApple(
    scopes: ['email', 'fullName'],
  );

  result.fold(
    (failure) {
      print('✗ Sign in failed: ${failure.message}');
    },
    (credentials) {
      print('✓ Sign in successful!');
      print('  User ID: ${credentials.user.id}');
      print('  Email: ${credentials.user.email ?? "Hidden by user"}');
      print('  Name: ${credentials.user.displayName ?? "Not provided"}');
      print('  Provider: ${credentials.user.provider.displayName}');

      if (credentials.serverAuthCode != null) {
        print('\n  Server Auth Code: ${credentials.serverAuthCode}');
        print('  → Send this to your backend for verification');
      }
    },
  );

  // Check sign in status
  print('\nChecking sign in status...');
  final statusResult = await authService.isSignedIn();

  statusResult.fold(
    (failure) => print('✗ Failed to check status: ${failure.message}'),
    (isSignedIn) => print('  Signed in: $isSignedIn'),
  );

  await authService.dispose();
}

/// Example 3: Azure AD Sign In
Future<void> _azureSignInExample() async {
  print('Example 3: Azure AD Sign In\n');

  // Initialize service
  final authService = AzureAuthenticationServiceImpl(
    tenantId: 'common', // or your specific tenant ID
    clientId: 'your-azure-client-id',
    redirectUri: 'msauth.com.example.app://auth',
    scopes: ['User.Read', 'Mail.Read'],
  );

  await authService.initialize();
  print('✓ Service initialized');

  // Sign in with Azure
  print('\nAttempting to sign in with Azure AD...');
  final result = await authService.signInWithAzure(
    scopes: ['User.Read', 'Mail.Read', 'Calendars.Read'],
  );

  result.fold(
    (failure) {
      print('✗ Sign in failed: ${failure.message}');
    },
    (credentials) {
      print('✓ Sign in successful!');
      print('  User ID: ${credentials.user.id}');
      print('  Email: ${credentials.user.email}');
      print('  Name: ${credentials.user.displayName}');
      print('  Provider: ${credentials.user.provider.displayName}');

      if (credentials.token != null) {
        print('\n  Token Info:');
        print('  - Token Type: ${credentials.token!.tokenType}');
        print('  - Has Access Token: ${credentials.token!.accessToken.isNotEmpty}');
        print('  - Scopes: ${credentials.token!.scopes?.join(", ")}');
      }
    },
  );

  // Get and refresh token
  print('\nGetting auth token...');
  final tokenResult = await authService.getAuthToken();

  tokenResult.fold(
    (failure) => print('✗ Failed to get token: ${failure.message}'),
    (token) {
      print('✓ Got auth token');
      print('  Token Type: ${token.tokenType}');
      print('  Is Valid: ${token.isValid}');
      print('  Is Expired: ${token.isExpired}');

      if (token.expiresAt != null) {
        print('  Expires At: ${token.expiresAt}');
        print('  Time Until Expiry: ${token.timeUntilExpiry}');
      }
    },
  );

  // Refresh token
  print('\nRefreshing token...');
  final refreshResult = await authService.refreshToken();

  refreshResult.fold(
    (failure) {
      print('✗ Token refresh failed: ${failure.message}');
      if (failure is TokenExpiredFailure) {
        print('  → Refresh token expired, need to sign in again');
      }
    },
    (newToken) {
      print('✓ Token refreshed successfully');
      print('  New token is valid: ${newToken.isValid}');
    },
  );

  await authService.dispose();
}

/// Example 4: Auth State Management
Future<void> _authStateExample() async {
  print('Example 4: Auth State Management\n');

  final authService = GoogleAuthenticationServiceImpl(
    scopes: ['email', 'profile'],
  );

  await authService.initialize();

  // Listen to auth state changes
  print('Setting up auth state listener...');
  final subscription = authService.authStateChanges.listen((user) {
    if (user != null) {
      print('\n🔐 Auth State Changed: User signed in');
      print('   Email: ${user.email}');
      print('   Provider: ${user.provider.displayName}');
    } else {
      print('\n🔓 Auth State Changed: User signed out');
    }
  });

  // Sign in
  print('\nSigning in...');
  await authService.signInWithGoogle();

  // Wait a bit for state change
  await Future.delayed(Duration(seconds: 1));

  // Sign out
  print('\nSigning out...');
  await authService.signOut();

  // Wait a bit for state change
  await Future.delayed(Duration(seconds: 1));

  // Clean up
  await subscription.cancel();
  await authService.dispose();

  print('\n✓ Auth state example completed');
}

/// Example: Error Handling
void _errorHandlingExample(Failure failure) {
  print('Handling authentication error...\n');

  if (failure is AuthenticationCancelledFailure) {
    print('User cancelled the authentication flow');
    print('→ Show a message or retry option');
  } else if (failure is InvalidCredentialsFailure) {
    print('Invalid credentials provided');
    print('→ Ask user to check their credentials');
  } else if (failure is AccountAlreadyExistsFailure) {
    print('Account already exists');
    print('→ Suggest sign in instead of sign up');
  } else if (failure is AccountNotFoundFailure) {
    print('Account not found');
    print('→ Suggest creating a new account');
  } else if (failure is AuthenticationNetworkFailure) {
    print('Network error occurred');
    print('→ Check internet connection and retry');
  } else if (failure is TokenExpiredFailure) {
    print('Token expired');
    print('→ Refresh token or re-authenticate');
  } else if (failure is AuthenticationConfigurationFailure) {
    print('Configuration error');
    print('→ Check provider setup (client IDs, redirect URIs)');
  } else if (failure is InsufficientPermissionsFailure) {
    print('Insufficient permissions');
    print('→ Request required permissions again');
  } else if (failure is ProviderNotAvailableFailure) {
    print('Provider not available on this platform');
    print('→ Show alternative sign-in methods');
  } else {
    print('Authentication failed: ${failure.message}');
    print('→ Show generic error message');
  }
}

/// Example: Using with DI
class AuthenticationExample {
  final AuthenticationService _authService;

  AuthenticationExample(this._authService);

  Future<void> signIn() async {
    // Initialize
    await _authService.initialize();

    // Sign in
    final result = await _authService.signInWithGoogle();

    result.fold(
      (failure) => _errorHandlingExample(failure),
      (credentials) {
        print('✓ Signed in as ${credentials.user.email}');
        _handleSuccessfulSignIn(credentials);
      },
    );
  }

  void _handleSuccessfulSignIn(AuthCredentials credentials) {
    // Save user info
    // Navigate to home screen
    // Start listening to auth state changes
  }

  Future<void> signOut() async {
    final result = await _authService.signOut();

    result.fold(
      (failure) => print('Sign out failed: ${failure.message}'),
      (_) {
        print('✓ Signed out successfully');
        // Clear user data
        // Navigate to login screen
      },
    );
  }

  Future<String?> getAccessToken() async {
    final result = await _authService.getAuthToken();

    return result.fold(
      (failure) {
        print('Failed to get token: ${failure.message}');
        return null;
      },
      (token) => token.accessToken,
    );
  }
}
