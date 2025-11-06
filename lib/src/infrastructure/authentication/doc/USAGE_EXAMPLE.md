# Authentication Usage Examples

Complete, copy-paste examples for common authentication scenarios.

## Basic Sign In Flow

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthenticationService _authService = GoogleAuthenticationServiceImpl();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final result = await _authService.initialize(AuthConfig(
      scopes: ['email', 'profile'],
    ));

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      (_) {
        // Try silent sign in
        _attemptSilentSignIn();
      },
    );
  }

  Future<void> _attemptSilentSignIn() async {
    final result = await _authService.signInSilently();
    
    result.fold(
      (failure) {
        // Silent sign in failed, user needs to sign in manually
        print('Silent sign in failed: ${failure.message}');
      },
      (credential) {
        // Success! Navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.signIn();

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      (credential) {
        // Sign in successful, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Sign In with Google'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Multi-Provider Authentication

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class MultiProviderAuth extends StatefulWidget {
  @override
  _MultiProviderAuthState createState() => _MultiProviderAuthState();
}

class _MultiProviderAuthState extends State<MultiProviderAuth> {
  final _googleAuth = GoogleAuthenticationServiceImpl();
  final _appleAuth = AppleAuthenticationServiceImpl();
  final _azureAuth = AzureAuthenticationServiceImpl();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    // Initialize all providers
    await Future.wait([
      _googleAuth.initialize(AuthConfig(scopes: ['email', 'profile'])),
      _appleAuth.initialize(AuthConfig(scopes: ['email', 'fullName'])),
      _azureAuth.initialize(AuthConfig(
        clientId: 'your-azure-client-id',
        redirectUri: 'your-redirect-uri',
        scopes: ['openid', 'profile', 'email'],
      )),
    ]);
  }

  Future<void> _signInWith(AuthenticationService service, String providerName) async {
    setState(() => _isLoading = true);

    final result = await service.signIn();

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$providerName sign in failed: ${failure.message}')),
        );
      },
      (credential) {
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Sign In Method')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Sign In
                  ElevatedButton.icon(
                    icon: Icon(Icons.login),
                    label: Text('Sign in with Google'),
                    onPressed: () => _signInWith(_googleAuth, 'Google'),
                  ),
                  SizedBox(height: 16),
                  
                  // Apple Sign In
                  if (_appleAuth.isAvailable)
                    ElevatedButton.icon(
                      icon: Icon(Icons.apple),
                      label: Text('Sign in with Apple'),
                      onPressed: () => _signInWith(_appleAuth, 'Apple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  SizedBox(height: 16),
                  
                  // Microsoft Sign In
                  ElevatedButton.icon(
                    icon: Icon(Icons.business),
                    label: Text('Sign in with Microsoft'),
                    onPressed: () => _signInWith(_azureAuth, 'Microsoft'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
```

## Reactive Auth State Management

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class AuthStateManager extends StatefulWidget {
  final Widget child;

  const AuthStateManager({required this.child});

  @override
  _AuthStateManagerState createState() => _AuthStateManagerState();
}

class _AuthStateManagerState extends State<AuthStateManager> {
  final AuthenticationService _authService = GoogleAuthenticationServiceImpl();
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authService.authStateChanges.listen((user) {
      setState(() {
        _currentUser = user;
      });

      // Navigate based on auth state
      if (user == null) {
        // User signed out - go to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else {
        // User signed in - go to home
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Provide auth service to children via InheritedWidget
    return AuthProvider(
      authService: _authService,
      currentUser: _currentUser,
      child: widget.child,
    );
  }
}

// InheritedWidget for accessing auth throughout the app
class AuthProvider extends InheritedWidget {
  final AuthenticationService authService;
  final AuthUser? currentUser;

  const AuthProvider({
    required this.authService,
    required this.currentUser,
    required Widget child,
  }) : super(child: child);

  static AuthProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
  }

  @override
  bool updateShouldNotify(AuthProvider oldWidget) {
    return currentUser != oldWidget.currentUser;
  }
}

// Usage in any widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final user = authProvider?.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider?.authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user?.displayName ?? user?.email ?? "User"}!'),
      ),
    );
  }
}
```

## Token Refresh Example

```dart
import 'package:app_core/app_core.dart';

class AuthRepository {
  final AuthenticationService _authService;
  AuthCredential? _currentCredential;

  AuthRepository(this._authService);

  /// Get valid access token, refreshing if necessary
  Future<Either<AuthenticationFailure, String>> getAccessToken() async {
    // Check if we have a credential
    if (_currentCredential == null) {
      return const Left(AccountNotFoundFailure('Not signed in'));
    }

    // Check if token is expired or about to expire
    if (_currentCredential!.isExpired) {
      // Refresh token
      final result = await _authService.refreshToken();
      
      return result.fold(
        (failure) => Left(failure),
        (newCredential) {
          _currentCredential = newCredential;
          return Right(newCredential.accessToken ?? '');
        },
      );
    }

    // Token is still valid
    return Right(_currentCredential!.accessToken ?? '');
  }

  /// Make authenticated API call
  Future<Either<AuthenticationFailure, dynamic>> makeAuthenticatedRequest(
    Future<dynamic> Function(String token) apiCall,
  ) async {
    final tokenResult = await getAccessToken();

    return tokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        try {
          final response = await apiCall(token);
          return Right(response);
        } catch (e) {
          if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
            // Token might be invalid, try refresh
            final refreshResult = await _authService.refreshToken();
            
            return refreshResult.fold(
              (failure) => Left(failure),
              (newCredential) async {
                _currentCredential = newCredential;
                final response = await apiCall(newCredential.accessToken ?? '');
                return Right(response);
              },
            );
          }
          
          return Left(AuthenticationFailure(e.toString()));
        }
      },
    );
  }
}

// Usage
final authRepo = AuthRepository(googleAuthService);

// Make authenticated API call
final result = await authRepo.makeAuthenticatedRequest((token) async {
  return await http.get(
    Uri.parse('https://api.example.com/user/profile'),
    headers: {'Authorization': 'Bearer $token'},
  );
});
```

## Complete App Example

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthenticationService _authService = GoogleAuthenticationServiceImpl();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Initialize
    await _authService.initialize(AuthConfig(
      scopes: ['email', 'profile'],
    ));

    // Try silent sign in
    final result = await _authService.signInSilently();

    result.fold(
      (failure) {
        // Not signed in, go to login
        Navigator.pushReplacementNamed(context, '/login');
      },
      (credential) {
        // Already signed in, go to home
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

## Testing Example

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthenticationService {}

void main() {
  group('Authentication Tests', () {
    late MockAuthService mockAuth;

    setUp(() {
      mockAuth = MockAuthService();
    });

    test('successful sign in returns credential', () async {
      // Arrange
      final expectedCredential = AuthCredential(
        user: AuthUser(
          id: 'test-id',
          email: 'test@example.com',
          providerType: AuthProviderType.google,
        ),
        accessToken: 'test-token',
      );

      when(mockAuth.signIn()).thenAnswer(
        (_) async => Right(expectedCredential),
      );

      // Act
      final result = await mockAuth.signIn();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (credential) {
          expect(credential.user.email, 'test@example.com');
          expect(credential.accessToken, 'test-token');
        },
      );
    });

    test('cancelled sign in returns failure', () async {
      // Arrange
      when(mockAuth.signIn()).thenAnswer(
        (_) async => const Left(AuthenticationCancelledFailure()),
      );

      // Act
      final result = await mockAuth.signIn();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthenticationCancelledFailure>());
        },
        (credential) => fail('Expected failure but got success'),
      );
    });
  });
}
```

That's it! You now have complete examples for implementing authentication in your app. Pick the example that matches your use case and adapt it to your needs.

