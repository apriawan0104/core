## 0.0.1

* Initial release of BUMA Core library

### Features

#### Infrastructure Layer

- **Logging Service**: Console and Logger package implementations with multiple log levels
- **Notification Service**: Firebase Cloud Messaging and local notifications support
- **Storage Service**: Hive-based local storage with performance optimizations
- **Responsive Service**: Screen size utilities using flutter_screenutil
- **Network Service**: HTTP networking with Dio implementation
  - Generic `HttpClient` interface (dependency independent)
  - `DioHttpClient` implementation
  - Type-safe requests with `Either<Failure, Success>`
  - Request/Response/Error interceptors
  - File upload/download with progress tracking
  - Comprehensive error handling with specific failure types
  - Easy to switch HTTP client implementations

#### Domain Layer

- Domain entities for notifications
- Domain entities for network (HttpResponse, RequestOptions, HttpMethod)

#### Error Handling

- Base `Failure` class
- Network-specific failures:
  - `NetworkFailure` (base)
  - `ConnectionFailure`
  - `TimeoutFailure`
  - `ServerFailure`
  - `ClientFailure`
  - `UnauthorizedFailure`
  - `ForbiddenFailure`
  - `NotFoundFailure`
  - `ParseFailure`
  - `CancelFailure`
  - `UnknownNetworkFailure`

#### Configuration

- Dependency injection setup with get_it and injectable
- Modular registration system

### Documentation

- Complete project guidelines (GUIDELINES.md)
- Architecture documentation (ARCHITECTURE.md)
- Logging setup guide (LOGGING_SETUP.md)
- Storage setup guide (STORAGE_SETUP.md)
- Network setup guide (NETWORK_SETUP.md)
- Migration guides

### Examples

- Logging examples
- Notification examples
- Storage examples with performance benchmarks
- Network examples with complete repository pattern demo

### Dependencies

- dartz: ^0.10.1 (Functional programming)
- dio: ^5.7.0 (HTTP client)
- equatable: ^2.0.7
- firebase_messaging: ^16.0.3
- flutter_local_notifications: ^17.2.3
- flutter_screenutil: ^5.9.3
- get_it: ^8.2.0
- hive: ^2.2.3
- injectable: ^2.5.1
- logger: ^2.6.2
