# Authentication Service - Quick Start Guide

Get up and running with authentication in 5 minutes!

## 📋 Prerequisites

- Flutter SDK installed
- iOS/Android development environment configured
- Provider accounts set up (Google/Apple/Azure)

## 🚀 Quick Setup

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Core library
  app_core:
    path: ../core
  
  # Choose your provider(s)
  google_sign_in: ^6.2.1        # For Google
  sign_in_with_apple: ^6.1.0    # For Apple
  aad_oauth: ^2.0.0             # For Azure
```

Run: `flutter pub get`

### Step 2: Platform Configuration

#### For Google Sign In

**Android** (`android/app/build.gradle`):
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### For Apple Sign In

**iOS** - In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability" → Add "Sign in with Apple"

#### For Azure AD

No additional platform configuration needed for basic setup.

### Step 3: Initialize Authentication

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  // Register authentication service
  getIt.registerLazySingleton<AuthenticationService>(
    () => GoogleAuthenticationServiceImpl(
      scopes: ['email', 'profile'],
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupServices();
  
  // Initialize auth
  final authService = getIt<AuthenticationService>();
  await authService.initialize();
  
  runApp(MyApp());
}
```

### Step 4: Create Sign In UI

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class SignInPage extends StatelessWidget {
  final authService = GetIt.instance<AuthenticationService>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign In Button
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(context),
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
            
            SizedBox(height: 16),
            
            // Apple Sign In Button
            ElevatedButton.icon(
              onPressed: () => _signInWithApple(context),
              icon: Icon(Icons.apple),
              label: Text('Sign in with Apple'),
            ),
            
            SizedBox(height: 16),
            
            // Azure Sign In Button
            ElevatedButton.icon(
              onPressed: () => _signInWithAzure(context),
              icon: Icon(Icons.business),
              label: Text('Sign in with Azure'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _signInWithGoogle(BuildContext context) async {
    final result = await authService.signInWithGoogle();
    
    result.fold(
      (failure) => _showError(context, failure.message),
      (credentials) => _navigateToHome(context, credentials.user),
    );
  }
  
  Future<void> _signInWithApple(BuildContext context) async {
    final result = await authService.signInWithApple();
    
    result.fold(
      (failure) => _showError(context, failure.message),
      (credentials) => _navigateToHome(context, credentials.user),
    );
  }
  
  Future<void> _signInWithAzure(BuildContext context) async {
    final result = await authService.signInWithAzure();
    
    result.fold(
      (failure) => _showError(context, failure.message),
      (credentials) => _navigateToHome(context, credentials.user),
    );
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }
  
  void _navigateToHome(BuildContext context, AuthUser user) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Step 5: Display User Info

```dart
class HomePage extends StatelessWidget {
  final authService = GetIt.instance<AuthenticationService>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: FutureBuilder<Either<Failure, AuthUser?>>(
        future: authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          return snapshot.data!.fold(
            (failure) => Center(child: Text('Error: ${failure.message}')),
            (user) {
              if (user == null) {
                return Center(child: Text('No user signed in'));
              }
              
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.photoUrl != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                    SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'No name',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(user.email ?? 'No email'),
                    SizedBox(height: 8),
                    Text('Provider: ${user.provider.displayName}'),
                    SizedBox(height: 8),
                    Text('Email Verified: ${user.emailVerified}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<void> _signOut(BuildContext context) async {
    final result = await authService.signOut();
    
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: ${failure.message}')),
      ),
      (_) => Navigator.pushReplacementNamed(context, '/login'),
    );
  }
}
```

## 🎯 Common Use Cases

### 1. Auto Sign In on App Start

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final authService = GetIt.instance<AuthenticationService>();
  
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    final result = await authService.isSignedIn();
    
    result.fold(
      (failure) => Navigator.pushReplacementNamed(context, '/login'),
      (isSignedIn) {
        if (isSignedIn) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

### 2. Listen to Auth State Changes

```dart
class AuthStateProvider extends ChangeNotifier {
  final AuthenticationService _authService;
  StreamSubscription<AuthUser?>? _subscription;
  AuthUser? _currentUser;
  
  AuthStateProvider(this._authService) {
    _subscription = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }
  
  AuthUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### 3. Protected API Calls with Token

```dart
class ApiService {
  final AuthenticationService _authService;
  final HttpClient _httpClient;
  
  ApiService(this._authService, this._httpClient);
  
  Future<Either<Failure, UserData>> fetchUserData() async {
    // Get auth token
    final tokenResult = await _authService.getAuthToken();
    
    return tokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        // Make API call with token
        final result = await _httpClient.get(
          '/api/user',
          headers: {
            'Authorization': 'Bearer ${token.accessToken}',
          },
        );
        
        return result.fold(
          (failure) => Left(failure),
          (response) => Right(UserData.fromJson(response.data)),
        );
      },
    );
  }
}
```

## 🔄 Switching Providers

To switch from one provider to another:

```dart
// From Google to Apple - Change ONLY the DI registration:

// Before
getIt.registerLazySingleton<AuthenticationService>(
  () => GoogleAuthenticationServiceImpl(scopes: ['email', 'profile']),
);

// After
getIt.registerLazySingleton<AuthenticationService>(
  () => AppleAuthenticationServiceImpl(
    clientId: 'your.bundle.id',
    redirectUri: 'https://your-app.com/auth',
  ),
);

// All other code remains the same!
```

## ⚙️ Provider-Specific Configuration

### Google Sign In

```dart
GoogleAuthenticationServiceImpl(
  clientId: 'your-web-client-id',              // Required for web
  serverClientId: 'your-server-client-id',     // For server auth code
  hostedDomain: 'yourdomain.com',              // Restrict to domain
  scopes: ['email', 'profile', 'openid'],
)
```

### Apple Sign In

```dart
AppleAuthenticationServiceImpl(
  clientId: 'your.bundle.id',                  // Bundle ID
  redirectUri: 'https://your-app.com/auth',    // For web/Android
)
```

### Azure AD OAuth

```dart
AzureAuthenticationServiceImpl(
  tenantId: 'common',                          // or specific tenant ID
  clientId: 'your-azure-client-id',
  redirectUri: 'msauth.your.package://auth',
  scopes: [
    'User.Read',
    'Mail.Read',
    'Calendars.Read',
  ],
  navigatorKey: navigatorKey,                  // For web
)
```

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "PlatformException: sign_in_failed" | Check provider configuration (client IDs, redirect URIs) |
| "Sign in cancelled" | User cancelled the flow - this is normal |
| "Token expired" | Call `refreshToken()` or re-authenticate |
| Apple Sign In not available | Device must be iOS 13+, macOS 10.15+ |
| Google Sign In "Error 10" | Add SHA-1 to Firebase console |

## 📚 Next Steps

- Read the [full documentation](README.md)
- Check out [example app](../../../example/authentication_example.dart)
- Learn about [advanced features](README.md#advanced-features)

## 🤝 Need Help?

- Check the [troubleshooting section](README.md#troubleshooting)
- Refer to provider documentation:
  - [google_sign_in](https://pub.dev/packages/google_sign_in)
  - [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)
  - [aad_oauth](https://pub.dev/packages/aad_oauth)

---

Happy coding! 🚀
