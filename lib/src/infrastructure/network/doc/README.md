# Network Service

Generic HTTP networking layer for Flutter applications. This service wraps HTTP client implementations (currently Dio) following the Dependency Inversion Principle, making it easy to switch between different HTTP packages without affecting business logic.

## Features

- ✅ **Dependency Independent**: Easy to switch from Dio to other HTTP clients
- ✅ **Type-Safe**: Full TypeScript-like generic support with Either<Failure, Success>
- ✅ **Interceptors**: Request, response, and error interceptors
- ✅ **Upload/Download**: File upload and download with progress callbacks
- ✅ **Error Handling**: Comprehensive error handling with specific failure types
- ✅ **Flexible**: Configurable timeouts, headers, and options
- ✅ **Testable**: Easy to mock for unit testing

## Architecture

```
infrastructure/network/
├── contract/           # Abstract interface (HttpClient)
│   └── http_client.service.dart
├── impl/              # Concrete implementations
│   └── dio_http_client.service.impl.dart
├── constants/         # Network constants
│   └── network.constant.dart
└── doc/              # Documentation
    └── README.md
```

**Key Principle**: The `HttpClient` interface is completely independent from Dio. You can create implementations using:
- Dio (current implementation)
- http package
- Chopper
- Or any other HTTP client

## Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  app_core: ^x.x.x  # Replace with actual version
  dartz: ^0.10.1
  dio: ^5.7.0       # Only needed if using DioHttpClient
```

## Basic Usage

### 1. Setup with Dependency Injection

```dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupNetworking() {
  // Register HttpClient implementation
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://api.example.com',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: 30000,
      receiveTimeout: 30000,
      enableLogging: true, // Enable logging in debug mode
    ),
  );
}
```

### 2. Make HTTP Requests

```dart
import 'package:app_core/app_core.dart';

class UserRepository {
  final HttpClient _httpClient;

  UserRepository(this._httpClient);

  Future<Either<NetworkFailure, List<User>>> getUsers() async {
    final result = await _httpClient.get<List<dynamic>>(
      '/users',
      queryParameters: {'page': 1, 'limit': 10},
    );

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

  Future<Either<NetworkFailure, void>> deleteUser(String id) async {
    final result = await _httpClient.delete(
      '/users/$id',
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
```

## Advanced Features

### Interceptors

Add custom interceptors for authentication, logging, or error handling:

```dart
// Request Interceptor - Add auth token
httpClient.addRequestInterceptor((options) async {
  final token = await getAuthToken();
  
  final headers = {...?options.headers};
  headers['Authorization'] = 'Bearer $token';
  
  return options.copyWith(headers: headers);
});

// Response Interceptor - Log responses
httpClient.addResponseInterceptor((response) async {
  print('Response from ${response.statusCode}');
  return response;
});

// Error Interceptor - Handle token refresh
httpClient.addErrorInterceptor((failure) async {
  if (failure is UnauthorizedFailure) {
    // Try to refresh token
    final newToken = await refreshAuthToken();
    
    if (newToken != null) {
      // Retry request with new token
      // Return Right to indicate recovery
    }
  }
  
  // Return Left to continue error chain
  return Left(failure);
});
```

### File Upload

```dart
Future<Either<NetworkFailure, UploadResponse>> uploadProfilePicture(
  String filePath,
) async {
  final result = await httpClient.upload<Map<String, dynamic>>(
    '/users/profile/picture',
    filePath,
    fieldName: 'avatar',
    data: {
      'userId': '123',
      'description': 'Profile picture',
    },
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload progress: $progress%');
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
  String url,
  String savePath,
) async {
  final result = await httpClient.download(
    url,
    savePath,
    onProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(2);
      print('Download progress: $progress%');
    },
  );

  return result; // Returns the save path on success
}
```

### Custom Request Options

For more control over requests:

```dart
final result = await httpClient.request<Map<String, dynamic>>(
  RequestOptionsEntity(
    url: '/custom-endpoint',
    method: HttpMethod.post,
    headers: {'Custom-Header': 'Value'},
    queryParameters: {'param': 'value'},
    data: {'key': 'value'},
    connectTimeout: 60000,
    receiveTimeout: 60000,
    responseType: ResponseType.json,
  ),
);
```

## Error Handling

The service provides specific failure types for better error handling:

```dart
final result = await httpClient.get('/users');

result.fold(
  (failure) {
    if (failure is ConnectionFailure) {
      // No internet connection
      showError('Please check your internet connection');
    } else if (failure is TimeoutFailure) {
      // Request timeout
      showError('Request took too long. Please try again.');
    } else if (failure is UnauthorizedFailure) {
      // 401 - Need to login again
      navigateToLogin();
    } else if (failure is NotFoundFailure) {
      // 404 - Resource not found
      showError('Resource not found');
    } else if (failure is ServerFailure) {
      // 5xx - Server error
      showError('Server error. Please try again later.');
    } else {
      // Generic error
      showError(failure.message);
    }
  },
  (response) {
    // Success - process data
    final users = processUsers(response.data);
  },
);
```

### Available Failure Types

- `NetworkFailure` - Base class for all network failures
- `ConnectionFailure` - No internet or server unreachable
- `TimeoutFailure` - Request timeout
- `ServerFailure` - 5xx errors
- `ClientFailure` - 4xx errors
- `UnauthorizedFailure` - 401 Unauthorized
- `ForbiddenFailure` - 403 Forbidden
- `NotFoundFailure` - 404 Not Found
- `ParseFailure` - Invalid response format
- `CancelFailure` - Request was cancelled
- `UnknownNetworkFailure` - Unexpected error

## Testing

The service is designed to be easily mockable:

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
    return Right(HttpResponseEntity<T>(
      data: mockData as T,
      statusCode: 200,
      statusMessage: 'OK',
    ));
  }

  // Implement other methods...
}

// Use in tests
void main() {
  late UserRepository repository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = UserRepository(mockHttpClient);
  });

  test('should get users successfully', () async {
    // Test with mock
    final result = await repository.getUsers();
    expect(result.isRight(), true);
  });
}
```

## Switching HTTP Client Implementation

To switch from Dio to another HTTP client (e.g., `http` package):

1. **Create new implementation**:

```dart
class HttpPackageClient implements HttpClient {
  final http.Client _client;
  
  HttpPackageClient(this._client);
  
  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters),
        headers: headers?.cast<String, String>(),
      );
      
      // Convert http.Response to HttpResponseEntity
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  // Implement other methods...
}
```

2. **Update DI registration** (ONLY change needed):

```dart
// Old:
// getIt.registerLazySingleton<HttpClient>(
//   () => DioHttpClient(...),
// );

// New:
getIt.registerLazySingleton<HttpClient>(
  () => HttpPackageClient(http.Client()),
);
```

3. **Done!** All your business logic continues to work without any changes.

## Configuration

### Environment-Based Configuration

```dart
String getBaseUrl() {
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  switch (environment) {
    case 'prod':
      return 'https://api.production.com';
    case 'staging':
      return 'https://api.staging.com';
    default:
      return 'https://api.dev.com';
  }
}

void setupNetworking() {
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: getBaseUrl(),
      connectTimeout: 30000,
      receiveTimeout: 30000,
      enableLogging: !kReleaseMode, // Only log in debug mode
    ),
  );
}
```

### Multiple HTTP Clients

You can register multiple HTTP clients for different APIs:

```dart
void setupNetworking() {
  // Main API client
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://api.myapp.com',
    ),
    instanceName: 'mainApi',
  );

  // External API client
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://external-api.com',
      headers: {
        'X-API-Key': 'your-api-key',
      },
    ),
    instanceName: 'externalApi',
  );
}

// Use in repository
class MyRepository {
  final HttpClient _mainClient;
  final HttpClient _externalClient;

  MyRepository()
      : _mainClient = getIt<HttpClient>(instanceName: 'mainApi'),
        _externalClient = getIt<HttpClient>(instanceName: 'externalApi');
}
```

## Best Practices

1. **Always use Either for error handling** - Never throw exceptions from repositories
2. **Handle all failure types** - Provide appropriate user feedback for each error type
3. **Use interceptors wisely** - Don't overuse them; keep logic simple
4. **Type your responses** - Use generics for type-safe responses
5. **Keep baseUrl in config** - Don't hardcode URLs in code
6. **Add authentication in interceptors** - Centralize auth logic
7. **Enable logging in debug only** - Disable in production for performance
8. **Test with mocks** - Always test repositories with mock HTTP clients

## Constants

Use `NetworkConstants` for common values:

```dart
import 'package:app_core/app_core.dart';

final headers = {
  NetworkConstants.headerContentType: NetworkConstants.contentTypeJson,
  NetworkConstants.headerAuthorization: 'Bearer $token',
};

if (response.statusCode == NetworkConstants.statusOk) {
  // Success
}
```

## Performance Tips

1. **Reuse client instance** - Register as singleton, don't create multiple instances
2. **Set appropriate timeouts** - Balance between UX and reliability
3. **Use connection pooling** - Dio does this by default
4. **Cancel requests when not needed** - Clean up in dispose methods
5. **Cache responses** - Implement caching layer in repositories

## Troubleshooting

### Common Issues

**Issue**: `Target of URI doesn't exist: 'package:dartz/dartz.dart'`
**Solution**: Run `flutter pub get` to install dependencies

**Issue**: Timeout errors in development
**Solution**: Increase timeout values for slow networks

**Issue**: SSL certificate errors
**Solution**: Ensure your server has valid SSL certificate, or add certificate pinning

**Issue**: 401 Unauthorized after token refresh
**Solution**: Implement token refresh in error interceptor

## Migration Guide

### From Direct Dio Usage

If you were using Dio directly:

**Before:**
```dart
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
final response = await dio.get('/users');
final users = response.data;
```

**After:**
```dart
final httpClient = getIt<HttpClient>();
final result = await httpClient.get<List<dynamic>>('/users');

result.fold(
  (failure) => handleError(failure),
  (response) {
    final users = response.data;
  },
);
```

## Related Documentation

- [Project Architecture](../../../ARCHITECTURE.md)
- [Project Guidelines](../../../GUIDELINES.md)
- [Error Handling](../../../errors/README.md)

## Support

For issues or questions, please refer to the main project documentation or create an issue in the repository.

