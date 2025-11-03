# Network Service Setup Guide

This guide will help you set up and use the HTTP Network service in your Flutter application.

## 📋 Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
4. [Basic Usage](#basic-usage)
5. [Advanced Features](#advanced-features)
6. [Error Handling](#error-handling)
7. [Testing](#testing)
8. [Best Practices](#best-practices)

## 📦 Installation

### 1. Add Dependencies

The network service requires `dio` and `dartz` packages. They should already be included in `app_core`, but if not, add them to your `pubspec.yaml`:

```yaml
dependencies:
  app_core:
    path: ../core  # or your path to core package
  dartz: ^0.10.1
  dio: ^5.7.0
```

### 2. Run pub get

```bash
flutter pub get
```

## 🚀 Quick Start

### Step 1: Setup Dependency Injection

In your app's DI setup file (e.g., `lib/config/di/injection.dart`):

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart'; // for kReleaseMode

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ... other registrations

  // Register HttpClient
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://api.yourapp.com',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: 30000,      // 30 seconds
      receiveTimeout: 30000,      // 30 seconds
      sendTimeout: 30000,         // 30 seconds
      enableLogging: !kReleaseMode, // Only log in debug mode
    ),
  );
}
```

### Step 2: Create a Repository

Create a repository that uses the `HttpClient`:

```dart
import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';

class UserRepository {
  final HttpClient _httpClient;

  UserRepository(this._httpClient);

  Future<Either<NetworkFailure, List<User>>> getUsers() async {
    final result = await _httpClient.get<List<dynamic>>('/users');

    return result.fold(
      (failure) => Left(failure),
      (response) {
        final users = (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
        return Right(users);
      },
    );
  }
}
```

### Step 3: Register Repository

```dart
void setupDependencyInjection() {
  // ... HttpClient registration above
  
  // Register repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<HttpClient>()),
  );
}
```

### Step 4: Use in Your App

```dart
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _repository = getIt<UserRepository>();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getUsers();

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (users) {
        setState(() {
          _isLoading = false;
          _users = users;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  }
}
```

## ⚙️ Configuration

### Environment-Based Configuration

```dart
class AppConfig {
  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    switch (env) {
      case 'prod':
        return 'https://api.production.com';
      case 'staging':
        return 'https://api.staging.com';
      default:
        return 'https://api.dev.com';
    }
  }
  
  static Map<String, dynamic> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-App-Version': '1.0.0',
  };
}

// Usage
getIt.registerLazySingleton<HttpClient>(
  () => DioHttpClient(
    baseUrl: AppConfig.baseUrl,
    headers: AppConfig.defaultHeaders,
    connectTimeout: 30000,
    receiveTimeout: 30000,
    enableLogging: !kReleaseMode,
  ),
);
```

### Multiple API Clients

If you need to connect to multiple APIs:

```dart
void setupDependencyInjection() {
  // Main API
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://api.myapp.com',
    ),
    instanceName: 'mainApi',
  );

  // Payment API
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://payment-api.example.com',
      headers: {
        'X-API-Key': 'your-payment-api-key',
      },
    ),
    instanceName: 'paymentApi',
  );
}

// Usage in repository
class PaymentRepository {
  final HttpClient _paymentClient;

  PaymentRepository()
      : _paymentClient = getIt<HttpClient>(instanceName: 'paymentApi');
}
```

## 📖 Basic Usage

### GET Request

```dart
Future<Either<NetworkFailure, User>> getUser(String id) async {
  final result = await _httpClient.get<Map<String, dynamic>>(
    '/users/$id',
  );

  return result.fold(
    (failure) => Left(failure),
    (response) => Right(User.fromJson(response.data!)),
  );
}
```

### POST Request

```dart
Future<Either<NetworkFailure, User>> createUser(User user) async {
  final result = await _httpClient.post<Map<String, dynamic>>(
    '/users',
    data: user.toJson(),
  );

  return result.fold(
    (failure) => Left(failure),
    (response) => Right(User.fromJson(response.data!)),
  );
}
```

### PUT Request

```dart
Future<Either<NetworkFailure, User>> updateUser(String id, User user) async {
  final result = await _httpClient.put<Map<String, dynamic>>(
    '/users/$id',
    data: user.toJson(),
  );

  return result.fold(
    (failure) => Left(failure),
    (response) => Right(User.fromJson(response.data!)),
  );
}
```

### DELETE Request

```dart
Future<Either<NetworkFailure, void>> deleteUser(String id) async {
  final result = await _httpClient.delete('/users/$id');

  return result.fold(
    (failure) => Left(failure),
    (_) => const Right(null),
  );
}
```

### Query Parameters

```dart
final result = await _httpClient.get<List<dynamic>>(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 20,
    'sort': 'name',
    'order': 'asc',
  },
);
```

### Custom Headers

```dart
final result = await _httpClient.get<Map<String, dynamic>>(
  '/protected-resource',
  headers: {
    'Authorization': 'Bearer $token',
    'X-Custom-Header': 'custom-value',
  },
);
```

## 🔥 Advanced Features

### Interceptors

#### Authentication Interceptor

```dart
void setupNetworkInterceptors() {
  final httpClient = getIt<HttpClient>();

  // Add auth token to all requests
  httpClient.addRequestInterceptor((options) async {
    final token = await getIt<AuthService>().getToken();
    
    if (token != null) {
      final headers = {...?options.headers};
      headers['Authorization'] = 'Bearer $token';
      return options.copyWith(headers: headers);
    }
    
    return options;
  });
}
```

#### Token Refresh Interceptor

```dart
void setupTokenRefreshInterceptor() {
  final httpClient = getIt<HttpClient>();

  httpClient.addErrorInterceptor((failure) async {
    if (failure is UnauthorizedFailure) {
      // Try to refresh token
      final authService = getIt<AuthService>();
      final newToken = await authService.refreshToken();
      
      if (newToken != null) {
        // Token refreshed successfully
        // The next retry will use the new token
        // Note: You'll need to implement retry logic in your repository
        return Left(failure); // or implement retry here
      } else {
        // Refresh failed, logout user
        await authService.logout();
        // Navigate to login
      }
    }
    
    return Left(failure);
  });
}
```

#### Logging Interceptor

```dart
void setupLoggingInterceptor() {
  final httpClient = getIt<HttpClient>();

  httpClient.addRequestInterceptor((options) async {
    print('→ REQUEST: ${options.method} ${options.url}');
    print('  Headers: ${options.headers}');
    print('  Data: ${options.data}');
    return options;
  });

  httpClient.addResponseInterceptor((response) async {
    print('← RESPONSE: ${response.statusCode}');
    print('  Data: ${response.data}');
    return response;
  });

  httpClient.addErrorInterceptor((failure) async {
    print('✗ ERROR: ${failure.runtimeType} - ${failure.message}');
    return Left(failure);
  });
}
```

### File Upload

```dart
Future<Either<NetworkFailure, UploadResponse>> uploadImage(
  String imagePath,
) async {
  final result = await _httpClient.upload<Map<String, dynamic>>(
    '/upload/image',
    imagePath,
    fieldName: 'image',
    data: {
      'description': 'Profile picture',
      'tags': ['profile', 'avatar'],
    },
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload: $progress%');
      // Update UI progress here
    },
  );

  return result.fold(
    (failure) => Left(failure),
    (response) => Right(UploadResponse.fromJson(response.data!)),
  );
}
```

### File Download

```dart
Future<Either<NetworkFailure, String>> downloadFile(
  String fileUrl,
  String savePath,
) async {
  final result = await _httpClient.download(
    fileUrl,
    savePath,
    onProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(2);
      print('Download: $progress%');
      // Update UI progress here
    },
  );

  return result; // Returns save path on success
}
```

## ⚠️ Error Handling

### Handling Specific Errors

```dart
Future<void> loadUsers() async {
  final result = await _repository.getUsers();

  result.fold(
    (failure) {
      if (failure is ConnectionFailure) {
        showSnackBar('No internet connection');
      } else if (failure is TimeoutFailure) {
        showSnackBar('Request timeout. Please try again.');
      } else if (failure is UnauthorizedFailure) {
        // Redirect to login
        navigateToLogin();
      } else if (failure is ServerFailure) {
        showSnackBar('Server error. Please try again later.');
      } else {
        showSnackBar('An error occurred: ${failure.message}');
      }
    },
    (users) {
      // Success - update UI
      setState(() => _users = users);
    },
  );
}
```

### Retry Logic

```dart
Future<Either<NetworkFailure, T>> retryRequest<T>(
  Future<Either<NetworkFailure, T>> Function() request, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  var attempts = 0;
  
  while (attempts < maxRetries) {
    final result = await request();
    
    if (result.isRight()) {
      return result;
    }
    
    // Check if error is retryable
    final failure = result.fold((l) => l, (r) => null);
    if (failure is TimeoutFailure || failure is ConnectionFailure) {
      attempts++;
      if (attempts < maxRetries) {
        await Future.delayed(delay);
        continue;
      }
    }
    
    return result;
  }
  
  return Left(TimeoutFailure(message: 'Max retries exceeded'));
}

// Usage
final result = await retryRequest(
  () => _repository.getUsers(),
  maxRetries: 3,
);
```

## 🧪 Testing

### Mock HttpClient

```dart
class MockHttpClient implements HttpClient {
  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    // Return mock data
    if (path == '/users') {
      return Right(HttpResponseEntity<T>(
        data: mockUserListData as T,
        statusCode: 200,
        statusMessage: 'OK',
      ));
    }
    
    return Left(NotFoundFailure());
  }
  
  // Implement other methods...
}
```

### Testing Repository

```dart
void main() {
  late UserRepository repository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = UserRepository(mockHttpClient);
  });

  group('UserRepository', () {
    test('getUsers returns list of users on success', () async {
      // Arrange
      // mockHttpClient is already set up to return mock data

      // Act
      final result = await repository.getUsers();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (users) {
          expect(users, isA<List<User>>());
          expect(users.length, greaterThan(0));
        },
      );
    });

    test('getUsers returns failure on error', () async {
      // Arrange
      // Configure mock to return error

      // Act
      final result = await repository.getUsers();

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

## ✅ Best Practices

### 1. Always Use Either for Error Handling

```dart
// ✅ GOOD
Future<Either<NetworkFailure, User>> getUser(String id);

// ❌ BAD
Future<User> getUser(String id); // Can throw exceptions
```

### 2. Type Your Responses

```dart
// ✅ GOOD
final result = await _httpClient.get<Map<String, dynamic>>('/user/1');

// ❌ BAD
final result = await _httpClient.get('/user/1'); // Untyped
```

### 3. Handle All Error Types

```dart
// ✅ GOOD
result.fold(
  (failure) {
    if (failure is ConnectionFailure) {
      // Handle connection error
    } else if (failure is UnauthorizedFailure) {
      // Handle unauthorized
    } else {
      // Handle other errors
    }
  },
  (data) => // Handle success,
);

// ❌ BAD
result.fold(
  (failure) => print(failure.message), // Generic handling
  (data) => // Handle success,
);
```

### 4. Use Constants

```dart
// ✅ GOOD
import 'package:app_core/app_core.dart';

final headers = {
  NetworkConstants.headerAuthorization: 'Bearer $token',
};

// ❌ BAD
final headers = {
  'Authorization': 'Bearer $token', // Magic string
};
```

### 5. Centralize Base URL Configuration

```dart
// ✅ GOOD - in config file
class ApiConfig {
  static const String baseUrl = 'https://api.myapp.com';
}

// ❌ BAD - hardcoded everywhere
DioHttpClient(baseUrl: 'https://api.myapp.com');
```

### 6. Use Dependency Injection

```dart
// ✅ GOOD
class UserRepository {
  final HttpClient _httpClient;
  UserRepository(this._httpClient);
}

// ❌ BAD
class UserRepository {
  final _httpClient = DioHttpClient(...); // Tight coupling
}
```

### 7. Keep Repositories Clean

```dart
// ✅ GOOD - Repository only handles data
class UserRepository {
  Future<Either<NetworkFailure, User>> getUser(String id) async {
    final result = await _httpClient.get('/users/$id');
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(User.fromJson(response.data!)),
    );
  }
}

// ❌ BAD - Repository contains UI logic
class UserRepository {
  Future<User> getUser(String id) async {
    showLoading(); // UI logic!
    final result = await _httpClient.get('/users/$id');
    hideLoading(); // UI logic!
    return User.fromJson(result.data);
  }
}
```

## 📚 Additional Resources

- [Full API Documentation](lib/src/infrastructure/network/doc/README.md)
- [Example Code](example/network_example.dart)
- [Project Guidelines](GUIDELINES.md)
- [Architecture Documentation](ARCHITECTURE.md)

## 🆘 Troubleshooting

### Issue: `Target of URI doesn't exist: 'package:dartz/dartz.dart'`

**Solution**: Run `flutter pub get`

### Issue: Timeout errors in production

**Solution**: Increase timeout values:

```dart
DioHttpClient(
  baseUrl: 'https://api.myapp.com',
  connectTimeout: 60000,  // Increase to 60 seconds
  receiveTimeout: 60000,
)
```

### Issue: SSL certificate errors

**Solution**: Ensure your API has valid SSL certificate. For development, you might need to configure certificate pinning.

### Issue: 401 Unauthorized after some time

**Solution**: Implement token refresh in error interceptor (see Advanced Features section)

## 🔄 Migration from Direct Dio Usage

If you're migrating from direct Dio usage:

**Before:**

```dart
final dio = Dio();
final response = await dio.get('https://api.example.com/users');
final users = (response.data as List).map((e) => User.fromJson(e)).toList();
```

**After:**

```dart
final httpClient = getIt<HttpClient>();
final result = await httpClient.get<List<dynamic>>('/users');

result.fold(
  (failure) => handleError(failure),
  (response) {
    final users = (response.data as List).map((e) => User.fromJson(e)).toList();
  },
);
```

## 📄 License

This is part of the BUMA Core library.

