# BUMA Core Library

Flutter core library providing reusable business logic, infrastructure services, and utilities for all BUMA mobile applications.

## 🎯 Features

### Infrastructure Services

- **Background Service** - Run Dart code in background even when app is closed
  - Generic `BackgroundService` interface (works with flutter_background_service, etc.)
  - Foreground service mode with notifications (Android)
  - Background mode without notifications (Android)
  - iOS background fetch support
  - Two-way communication between UI and background
  - Dependency-independent design
  
- **Network Service** - HTTP networking with dependency-independent design
  - Generic `HttpClient` interface (works with Dio, http, Chopper, etc.)
  - Type-safe requests with `Either<Failure, Success>`
  - Request/Response/Error interceptors
  - File upload/download with progress tracking
  - Comprehensive error handling
  
- **Logging Service** - Flexible logging with multiple implementations
  - Console logging for development
  - Logger package integration
  - Multiple log levels (trace, debug, info, warning, error, fatal)
  
- **Storage Service** - Local data persistence
  - Hive-based implementation
  - High-performance async operations
  - Type-safe storage
  
- **Notification Service** - Push and local notifications
  - Firebase Cloud Messaging integration
  - Local notifications support
  - Custom notification handling
  
- **Responsive Service** - Screen size utilities
  - Flutter ScreenUtil integration
  - Responsive layouts
  
- **Chart Service** - Data visualization with charts
  - Generic `ChartService` interface (works with Syncfusion, fl_chart, etc.)
  - 30+ chart types (line, column, pie, etc.)
  - Interactive features (zoom, pan, tooltip)
  - Sparkline charts for dashboards
  - Dependency-independent design

### Domain Layer

- Clean Architecture principles
- Dependency Inversion Principle
- Reusable domain entities
- Well-defined contracts

### Error Handling

- Functional error handling with `Either<Failure, Success>`
- Comprehensive failure types
- Network-specific errors (ConnectionFailure, TimeoutFailure, etc.)

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  app_core:
    path: ../core  # Adjust path as needed
```

Run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Setup Dependency Injection

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Setup network
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://api.yourapp.com',
      enableLogging: true,
    ),
  );
  
  // Setup other services...
}
```

### 2. Use in Repository

```dart
import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';

class UserRepository {
  final HttpClient _httpClient;
  
  UserRepository(this._httpClient);
  
  Future<Either<NetworkFailure, User>> getUser(String id) async {
    final result = await _httpClient.get<Map<String, dynamic>>('/users/$id');
    
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(User.fromJson(response.data!)),
    );
  }
}
```

### 3. Handle Results in UI

```dart
void loadUser() async {
  final result = await repository.getUser('123');
  
  result.fold(
    (failure) {
      // Handle error
      if (failure is ConnectionFailure) {
        showError('No internet connection');
      } else if (failure is UnauthorizedFailure) {
        navigateToLogin();
      } else {
        showError(failure.message);
      }
    },
    (user) {
      // Success - update UI
      setState(() => _user = user);
    },
  );
}
```

## 📚 Documentation

- **[Background Service Setup Guide](BACKGROUND_SERVICE_SETUP.md)** - Background task execution
- **[Chart Setup Guide](CHART_SETUP.md)** - Chart visualization and data display
- **[Network Setup Guide](NETWORK_SETUP.md)** - Complete guide for HTTP networking
- **[Logging Setup Guide](LOGGING_SETUP.md)** - Logging service configuration
- **[Storage Setup Guide](STORAGE_SETUP.md)** - Local storage usage
- **[Architecture](ARCHITECTURE.md)** - Architecture overview and principles
- **[Project Guidelines](PROJECT_GUIDELINES.md)** - Development guidelines and best practices

## 📖 Examples

Check the `example/` directory for complete working examples:

- `background_service_example.dart` - Background service examples
- `chart_example.dart` - Chart visualization examples
- `network_example.dart` - HTTP networking examples
- `logging_example.dart` - Logging service examples
- `storage_example.dart` - Storage service examples
- `notification_example.dart` - Notification examples

## 🏗️ Architecture

This library follows Clean Architecture principles:

```
lib/src/
├── foundation/        # Domain layer (entities, use cases)
├── infrastructure/    # Infrastructure layer (service implementations)
├── application/       # Application layer (app-level services)
├── configuration/     # DI and configuration
├── constants/         # Global constants
├── errors/           # Error/Failure classes
├── extensions/       # Dart extensions
└── helpers/          # Utility functions
```

### Key Principles

1. **Dependency Independence** - Services are abstracted behind interfaces
2. **Testability** - All services can be easily mocked
3. **Flexibility** - Switch implementations without affecting business logic
4. **Type Safety** - Use Either<Failure, Success> for error handling
5. **Clean Code** - Follow SOLID principles

## 🧪 Testing

All services are designed to be easily testable:

```dart
class MockHttpClient implements HttpClient {
  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    return Right(HttpResponseEntity<T>(
      data: mockData as T,
      statusCode: 200,
    ));
  }
  
  // Implement other methods...
}
```

## 🔧 Dependencies

Core dependencies:

- `dartz` - Functional programming
- `dio` - HTTP client
- `flutter_background_service` - Background task execution
- `get_it` - Dependency injection
- `injectable` - Code generation for DI
- `hive` - Local storage
- `firebase_messaging` - Push notifications
- `logger` - Logging

See `pubspec.yaml` for complete list.

## 📋 Requirements

- Dart SDK: `^3.5.0`
- Flutter: `>=3.24.0`

## 🤝 Contributing

This is an internal library for BUMA applications. Follow the guidelines in `GUIDELINES.md` when contributing.

### Before Committing

1. Run tests: `flutter test`
2. Run analysis: `flutter analyze`
3. Update documentation if needed
4. Update CHANGELOG.md

## 📄 License

Proprietary - BUMA Internal Use Only

## 🆘 Support

For issues or questions:

1. Check the relevant documentation files
2. See examples in `example/` directory
3. Contact the core team

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

**Made with ❤️ by BUMA Core Team**
