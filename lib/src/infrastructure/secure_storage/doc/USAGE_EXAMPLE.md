# Secure Storage - Usage Examples

Comprehensive examples for common use cases and advanced patterns.

## Table of Contents

1. [Basic Examples](#basic-examples)
2. [Authentication Examples](#authentication-examples)
3. [Error Handling Patterns](#error-handling-patterns)
4. [Platform-Specific Examples](#platform-specific-examples)
5. [Advanced Patterns](#advanced-patterns)
6. [Integration Examples](#integration-examples)
7. [Testing Examples](#testing-examples)

## 1. Basic Examples

### Write and Read

```dart
import 'package:app_core/app_core.dart';

Future<void> basicWriteRead() async {
  final secureStorage = getIt<SecureStorageService>();
  
  // Write
  final writeResult = await secureStorage.write(
    key: 'my_secret',
    value: 'super_secret_value',
  );
  
  writeResult.fold(
    (failure) => print('Write failed: $failure'),
    (_) => print('Write successful'),
  );
  
  // Read
  final readResult = await secureStorage.read(key: 'my_secret');
  
  readResult.fold(
    (failure) => print('Read failed: $failure'),
    (value) => print('Value: $value'),
  );
}
```

### Check, Update, Delete

```dart
Future<void> checkUpdateDelete() async {
  final secureStorage = getIt<SecureStorageService>();
  
  // Check if exists
  final existsResult = await secureStorage.containsKey(key: 'my_secret');
  
  final exists = existsResult.fold(
    (failure) => false,
    (value) => value,
  );
  
  if (exists) {
    // Update (just write again)
    await secureStorage.write(
      key: 'my_secret',
      value: 'updated_secret_value',
    );
    
    // Delete
    await secureStorage.delete(key: 'my_secret');
  }
}
```

### Read All and Get All Keys

```dart
Future<void> readAllAndKeys() async {
  final secureStorage = getIt<SecureStorageService>();
  
  // Get all keys
  final keysResult = await secureStorage.getAllKeys();
  keysResult.fold(
    (failure) => print('Failed to get keys: $failure'),
    (keys) {
      print('Stored keys: $keys');
      // Output: [auth_token, refresh_token, user_id]
    },
  );
  
  // Read all data
  final allResult = await secureStorage.readAll();
  allResult.fold(
    (failure) => print('Failed to read all: $failure'),
    (allData) {
      print('Total items: ${allData.length}');
      allData.forEach((key, value) {
        // Don't log actual values in production!
        print('$key: ${value.substring(0, 10)}...');
      });
    },
  );
}
```

## 2. Authentication Examples

### Complete Auth Service

```dart
import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';

class AuthService {
  final SecureStorageService _secureStorage;
  
  AuthService(this._secureStorage);
  
  /// Login and save credentials
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call your auth API
      final response = await _authApi.login(email, password);
      
      // Save tokens securely
      await _secureStorage.write(
        key: SecureStorageConstants.authToken,
        value: response.accessToken,
      );
      
      await _secureStorage.write(
        key: SecureStorageConstants.refreshToken,
        value: response.refreshToken,
      );
      
      await _secureStorage.write(
        key: SecureStorageConstants.userId,
        value: response.userId,
      );
      
      await _secureStorage.write(
        key: SecureStorageConstants.userEmail,
        value: email,
      );
      
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    final result = await _secureStorage.read(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final result = await _secureStorage.read(
      key: SecureStorageConstants.refreshToken,
    );
    
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }
  
  /// Refresh access token
  Future<Either<Failure, void>> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          AuthenticationFailure(message: 'No refresh token'),
        );
      }
      
      // Call refresh endpoint
      final response = await _authApi.refresh(refreshToken);
      
      // Update access token
      await _secureStorage.write(
        key: SecureStorageConstants.authToken,
        value: response.accessToken,
      );
      
      // Optionally update refresh token if rotated
      if (response.refreshToken != null) {
        await _secureStorage.write(
          key: SecureStorageConstants.refreshToken,
          value: response.refreshToken!,
        );
      }
      
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final result = await _secureStorage.containsKey(
      key: SecureStorageConstants.authToken,
    );
    
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }
  
  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    final result = await _secureStorage.read(
      key: SecureStorageConstants.userId,
    );
    
    return result.fold(
      (failure) => null,
      (userId) => userId,
    );
  }
  
  /// Logout (clear all auth data)
  Future<void> logout() async {
    // Delete all auth-related keys
    for (final key in SecureStorageConstants.authKeys) {
      await _secureStorage.delete(key: key);
    }
    
    // Delete user data
    for (final key in SecureStorageConstants.userKeys) {
      await _secureStorage.delete(key: key);
    }
    
    // Or simply delete everything
    // await _secureStorage.deleteAll();
  }
  
  /// Delete account (clear ALL secure data)
  Future<void> deleteAccount() async {
    await _secureStorage.deleteAll();
  }
}
```

### HTTP Interceptor for Token Refresh

```dart
import 'package:dio/dio.dart';
import 'package:app_core/app_core.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final AuthService _authService;
  
  AuthInterceptor(this._secureStorage, this._authService);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token
    final tokenResult = await _secureStorage.read(
      key: SecureStorageConstants.authToken,
    );
    
    final token = tokenResult.fold(
      (failure) => null,
      (value) => value,
    );
    
    // Add token to headers
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If 401, try to refresh token
    if (err.response?.statusCode == 401) {
      // Refresh token
      final refreshResult = await _authService.refreshAccessToken();
      
      final success = refreshResult.fold(
        (failure) => false,
        (_) => true,
      );
      
      if (success) {
        // Retry original request with new token
        try {
          final tokenResult = await _secureStorage.read(
            key: SecureStorageConstants.authToken,
          );
          
          final newToken = tokenResult.fold(
            (failure) => null,
            (value) => value,
          );
          
          if (newToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            
            final response = await Dio().fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Refresh failed, logout
          await _authService.logout();
        }
      } else {
        // Refresh failed, logout
        await _authService.logout();
      }
    }
    
    handler.next(err);
  }
}
```

## 3. Error Handling Patterns

### Pattern 1: Specific Error Handling

```dart
Future<void> specificErrorHandling() async {
  final secureStorage = getIt<SecureStorageService>();
  
  final result = await secureStorage.read(key: 'auth_token');
  
  result.fold(
    (failure) {
      if (failure is SecureStorageKeyNotFoundFailure) {
        // Key doesn't exist - user not logged in
        print('User not logged in');
        navigateToLogin();
      } else if (failure is SecureStorageAccessDeniedFailure) {
        // Platform denied access
        print('Access denied by platform');
        showAccessDeniedDialog();
      } else if (failure is SecureStorageDeviceLockRequiredFailure) {
        // Device needs to be unlocked
        print('Please unlock your device');
        showUnlockDeviceDialog();
      } else if (failure is SecureStorageEncryptionFailure) {
        // Encryption error
        print('Encryption error - data may be corrupted');
        clearCorruptedDataAndLogout();
      } else {
        // Unknown error
        print('Unknown error: $failure');
        showGenericErrorDialog();
      }
    },
    (token) {
      if (token != null) {
        // Use token
        useToken(token);
      } else {
        // Key exists but value is null
        print('Token is null');
      }
    },
  );
}
```

### Pattern 2: Retry with Exponential Backoff

```dart
Future<Either<SecureStorageFailure, T?>> readWithRetry<T>({
  required String key,
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  final secureStorage = getIt<SecureStorageService>();
  
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    final result = await secureStorage.read(key: key);
    
    // Success or non-retryable error
    final shouldRetry = result.fold(
      (failure) {
        // Don't retry for these errors
        if (failure is SecureStorageInvalidKeyFailure ||
            failure is SecureStorageKeyNotFoundFailure ||
            failure is SecureStoragePlatformNotSupportedFailure) {
          return false;
        }
        return true;
      },
      (_) => false, // Success, no retry needed
    );
    
    if (!shouldRetry) {
      return result as Either<SecureStorageFailure, T?>;
    }
    
    // Wait before retry with exponential backoff
    if (attempt < maxRetries - 1) {
      final delay = initialDelay * (attempt + 1);
      await Future.delayed(delay);
    }
  }
  
  // Last attempt
  return await secureStorage.read(key: key) as Either<SecureStorageFailure, T?>;
}
```

### Pattern 3: Fallback to Default Value

```dart
Future<String> readOrDefault({
  required String key,
  required String defaultValue,
}) async {
  final secureStorage = getIt<SecureStorageService>();
  
  final result = await secureStorage.read(key: key);
  
  return result.fold(
    (failure) {
      // Log error
      logger.error('Failed to read $key: $failure');
      return defaultValue;
    },
    (value) => value ?? defaultValue,
  );
}

// Usage
final token = await readOrDefault(
  key: SecureStorageConstants.authToken,
  defaultValue: '',
);
```

## 4. Platform-Specific Examples

### iOS: Using Different Accessibility Levels

```dart
class IOSSecureStorage {
  final SecureStorageService _secureStorage;
  
  IOSSecureStorage(this._secureStorage);
  
  /// Save token accessible after first unlock
  /// (Good for background operations like push notifications)
  Future<void> saveTokenForBackground(String token) async {
    await _secureStorage.write(
      key: SecureStorageConstants.authToken,
      value: token,
      options: SecureStorageOptions(
        accessibility: KeychainAccessibility.firstUnlock,
      ),
    );
  }
  
  /// Save highly sensitive data (only when unlocked)
  Future<void> saveSensitiveData(String data) async {
    await _secureStorage.write(
      key: 'sensitive_data',
      value: data,
      options: SecureStorageOptions(
        accessibility: KeychainAccessibility.unlocked,
      ),
    );
  }
  
  /// Save device-specific secret (no iCloud backup)
  Future<void> saveDeviceSecret(String secret) async {
    await _secureStorage.write(
      key: 'device_secret',
      value: secret,
      options: SecureStorageOptions(
        accessibility: KeychainAccessibility.firstUnlockThisDeviceOnly,
        iCloudSync: false,
      ),
    );
  }
  
  /// Save data requiring device passcode
  Future<void> saveWithPasscodeProtection(String data) async {
    await _secureStorage.write(
      key: 'passcode_protected',
      value: data,
      options: SecureStorageOptions(
        accessibility: KeychainAccessibility.passcodeSetThisDeviceOnly,
      ),
    );
  }
}
```

### Android: KeyStore vs EncryptedSharedPreferences

```dart
// Option 1: Using EncryptedSharedPreferences (Recommended for API 23+)
void setupEncryptedSharedPreferences() {
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(
      options: SecureStorageOptions(
        useEncryptedSharedPreferences: true,
      ),
    ),
  );
}

// Option 2: Using KeyStore (For API 18+ support)
void setupKeyStore() {
  getIt.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageServiceImpl(
      options: SecureStorageOptions(
        useEncryptedSharedPreferences: false,
      ),
    ),
  );
}

// Option 3: Conditional based on Android version
void setupBasedOnVersion() {
  getIt.registerLazySingleton<SecureStorageService>(
    () {
      // Check Android SDK version
      final useEncrypted = Platform.isAndroid && 
                           android.Build.VERSION.SDK_INT >= 23;
      
      return FlutterSecureStorageServiceImpl(
        options: SecureStorageOptions(
          useEncryptedSharedPreferences: useEncrypted,
        ),
      );
    },
  );
}
```

## 5. Advanced Patterns

### Pattern 1: Key Rotation

```dart
class SecureStorageWithRotation {
  final SecureStorageService _secureStorage;
  
  SecureStorageWithRotation(this._secureStorage);
  
  /// Rotate token (move from old key to new key)
  Future<void> rotateToken() async {
    // Read old token
    final oldResult = await _secureStorage.read(
      key: 'auth_token_v1',
    );
    
    await oldResult.fold(
      (failure) async {
        // Old key doesn't exist, nothing to rotate
      },
      (oldToken) async {
        if (oldToken != null) {
          // Save to new key
          await _secureStorage.write(
            key: 'auth_token_v2',
            value: oldToken,
          );
          
          // Delete old key
          await _secureStorage.delete(key: 'auth_token_v1');
        }
      },
    );
  }
  
  /// Get token from current or previous version
  Future<String?> getTokenWithFallback() async {
    // Try new key first
    var result = await _secureStorage.read(key: 'auth_token_v2');
    
    var token = result.fold(
      (failure) => null,
      (value) => value,
    );
    
    if (token != null) return token;
    
    // Fallback to old key
    result = await _secureStorage.read(key: 'auth_token_v1');
    
    token = result.fold(
      (failure) => null,
      (value) => value,
    );
    
    if (token != null) {
      // Migrate to new key
      await rotateToken();
    }
    
    return token;
  }
}
```

### Pattern 2: Encrypted Metadata

```dart
class SecureStorageWithMetadata {
  final SecureStorageService _secureStorage;
  
  SecureStorageWithMetadata(this._secureStorage);
  
  /// Save with timestamp metadata
  Future<void> saveWithMetadata({
    required String key,
    required String value,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    
    // Save value
    await _secureStorage.write(key: key, value: value);
    
    // Save timestamp
    await _secureStorage.write(
      key: '${key}_timestamp',
      value: timestamp,
    );
  }
  
  /// Read with expiration check
  Future<String?> readWithExpiration({
    required String key,
    required Duration maxAge,
  }) async {
    // Read value
    final valueResult = await _secureStorage.read(key: key);
    final value = valueResult.fold(
      (failure) => null,
      (v) => v,
    );
    
    if (value == null) return null;
    
    // Read timestamp
    final timestampResult = await _secureStorage.read(
      key: '${key}_timestamp',
    );
    
    final timestampStr = timestampResult.fold(
      (failure) => null,
      (v) => v,
    );
    
    if (timestampStr == null) return value;
    
    // Check expiration
    final timestamp = DateTime.parse(timestampStr);
    final age = DateTime.now().difference(timestamp);
    
    if (age > maxAge) {
      // Expired, delete
      await _secureStorage.delete(key: key);
      await _secureStorage.delete(key: '${key}_timestamp');
      return null;
    }
    
    return value;
  }
}
```

### Pattern 3: Secure Storage Repository

```dart
class SecureStorageRepository {
  final SecureStorageService _secureStorage;
  
  SecureStorageRepository(this._secureStorage);
  
  /// Generic save method with error handling
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T value,
    SecureStorageOptions? options,
  }) async {
    try {
      final stringValue = _serialize(value);
      
      final result = await _secureStorage.write(
        key: key,
        value: stringValue,
        options: options,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Serialization error: $e'),
      );
    }
  }
  
  /// Generic get method with deserialization
  Future<Either<Failure, T?>> get<T>({
    required String key,
    SecureStorageOptions? options,
  }) async {
    try {
      final result = await _secureStorage.read(
        key: key,
        options: options,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (stringValue) {
          if (stringValue == null) return const Right(null);
          
          final value = _deserialize<T>(stringValue);
          return Right(value);
        },
      );
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Deserialization error: $e'),
      );
    }
  }
  
  String _serialize<T>(T value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    
    // For complex objects, use JSON
    return jsonEncode(value);
  }
  
  T? _deserialize<T>(String value) {
    if (T == String) return value as T;
    if (T == int) return int.parse(value) as T;
    if (T == double) return double.parse(value) as T;
    if (T == bool) return (value == 'true') as T;
    
    // For complex objects, decode JSON
    return jsonDecode(value) as T;
  }
}
```

## 6. Integration Examples

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_core/app_core.dart';

// Provider for secure storage
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return FlutterSecureStorageServiceImpl(
    options: SecureStorageOptions.balanced(),
  );
});

// Provider for auth token
final authTokenProvider = FutureProvider<String?>((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  
  final result = await secureStorage.read(
    key: SecureStorageConstants.authToken,
  );
  
  return result.fold(
    (failure) => null,
    (token) => token,
  );
});

// Provider for login state
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  
  final result = await secureStorage.containsKey(
    key: SecureStorageConstants.authToken,
  );
  
  return result.fold(
    (failure) => false,
    (exists) => exists,
  );
});

// Usage in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedInAsync = ref.watch(isLoggedInProvider);
    
    return isLoggedInAsync.when(
      data: (isLoggedIn) {
        if (isLoggedIn) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
      loading: () => LoadingScreen(),
      error: (err, stack) => ErrorScreen(error: err),
    );
  }
}
```

### With Bloc

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app_core.dart';

// Events
abstract class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String token;
  AuthLoginRequested(this.token);
}
class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService _secureStorage;
  
  AuthBloc(this._secureStorage) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _secureStorage.read(
      key: SecureStorageConstants.authToken,
    );
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (token) {
        if (token != null) {
          emit(AuthAuthenticated(token));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _secureStorage.write(
      key: SecureStorageConstants.authToken,
      value: event.token,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthAuthenticated(event.token)),
    );
  }
  
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    await _secureStorage.delete(
      key: SecureStorageConstants.authToken,
    );
    
    emit(AuthUnauthenticated());
  }
}
```

## 7. Testing Examples

### Mock Secure Storage

```dart
import 'package:mocktail/mocktail.dart';
import 'package:app_core/app_core.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockSecureStorage;
  late AuthService authService;
  
  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    authService = AuthService(mockSecureStorage);
  });
  
  group('AuthService', () {
    test('login saves token to secure storage', () async {
      // Arrange
      when(() => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => const Right(null));
      
      // Act
      await authService.login(
        email: 'test@example.com',
        password: 'password',
      );
      
      // Assert
      verify(() => mockSecureStorage.write(
        key: SecureStorageConstants.authToken,
        value: any(named: 'value'),
      )).called(1);
    });
    
    test('getAccessToken returns token from secure storage', () async {
      // Arrange
      const expectedToken = 'test_token';
      when(() => mockSecureStorage.read(
        key: any(named: 'key'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => const Right(expectedToken));
      
      // Act
      final token = await authService.getAccessToken();
      
      // Assert
      expect(token, expectedToken);
      verify(() => mockSecureStorage.read(
        key: SecureStorageConstants.authToken,
      )).called(1);
    });
    
    test('isLoggedIn returns true when token exists', () async {
      // Arrange
      when(() => mockSecureStorage.containsKey(
        key: any(named: 'key'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => const Right(true));
      
      // Act
      final isLoggedIn = await authService.isLoggedIn();
      
      // Assert
      expect(isLoggedIn, true);
    });
    
    test('logout deletes all auth keys', () async {
      // Arrange
      when(() => mockSecureStorage.delete(
        key: any(named: 'key'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => const Right(null));
      
      // Act
      await authService.logout();
      
      // Assert
      verify(() => mockSecureStorage.delete(
        key: any(named: 'key'),
      )).called(greaterThan(0));
    });
  });
}
```

### Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_core/app_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('SecureStorage Integration Tests', () {
    late SecureStorageService secureStorage;
    
    setUp(() async {
      secureStorage = FlutterSecureStorageServiceImpl(
        options: SecureStorageOptions.balanced(),
      );
      
      // Clean up before each test
      await secureStorage.deleteAll();
    });
    
    tearDown(() async {
      // Clean up after each test
      await secureStorage.deleteAll();
    });
    
    test('write and read token', () async {
      const key = 'test_token';
      const value = 'test_value';
      
      // Write
      final writeResult = await secureStorage.write(
        key: key,
        value: value,
      );
      
      expect(writeResult.isRight(), true);
      
      // Read
      final readResult = await secureStorage.read(key: key);
      
      expect(readResult.isRight(), true);
      readResult.fold(
        (failure) => fail('Should not fail'),
        (readValue) => expect(readValue, value),
      );
    });
    
    test('delete removes key', () async {
      const key = 'test_token';
      const value = 'test_value';
      
      // Write
      await secureStorage.write(key: key, value: value);
      
      // Delete
      await secureStorage.delete(key: key);
      
      // Verify deleted
      final containsResult = await secureStorage.containsKey(key: key);
      
      containsResult.fold(
        (failure) => fail('Should not fail'),
        (exists) => expect(exists, false),
      );
    });
    
    test('deleteAll removes all keys', () async {
      // Write multiple keys
      await secureStorage.write(key: 'key1', value: 'value1');
      await secureStorage.write(key: 'key2', value: 'value2');
      await secureStorage.write(key: 'key3', value: 'value3');
      
      // Delete all
      await secureStorage.deleteAll();
      
      // Verify all deleted
      final keysResult = await secureStorage.getAllKeys();
      
      keysResult.fold(
        (failure) => fail('Should not fail'),
        (keys) => expect(keys.isEmpty, true),
      );
    });
  });
}
```

---

## Summary

This document provides comprehensive examples for:
- ✅ Basic CRUD operations
- ✅ Complete authentication flows
- ✅ Error handling patterns
- ✅ Platform-specific configurations
- ✅ Advanced patterns (rotation, metadata, repository)
- ✅ Integration with state management (Riverpod, Bloc)
- ✅ Testing strategies (mocking, integration)

For more information, see:
- [README.md](README.md) - Complete documentation
- [QUICK_START.md](QUICK_START.md) - Quick start guide

