# Bearer Token Authentication Setup Guide

Panduan lengkap untuk mengimplementasikan bearer token authentication di aplikasi Flutter menggunakan BUMA Core library.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Usage Examples](#usage-examples)
- [Advanced Configuration](#advanced-configuration)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

Bearer token authentication adalah metode autentikasi yang menggunakan token (biasanya JWT) untuk mengidentifikasi user di setiap HTTP request.

### Features

✅ **Automatic Token Injection** - Token otomatis ditambahkan ke setiap request  
✅ **Auto Token Refresh** - Token expired otomatis di-refresh  
✅ **Secure Storage** - Token disimpan dengan encryption (Keychain/KeyStore)  
✅ **Dependency Independent** - Mudah ganti auth provider tanpa ubah code  
✅ **Type Safe** - Error handling dengan Either<Failure, Success>  
✅ **Configurable** - Exclude specific endpoints dari authentication  

### How It Works

```
┌──────────────┐
│ User Login   │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ AuthService          │ ──► Get Token (JWT)
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ TokenProvider        │ ──► Cache to SecureStorage (Encrypted)
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ HTTP Request         │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ AuthInterceptor      │ ──► Get Token from Cache
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Add Bearer Header    │ ──► Authorization: Bearer {token}
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ API Server           │
└──────────────────────┘
```

---

## 🏗️ Architecture

### Components

#### 1. **TokenProviderService** (Interface)
- Abstraksi untuk mendapatkan & manage tokens
- Independent dari auth provider apapun
- Handle caching & refresh logic

#### 2. **TokenProviderServiceImpl** (Implementation)
- Implementasi menggunakan `AuthenticationService` dan `SecureStorageService`
- Cache tokens di secure storage
- Auto-refresh expired tokens

#### 3. **AuthInterceptor**
- HTTP request interceptor
- Inject bearer token ke request headers
- Skip authentication untuk public endpoints

#### 4. **AuthenticationService** (Interface)
- Handle sign in/out
- Generate & refresh tokens
- Provider-agnostic (Google, Azure, Apple, Custom Backend)

#### 5. **SecureStorageService** (Interface)
- Secure storage untuk tokens
- Platform-specific encryption (Keychain/KeyStore)

### Dependency Flow

```
HttpClient
    │
    ├─► AuthInterceptor
    │       │
    │       └─► TokenProviderService (interface)
    │               │
    │               └─► TokenProviderServiceImpl
    │                       │
    │                       ├─► AuthenticationService (interface)
    │                       │       │
    │                       │       └─► GoogleAuthServiceImpl
    │                       │       └─► AzureAuthServiceImpl
    │                       │       └─► CustomBackendAuthImpl
    │                       │
    │                       └─► SecureStorageService (interface)
    │                               │
    │                               └─► FlutterSecureStorageImpl
```

**Key Point**: Semua dependency menggunakan **interface**, sehingga mudah di-test dan di-replace.

---

## 🚀 Quick Start

### Step 1: Add Dependencies

Pastikan dependencies sudah ada di `pubspec.yaml`:

```yaml
dependencies:
  app_core:
    path: ../core  # atau dari git/pub
  get_it: ^7.6.0
  dartz: ^0.10.1
```

### Step 2: Initialize Services

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupAuthentication() {
  // 1. Secure Storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(),
  );

  // 2. Authentication Service
  getIt.registerLazySingleton<AuthenticationService>(
    () => GoogleAuthenticationServiceImpl(
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // 3. Token Provider
  getIt.registerLazySingleton<TokenProviderService>(
    () => TokenProviderServiceImpl(
      authService: getIt<AuthenticationService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // 4. Auth Interceptor
  final authInterceptor = AuthInterceptor(
    tokenProvider: getIt<TokenProviderService>(),
    excludedPaths: ['/auth/login', '/public'],
  );

  // 5. HTTP Client
  getIt.registerLazySingleton<HttpClient>(
    () {
      final client = DioHttpClient(
        baseUrl: 'https://api.example.com',
        enableLogging: true,
      );
      
      client.addRequestInterceptor(authInterceptor.onRequest);
      
      return client;
    },
  );
}
```

### Step 3: Use in Your App

```dart
// Login
final authService = getIt<AuthenticationService>();
await authService.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password',
);

// Make authenticated request (token auto-injected!)
final httpClient = getIt<HttpClient>();
final result = await httpClient.get('/user/profile');

// Logout
final tokenProvider = getIt<TokenProviderService>();
await authService.signOut();
await tokenProvider.clearTokens();
```

**That's it!** Token akan otomatis di-inject ke semua HTTP requests.

---

## 📚 Detailed Setup

### 1. Setup Secure Storage

```dart
getIt.registerLazySingleton<SecureStorageService>(
  () => FlutterSecureStorageServiceImpl(
    options: SecureStorageOptions(
      // iOS: Token hanya bisa diakses setelah unlock pertama kali
      accessibility: KeychainAccessibility.firstUnlockThisDeviceOnly,
      
      // Android: Gunakan KeyStore (hardware encryption)
      useEncryptedSharedPreferences: false,
    ),
  ),
);
```

**Platform Storage:**
- **iOS/macOS**: Keychain (hardware-encrypted via Secure Enclave)
- **Android**: KeyStore (hardware-encrypted via TEE/StrongBox)
- **Windows**: Credential Manager
- **Linux**: libsecret

### 2. Setup Authentication Service

Pilih auth provider sesuai kebutuhan:

#### Option A: Google Authentication

```dart
getIt.registerLazySingleton<AuthenticationService>(
  () => GoogleAuthenticationServiceImpl(
    secureStorage: getIt<SecureStorageService>(),
  ),
);
```

#### Option B: Azure AD OAuth

```dart
getIt.registerLazySingleton<AuthenticationService>(
  () => AzureAuthenticationServiceImpl(
    secureStorage: getIt<SecureStorageService>(),
  ),
);
```

#### Option C: Apple Sign In

```dart
getIt.registerLazySingleton<AuthenticationService>(
  () => AppleAuthenticationServiceImpl(
    secureStorage: getIt<SecureStorageService>(),
  ),
);
```

#### Option D: Custom Backend (JWT)

Implement your own `AuthenticationService`:

```dart
class CustomBackendAuthServiceImpl implements AuthenticationService {
  final HttpClient _httpClient;
  final SecureStorageService _secureStorage;
  
  @override
  Future<Either<Failure, AuthCredentials>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Your custom backend login logic
    final result = await _httpClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    return result.fold(
      (failure) => Left(failure),
      (response) {
        final token = AuthToken.fromJson(response.data['token']);
        final user = AuthUser.fromJson(response.data['user']);
        return Right(AuthCredentials(user: user, token: token));
      },
    );
  }
  
  // Implement other methods...
}
```

### 3. Setup Token Provider

```dart
getIt.registerLazySingleton<TokenProviderService>(
  () => TokenProviderServiceImpl(
    authService: getIt<AuthenticationService>(),
    secureStorage: getIt<SecureStorageService>(),
  ),
);
```

**TokenProvider automatically:**
- Caches tokens to secure storage
- Validates token expiration
- Refreshes expired tokens
- Clears tokens on logout

### 4. Setup Auth Interceptor

```dart
final authInterceptor = AuthInterceptor(
  tokenProvider: getIt<TokenProviderService>(),
  
  // Exclude these paths from authentication
  excludedPaths: [
    '/auth/login',           // Login endpoint
    '/auth/register',        // Registration
    '/auth/forgot-password', // Password reset
    '/auth/refresh',         // Token refresh
    '/public',               // Public content
    '/health',               // Health check
    '/api/v1/guest',         // Guest endpoints
  ],
);
```

### 5. Setup HTTP Client

```dart
getIt.registerLazySingleton<HttpClient>(
  () {
    final client = DioHttpClient(
      baseUrl: 'https://api.example.com',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: 30000,
      receiveTimeout: 30000,
      enableLogging: true,
    );
    
    // Add auth interceptor
    client.addRequestInterceptor(authInterceptor.onRequest);
    
    // Add error interceptor for 401 handling
    client.addErrorInterceptor((failure) async {
      if (failure is UnauthorizedFailure) {
        // Token expired and refresh failed
        // Navigate to login
        await getIt<AuthenticationService>().signOut();
        await getIt<TokenProviderService>().clearTokens();
        // navigateToLogin();
      }
      return Left(failure);
    });
    
    return client;
  },
);
```

---

## 💡 Usage Examples

### Example 1: User Login

```dart
Future<void> login(String email, String password) async {
  final authService = getIt<AuthenticationService>();
  
  final result = await authService.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  result.fold(
    (failure) {
      // Handle login error
      showError('Login failed: $failure');
    },
    (credentials) {
      // Login successful, token automatically saved
      print('Welcome ${credentials.user.displayName}!');
      navigateToHome();
    },
  );
}
```

### Example 2: Make Authenticated Request

```dart
Future<void> fetchUserProfile() async {
  final httpClient = getIt<HttpClient>();
  
  // Token automatically injected by AuthInterceptor!
  final result = await httpClient.get<Map<String, dynamic>>(
    '/user/profile',
  );
  
  result.fold(
    (failure) {
      if (failure is UnauthorizedFailure) {
        // Token invalid, redirect to login
        navigateToLogin();
      } else {
        showError('Request failed: $failure');
      }
    },
    (response) {
      final profile = UserProfile.fromJson(response.data!);
      displayProfile(profile);
    },
  );
}
```

### Example 3: Check Authentication Status

```dart
Future<bool> isUserAuthenticated() async {
  final tokenProvider = getIt<TokenProviderService>();
  
  final result = await tokenProvider.hasValidToken();
  
  return result.fold(
    (failure) => false,
    (hasToken) => hasToken,
  );
}

// Use in route guard
if (await isUserAuthenticated()) {
  navigateToHome();
} else {
  navigateToLogin();
}
```

### Example 4: Manual Token Refresh

```dart
Future<void> refreshTokenManually() async {
  final tokenProvider = getIt<TokenProviderService>();
  
  final result = await tokenProvider.refreshToken();
  
  result.fold(
    (failure) {
      // Refresh failed, user needs to re-login
      print('Token refresh failed: $failure');
      logout();
    },
    (newToken) {
      print('Token refreshed successfully');
      print('New expiry: ${newToken.expiresAt}');
    },
  );
}
```

### Example 5: Logout

```dart
Future<void> logout() async {
  final authService = getIt<AuthenticationService>();
  final tokenProvider = getIt<TokenProviderService>();
  
  // Sign out from auth provider
  await authService.signOut();
  
  // Clear cached tokens
  await tokenProvider.clearTokens();
  
  // Navigate to login
  navigateToLogin();
}
```

---

## ⚙️ Advanced Configuration

### Custom Token Expiry Buffer

Default buffer is 5 minutes. To customize:

```dart
// Modify TokenProviderServiceImpl._expiryBufferTime
static const Duration _expiryBufferTime = Duration(minutes: 10);
```

### Dynamic Excluded Paths

```dart
final authInterceptor = AuthInterceptor(
  tokenProvider: getIt<TokenProviderService>(),
  excludedPaths: [],
);

// Add excluded paths dynamically
authInterceptor.addExcludedPath('/new-public-endpoint');

// Remove excluded paths
authInterceptor.removeExcludedPath('/no-longer-public');

// Get current excluded paths
final paths = authInterceptor.getExcludedPaths();
```

### Multiple Auth Providers

```dart
// Register based on platform or user preference
getIt.registerLazySingleton<AuthenticationService>(
  () {
    if (Platform.isAndroid) {
      return GoogleAuthenticationServiceImpl(...);
    } else if (Platform.isIOS) {
      return AppleAuthenticationServiceImpl(...);
    } else {
      return AzureAuthenticationServiceImpl(...);
    }
  },
);

// TokenProvider works with any AuthenticationService!
```

### Custom Error Handling

```dart
client.addErrorInterceptor((failure) async {
  if (failure is UnauthorizedFailure) {
    // Try to refresh token
    final tokenProvider = getIt<TokenProviderService>();
    final refreshResult = await tokenProvider.refreshToken();
    
    return refreshResult.fold(
      // Refresh failed, logout
      (refreshFailure) {
        logout();
        return Left(failure);
      },
      // Refresh success, retry request
      (newToken) async {
        // Retry the failed request with new token
        return Right(/* retried response */);
      },
    );
  }
  
  return Left(failure);
});
```

---

## 🔒 Security Best Practices

### ✅ DO's

1. **Always use SecureStorage for tokens**
   - ✅ iOS: Keychain (hardware-encrypted)
   - ✅ Android: KeyStore (hardware-encrypted)
   - ❌ NEVER use SharedPreferences

2. **Set appropriate token expiry buffer**
   ```dart
   // Refresh 5-10 minutes before actual expiry
   static const Duration _expiryBufferTime = Duration(minutes: 5);
   ```

3. **Clear tokens on logout**
   ```dart
   await authService.signOut();
   await tokenProvider.clearTokens();
   ```

4. **Handle 401 errors properly**
   ```dart
   if (failure is UnauthorizedFailure) {
     // Clear session and redirect to login
     await logout();
   }
   ```

5. **Use HTTPS only**
   ```dart
   baseUrl: 'https://api.example.com', // Not http://
   ```

### ❌ DON'Ts

1. **NEVER log tokens**
   ```dart
   // ❌ BAD
   print('Token: $accessToken');
   
   // ✅ GOOD
   print('Token: [REDACTED]');
   ```

2. **NEVER hardcode tokens**
   ```dart
   // ❌ VERY BAD
   final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```

3. **NEVER store tokens in plain text**
   ```dart
   // ❌ BAD
   SharedPreferences.setString('token', token);
   
   // ✅ GOOD
   SecureStorageService.write(key: 'token', value: token);
   ```

4. **NEVER skip SSL verification**
   ```dart
   // ❌ VERY DANGEROUS
   dio.options.validateCertificate = false;
   ```

---

## 🐛 Troubleshooting

### Issue: Token not being injected to requests

**Solution:**
1. Check if AuthInterceptor is registered:
   ```dart
   client.addRequestInterceptor(authInterceptor.onRequest);
   ```

2. Check if endpoint is in excluded paths:
   ```dart
   final paths = authInterceptor.getExcludedPaths();
   print('Excluded: $paths');
   ```

3. Check if user is logged in:
   ```dart
   final hasToken = await tokenProvider.hasValidToken();
   print('Has token: $hasToken');
   ```

### Issue: 401 Unauthorized despite being logged in

**Solution:**
1. Check if token is expired:
   ```dart
   final token = await tokenProvider.getAuthToken();
   print('Token expired: ${token.fold((l) => true, (r) => r.isExpired)}');
   ```

2. Try manual refresh:
   ```dart
   await tokenProvider.refreshToken();
   ```

3. Check server token format:
   ```dart
   // Server expects: "Bearer {token}"
   // Check if header format is correct
   ```

### Issue: Token not persisting after app restart

**Solution:**
1. Ensure SecureStorage is working:
   ```dart
   await secureStorage.write(key: 'test', value: 'test');
   final result = await secureStorage.read(key: 'test');
   print('Storage works: ${result.isRight()}');
   ```

2. Check if tokens are being saved:
   ```dart
   // After login, check storage
   final token = await secureStorage.read(key: 'auth_access_token');
   print('Token saved: ${token.isRight()}');
   ```

### Issue: iOS Keychain access denied

**Solution:**
1. Add keychain entitlements to `ios/Runner/Runner.entitlements`:
   ```xml
   <key>keychain-access-groups</key>
   <array>
     <string>$(AppIdentifierPrefix)com.your.app</string>
   </array>
   ```

### Issue: Android KeyStore errors

**Solution:**
1. Use EncryptedSharedPreferences for older Android:
   ```dart
   SecureStorageOptions(
     useEncryptedSharedPreferences: true,
   )
   ```

---

## 📖 Additional Resources

- **Example Code**: `example/bearer_token_example.dart`
- **API Documentation**: See inline dartdoc comments
- **Architecture Guide**: `ARCHITECTURE.md`
- **Migration Guide**: `MIGRATION_GUIDE.md`

---

## 🎯 Summary

Bearer token authentication dengan BUMA Core:

1. ✅ **Dependency Independent** - Mudah ganti auth provider
2. ✅ **Automatic** - Token injection & refresh otomatis
3. ✅ **Secure** - Hardware-encrypted storage
4. ✅ **Type Safe** - Error handling dengan Either
5. ✅ **Maintainable** - Clear separation of concerns
6. ✅ **Testable** - Mock-friendly design

**Setup Steps:**
1. Register `SecureStorageService`
2. Register `AuthenticationService`
3. Register `TokenProviderService`
4. Create `AuthInterceptor`
5. Register `HttpClient` with interceptor

**Result:** Token otomatis di-inject ke semua HTTP requests! 🚀

