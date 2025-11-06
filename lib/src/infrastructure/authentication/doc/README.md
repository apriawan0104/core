# Authentication Service

Comprehensive authentication service for BUMA Core that supports multiple authentication providers.

## 📋 Table of Contents

- [Overview](#overview)
- [Supported Providers](#supported-providers)
- [Architecture](#architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Advanced Features](#advanced-features)
- [Migration Guide](#migration-guide)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The authentication service provides a **dependency-independent** abstraction for authentication operations. It supports multiple authentication providers (Google, Apple, Azure AD) without tying your business logic to any specific implementation.

### Key Features

✅ **Multiple Providers**: Google, Apple, Azure AD  
✅ **Dependency Independent**: Easy to switch providers  
✅ **Type Safe**: All operations return `Either<Failure, Success>`  
✅ **Real-time Updates**: Stream-based authentication state  
✅ **Token Management**: Automatic refresh and validation  
✅ **Easy Testing**: Mock-friendly design  
✅ **Platform Support**: iOS, Android, Web, macOS  

### Design Philosophy

Following BUMA Core principles:

1. **No Third-Party Types in Public API**: All interfaces use our own models
2. **Abstraction First**: All providers implement the same interface
3. **Easy Migration**: Switching providers requires only DI changes
4. **Zero Business Logic Changes**: Consumer code remains unchanged

## 🔌 Supported Providers

### 1. Google Sign In

- **Package**: [`google_sign_in`](https://pub.dev/packages/google_sign_in)
- **Platforms**: Android, iOS, macOS, Web
- **Features**: OAuth 2.0, offline access, server auth codes

### 2. Apple Sign In

- **Package**: [`sign_in_with_apple`](https://pub.dev/packages/sign_in_with_apple)
- **Platforms**: iOS 13+, macOS 10.15+, Android (via web), Web
- **Features**: Privacy-focused, email relay, name sharing

### 3. Azure AD OAuth

- **Package**: [`aad_oauth`](https://pub.dev/packages/aad_oauth)
- **Platforms**: Android, iOS, Web
- **Features**: Enterprise authentication, Microsoft 365 integration

## 🏗️ Architecture

```
authentication/
├── contract/
│   └── authentication.service.dart       # Abstract interface
├── impl/
│   ├── google_authentication.service.impl.dart
│   ├── apple_authentication.service.impl.dart
│   └── azure_authentication.service.impl.dart
├── models/
│   ├── auth_user.model.dart              # User information
│   ├── auth_token.model.dart             # Token data
│   ├── auth_credentials.model.dart       # Complete auth result
│   └── auth_provider.model.dart          # Provider enum
├── constants/
│   └── authentication.constant.dart      # Scopes, errors, etc.
└── doc/
    ├── README.md                         # This file
    └── QUICK_START.md                    # Quick reference
```

## 📦 Installation

### 1. Add Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  # Core library
  app_core:
    path: ../core  # or your core library path
  
  # Choose which providers you need:
  
  # For Google Sign In
  google_sign_in: ^6.2.1
  
  # For Apple Sign In
  sign_in_with_apple: ^6.1.0
  
  # For Azure AD
  aad_oauth: ^2.0.0
```

### 2. Platform Setup

#### Android

**For Google Sign In:**
- Add SHA-1 fingerprint to Firebase/Google Cloud Console
- Download and add `google-services.json`

**For Azure AD:**
- Register app in Azure AD portal
- Configure redirect URI

#### iOS

**For Apple Sign In:**
- Enable "Sign in with Apple" capability in Xcode
- Configure app ID in Apple Developer Portal

**For Google Sign In:**
- Add URL schemes to `Info.plist`
- Add `GoogleService-Info.plist`

#### Web

Configure OAuth redirect URIs in respective provider consoles.

See [QUICK_START.md](QUICK_START.md) for detailed setup instructions.

## 🚀 Quick Start

### 1. Register in DI Container

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupAuthentication() {
  // Option 1: Google Sign In
  getIt.registerLazySingleton<AuthenticationService>(
    () => GoogleAuthenticationServiceImpl(
      scopes: ['email', 'profile'],
    ),
  );
  
  // Option 2: Apple Sign In
  // getIt.registerLazySingleton<AuthenticationService>(
  //   () => AppleAuthenticationServiceImpl(
  //     clientId: 'your.bundle.id',
  //     redirectUri: 'https://your-app.com/auth/callback',
  //   ),
  // );
  
  // Option 3: Azure AD
  // getIt.registerLazySingleton<AuthenticationService>(
  //   () => AzureAuthenticationServiceImpl(
  //     tenantId: 'your-tenant-id',
  //     clientId: 'your-client-id',
  //     redirectUri: 'your-redirect-uri',
  //     scopes: ['User.Read', 'Mail.Read'],
  //   ),
  // );
}
```

### 2. Initialize Service

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupAuthentication();
  
  final authService = getIt<AuthenticationService>();
  await authService.initialize();
  
  runApp(MyApp());
}
```

### 3. Sign In

```dart
class SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final authService = getIt<AuthenticationService>();
        
        // For Google
        final result = await authService.signInWithGoogle();
        
        // For Apple
        // final result = await authService.signInWithApple();
        
        // For Azure
        // final result = await authService.signInWithAzure();
        
        result.fold(
          (failure) => _showError(failure),
          (credentials) => _navigateToHome(credentials.user),
        );
      },
      child: Text('Sign In'),
    );
  }
}
```

### 4. Listen to Auth State

```dart
class AuthStateListener extends StatefulWidget {
  @override
  _AuthStateListenerState createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  late StreamSubscription<AuthUser?> _authSubscription;
  
  @override
  void initState() {
    super.initState();
    
    final authService = getIt<AuthenticationService>();
    
    _authSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        // User signed in
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User signed out
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Container();
}
```

## 💡 Usage Examples

### Get Current User

```dart
final authService = getIt<AuthenticationService>();

final result = await authService.getCurrentUser();
result.fold(
  (failure) => print('Error: $failure'),
  (user) {
    if (user != null) {
      print('Current user: ${user.email}');
      print('Provider: ${user.provider.displayName}');
    } else {
      print('No user signed in');
    }
  },
);
```

### Get Auth Token

```dart
final result = await authService.getAuthToken();
result.fold(
  (failure) => print('Failed to get token'),
  (token) {
    print('Access Token: ${token.accessToken}');
    print('Is Valid: ${token.isValid}');
    print('Expires At: ${token.expiresAt}');
  },
);
```

### Sign Out

```dart
final result = await authService.signOut();
result.fold(
  (failure) => print('Sign out failed: $failure'),
  (_) => print('Signed out successfully'),
);
```

### Check Sign In Status

```dart
final result = await authService.isSignedIn();
result.fold(
  (failure) => print('Error checking status'),
  (isSignedIn) {
    if (isSignedIn) {
      print('User is signed in');
    } else {
      print('User is not signed in');
    }
  },
);
```

## 🔧 Advanced Features

### Custom Scopes

```dart
// Google
final result = await authService.signInWithGoogle(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.readonly',
  ],
);

// Azure
final result = await authService.signInWithAzure(
  scopes: [
    'User.Read',
    'Mail.Read',
    'Calendar.ReadWrite',
  ],
);
```

### Token Refresh

```dart
final result = await authService.refreshToken();
result.fold(
  (failure) {
    if (failure is TokenExpiredFailure) {
      // Refresh token expired, need to sign in again
      await authService.signOut();
      navigateToLogin();
    }
  },
  (token) => print('Token refreshed'),
);
```

### Error Handling

```dart
final result = await authService.signInWithGoogle();

result.fold(
  (failure) {
    if (failure is AuthenticationCancelledFailure) {
      // User cancelled the sign in flow
      showSnackbar('Sign in cancelled');
    } else if (failure is InvalidCredentialsFailure) {
      // Invalid credentials
      showSnackbar('Invalid credentials');
    } else if (failure is AuthenticationNetworkFailure) {
      // Network error
      showSnackbar('Network error. Please try again.');
    } else if (failure is ProviderNotAvailableFailure) {
      // Provider not available on this platform
      showSnackbar('Sign in method not available');
    } else {
      // Generic error
      showSnackbar('Sign in failed: ${failure.message}');
    }
  },
  (credentials) {
    // Success
    navigateToHome(credentials.user);
  },
);
```

## 🔄 Migration Guide

### Switching from Google to Apple

```dart
// Before (Google)
getIt.registerLazySingleton<AuthenticationService>(
  () => GoogleAuthenticationServiceImpl(
    scopes: ['email', 'profile'],
  ),
);

// After (Apple) - ONLY THIS CHANGES
getIt.registerLazySingleton<AuthenticationService>(
  () => AppleAuthenticationServiceImpl(
    clientId: 'your.bundle.id',
    redirectUri: 'https://your-app.com/auth',
  ),
);

// Business logic remains EXACTLY THE SAME:
final result = await authService.signInWithGoogle(); // This still works!
// Or use provider-agnostic approach:
// final result = await authService.signInWithApple();
```

**What needs to be changed:**
1. ✅ DI registration (1 line)
2. ✅ Dependencies in `pubspec.yaml`
3. ✅ Platform-specific configuration

**What DOESN'T need to be changed:**
- ❌ Business logic
- ❌ UI code (except sign-in buttons)
- ❌ Data models
- ❌ Tests

### Switching from Firebase Auth to Core Auth

If you're migrating from Firebase Auth to BUMA Core Auth:

```dart
// Before (Firebase)
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  print(user.email);
}

// After (Core)
final result = await authService.getCurrentUser();
result.fold(
  (failure) => print('Error'),
  (user) {
    if (user != null) {
      print(user.email);
    }
  },
);
```

## 🐛 Troubleshooting

### Google Sign In Issues

**Problem**: "Error 10" on Android  
**Solution**: Ensure SHA-1 fingerprint is added to Firebase console

**Problem**: Sign in works in debug but not release  
**Solution**: Add both debug and release SHA-1 fingerprints

### Apple Sign In Issues

**Problem**: "Sign in with Apple not available"  
**Solution**: 
- Ensure device is iOS 13+ or macOS 10.15+
- Enable capability in Xcode
- Configure App ID in Apple Developer Portal

### Azure AD Issues

**Problem**: "Invalid redirect URI"  
**Solution**: Ensure redirect URI matches exactly what's configured in Azure portal

**Problem**: "AADSTS50011: Reply URL mismatch"  
**Solution**: Check redirect URI in both app code and Azure portal

### Common Issues

**Problem**: Token expired  
**Solution**: Implement token refresh logic:

```dart
// Before making API calls
final tokenResult = await authService.getAuthToken();
tokenResult.fold(
  (failure) async {
    // Token invalid, refresh or re-authenticate
    final refreshResult = await authService.refreshToken();
    // Handle refresh result
  },
  (token) {
    if (token.isExpired) {
      // Refresh token
      await authService.refreshToken();
    }
  },
);
```

**Problem**: Auth state not persisting  
**Solution**: Make sure to call `initialize()` on app start to restore session

## 📚 Additional Resources

- [Quick Start Guide](QUICK_START.md)
- [API Reference](#) (coming soon)
- [Example App](../../../example/authentication_example.dart)

## 🤝 Contributing

When adding new authentication providers:

1. Create a new implementation class in `impl/`
2. Implement all methods from `AuthenticationService`
3. Map provider-specific types to our models
4. Add provider to `AuthProvider` enum
5. Update documentation

Example structure:

```dart
class CustomAuthenticationServiceImpl implements AuthenticationService {
  // Implement all interface methods
  
  // Private helper to map provider user to AuthUser
  AuthUser _mapToAuthUser(ProviderUser user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      // ... map other fields
      provider: AuthProvider.custom,
    );
  }
}
```

## 📄 License

This service is part of BUMA Core library.

---

For questions or issues, please refer to the main BUMA Core documentation.
