# BUMA Core - Architecture Documentation

> **Version**: 2.0  
> **Last Updated**: October 17, 2025  
> **Status**: Proposed Architecture

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Detailed Explanation](#detailed-explanation)
- [Decision Guide](#decision-guide)
- [Best Practices](#best-practices)
- [FAQs](#faqs)

---

## 🎯 Overview

**BUMA Core** adalah package fundamental yang menyediakan business logic, infrastructure services, dan utilities yang digunakan di seluruh aplikasi BUMA.

### Design Principles

1. **Clear Separation of Concerns** - Setiap folder memiliki tanggung jawab yang jelas
2. **Clean Architecture** - Mengikuti prinsip dependency rule
3. **Self-Documenting** - Nama folder menjelaskan isinya tanpa dokumentasi tambahan
4. **Scalable** - Mudah untuk menambahkan feature baru
5. **Flat Structure** - Menghindari nesting berlebihan untuk kemudahan navigasi

### Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │ ← Features (di luar buma_core)
├─────────────────────────────────────────┤
│         Application Layer               │ ← application/
├─────────────────────────────────────────┤
│         Domain Layer                    │ ← foundation/domain/
├─────────────────────────────────────────┤
│         Data Layer                      │ ← foundation/data/
├─────────────────────────────────────────┤
│         Infrastructure Layer            │ ← infrastructure/
└─────────────────────────────────────────┘
```

---

## 📂 Folder Structure

```
buma_core/lib/src/
│
├── 📁 foundation/              Business logic & domain entities
│   ├── data/
│   │   └── models/             DTO for API communication
│   │
│   └── domain/
│       ├── entities/           Business entities
│       ├── params/             Use case parameters
│       ├── typedef/            Type definitions
│       └── usecases/           Business use cases
│
├── 📁 infrastructure/          Platform & 3rd party services
│   ├── analytics/              Firebase Crashlytics, PostHog
│   ├── background/             Background task service
│   ├── network/                Dio HTTP client
│   ├── notification/           FCM & local notifications
│   └── storage/                Hive local storage
│
├── 📁 application/             Application-level services
│   ├── connection/             Internet connectivity checker
│   ├── file/                   File picker & image compressor
│   ├── location/               GPS & location permissions
│   └── version/                App version management
│
├── 📁 configuration/           Setup & initialization
│   ├── di/                     Dependency injection
│   └── flavor/                 Environment configuration
│
├── 📁 constants/               Global constants
│   ├── api.cons.dart
│   ├── firebase.cons.dart
│   ├── endpoint.cons.dart
│   └── ...
│
├── 📁 errors/                  Error handling
│   ├── exceptions/             Custom exceptions
│   └── failure.dart            Failure classes
│
├── 📁 extensions/              Dart type extensions
│   ├── file.extension.dart
│   ├── list.extension.dart
│   └── string.extension.dart
│
└── 📁 helpers/                 Pure utility functions
    ├── date_time.helper.dart
    ├── logger.helper.dart
    ├── parsing.helper.dart
    └── ...
```

---

## 📖 Detailed Explanation

### 1. 📁 `foundation/`

**Purpose**: Core business logic yang menjadi fondasi aplikasi. Layer ini tidak bergantung pada framework atau library eksternal.

#### `foundation/data/`
**Contains**: Data Transfer Objects (DTO) untuk komunikasi dengan API

```dart
// Example: API Response Model
class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
}
```

**When to use**:
- ✅ Membuat model untuk parse JSON dari API
- ✅ Response wrapper untuk standardisasi API response
- ❌ Business entities (gunakan `domain/entities/`)

#### `foundation/domain/entities/`
**Contains**: Business entities yang merepresentasikan core concepts

```dart
// Example: Location Entity
class LocationEntity {
  final double latitude;
  final double longitude;
  final String? address;
}
```

**When to use**:
- ✅ Business objects yang represent domain concepts
- ✅ Entities yang digunakan di use cases
- ❌ DTO untuk API (gunakan `data/models/`)

#### `foundation/domain/params/`
**Contains**: Parameters untuk use cases

```dart
// Example: Use Case Parameter
class GetCurrentLocationParams {
  final bool highAccuracy;
  final Duration timeout;
}
```

**When to use**:
- ✅ Parameter untuk use case yang memiliki > 1 argument
- ✅ Type-safe parameter passing
- ❌ Simple single parameter (langsung pakai type)

#### `foundation/domain/usecases/`
**Contains**: Business use cases (business logic) - encapsulates single business operations

```dart
// Example: Async Use Case
class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}

// Example: Sync Use Case (validation, computation)
class ValidateEmailUseCase implements UseCase<bool, ValidateEmailParams> {
  @override
  Either<Failure, bool> call(ValidateEmailParams params) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(params.email)) {
      return Left(ValidationFailure('Invalid email format'));
    }
    
    return const Right(true);
  }
}

// Use case without parameters
class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}
```

**Available Base Classes**:
- `UseCaseAsync<T, Params>` - For async operations (network, database, I/O)
- `UseCase<T, Params>` - For sync operations (validation, computation)
- `NoParams` - For use cases that require no input parameters

**When to use**:
- ✅ Business logic yang bisa digunakan di berbagai feature
- ✅ Single responsibility - one use case does one thing
- ✅ Orchestration beberapa repositories/services
- ✅ Type-safe error handling dengan Either<Failure, T>
- ❌ UI logic (tempatkan di controller/cubit)
- ❌ Direct infrastructure access (use repository abstraction)

**Documentation**: See [Use Case Pattern README](../lib/src/foundation/domain/usecases/README.md) for complete guide

---

### 2. 📁 `infrastructure/`

**Purpose**: Implementasi services yang bergantung pada library/platform eksternal (3rd party).

#### `infrastructure/analytics/`
**Contains**: Firebase Crashlytics, PostHog telemetry

```dart
// Example: Analytics Service
abstract class TelemetryService {
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties);
}

class PostHogTelemetryServiceImpl implements TelemetryService {
  // Implementation using PostHog SDK
}
```

**When to use**:
- ✅ Integrate dengan analytics provider
- ✅ Crash reporting & error tracking
- ✅ User behavior tracking

#### `infrastructure/network/`
**Contains**: HTTP client implementation (Dio)

```dart
// Example: Network Service
abstract class NetworkService {
  Future<Response> get(String url);
  Future<Response> post(String url, dynamic data);
}

class DioNetworkServiceImpl implements NetworkService {
  // Implementation using Dio
}
```

**When to use**:
- ✅ HTTP request wrapper
- ✅ Custom interceptors
- ✅ Network configuration

#### `infrastructure/storage/`
**Contains**: Local storage implementation (Hive)

```dart
// Example: Storage Service
abstract class StorageService {
  Future<void> save<T>(String key, T value);
  Future<T?> get<T>(String key);
}

class HiveStorageServiceImpl implements StorageService {
  // Implementation using Hive
}
```

**When to use**:
- ✅ Persist data ke local storage
- ✅ Cache management
- ✅ Key-value storage

---

### 3. 📁 `application/`

**Purpose**: Application-level services yang mengkoordinasikan business logic dengan infrastructure.

#### `application/connection/`
**Contains**: Internet connectivity checker

```dart
// Example: Connection Service
abstract class ConnectionService {
  Stream<bool> get connectionStream;
  Future<bool> isConnected();
}
```

**When to use**:
- ✅ Check internet connectivity
- ✅ Listen to connection changes
- ✅ Handle offline scenarios

#### `application/file/`
**Contains**: File operations (picker, compressor)

```dart
// Example: File Service
abstract class FileService {
  Future<File?> pickImage();
  Future<File> compressImage(File file);
}
```

**When to use**:
- ✅ File picking from device
- ✅ Image compression
- ✅ File type validation

#### `application/location/`
**Contains**: GPS & location permissions

```dart
// Example: Location Service
abstract class LocationService {
  Future<LocationEntity> getCurrentLocation();
  Future<bool> requestPermission();
}
```

**When to use**:
- ✅ Get device location
- ✅ Handle location permissions
- ✅ Location-based features

---

### 4. 📁 `configuration/`

**Purpose**: Setup, initialization, dan configuration management.

#### `configuration/di/`
**Contains**: Dependency Injection setup (GetIt, Injectable)

```dart
// Example: DI Module
@module
abstract class BumaCoreModule {
  @singleton
  NetworkService get networkService => DioNetworkServiceImpl();
}
```

**When to use**:
- ✅ Register services ke DI container
- ✅ Define dependencies
- ✅ Module registration

#### `configuration/flavor/`
**Contains**: Environment configuration (Dev, Staging, Production)

```dart
// Example: Flavor Config
class FlavorConfig {
  final String baseUrl;
  final String apiKey;
  final Environment environment;
}
```

**When to use**:
- ✅ Different configuration per environment
- ✅ Feature flags
- ✅ Environment-specific settings

---

### 5. 📁 `constants/`

**Purpose**: Global constants yang digunakan di seluruh aplikasi.

```dart
// Example: API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.buma.com';
  static const Duration timeout = Duration(seconds: 30);
}
```

**When to use**:
- ✅ API endpoints
- ✅ Configuration values
- ✅ Magic numbers/strings yang reusable
- ❌ Feature-specific constants (taruh di feature module)

**Structure**:
```
constants/
├── api.cons.dart           → API endpoints
├── firebase.cons.dart      → Firebase config
├── endpoint.cons.dart      → Base URLs
├── file.cons.dart          → File size limits, extensions
└── general.cons.dart       → General constants
```

---

### 6. 📁 `errors/`

**Purpose**: Centralized error handling dan exception definitions.

#### `errors/exceptions/`
**Contains**: Custom exception classes

```dart
// Example: Custom Exception
class NetworkException extends BaseException {
  final int? statusCode;
  NetworkException(String message, {this.statusCode}) : super(message);
}
```

**When to use**:
- ✅ Custom exception types
- ✅ Platform-specific errors
- ✅ Business rule violations

#### `errors/failure.dart`
**Contains**: Failure classes untuk Either pattern

```dart
// Example: Failure
abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}
```

**When to use**:
- ✅ Use dengan Either<Failure, Success> pattern
- ✅ Represent error states di domain layer
- ✅ Type-safe error handling

---

### 7. 📁 `extensions/`

**Purpose**: Dart type extensions untuk menambahkan functionality ke existing types.

```dart
// Example: String Extension
extension StringExtension on String {
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  String get capitalizeFirst => 
    isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
```

**When to use**:
- ✅ Add methods to existing Dart types (String, List, DateTime, etc)
- ✅ Reusable transformations
- ✅ Syntactic sugar
- ❌ Business logic (gunakan use cases)

**Guidelines**:
- ✅ Pure functions (no side effects)
- ✅ Self-contained
- ✅ Named clearly: `{Type}.extension.dart`

---

### 8. 📁 `helpers/`

**Purpose**: Pure utility functions tanpa state.

```dart
// Example: Logger Helper
class LoggerHelper {
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    // Logging logic
  }
  
  static void logInfo(String message) {
    // Logging logic
  }
}
```

**When to use**:
- ✅ Static utility methods
- ✅ Formatting functions
- ✅ Parsing utilities
- ✅ Conversion functions
- ❌ Stateful logic (gunakan services)

**Guidelines**:
- ✅ Static methods only
- ✅ Pure functions (same input = same output)
- ✅ No dependencies on services
- ✅ Named clearly: `{purpose}.helper.dart`

---

## 🧭 Decision Guide

### Where should I put my code?

Use this flowchart to decide:

```
┌─────────────────────────────────────────┐
│  What are you creating?                 │
└──────────────┬──────────────────────────┘
               │
               ├─ Business entity/use case? ──────────→ foundation/domain/
               │
               ├─ API model/DTO? ─────────────────────→ foundation/data/
               │
               ├─ 3rd party integration? ─────────────→ infrastructure/
               │
               ├─ App-level service? ─────────────────→ application/
               │
               ├─ Constant/config? ───────────────────→ constants/ or configuration/
               │
               ├─ Exception/error? ───────────────────→ errors/
               │
               ├─ Type extension? ────────────────────→ extensions/
               │
               └─ Pure utility function? ─────────────→ helpers/
```

### Quick Reference Table

| Apa yang dibuat | Folder | Contoh |
|----------------|--------|---------|
| Business entity | `foundation/domain/entities/` | `UserEntity`, `ProductEntity` |
| Use case | `foundation/domain/usecases/` | `GetUserProfileUseCase` |
| API model | `foundation/data/models/` | `UserResponseModel` |
| Firebase service | `infrastructure/analytics/` | `CrashlyticsService` |
| HTTP client | `infrastructure/network/` | `DioNetworkService` |
| Local storage | `infrastructure/storage/` | `HiveStorageService` |
| File picker | `application/file/` | `FileService` |
| Location service | `application/location/` | `LocationService` |
| DI setup | `configuration/di/` | `BumaCoreModule` |
| Environment config | `configuration/flavor/` | `FlavorConfig` |
| API endpoint | `constants/` | `ApiConstants` |
| Custom exception | `errors/exceptions/` | `NetworkException` |
| String extension | `extensions/` | `StringExtension` |
| Logger utility | `helpers/` | `LoggerHelper` |

---

## 🎯 Best Practices

### General Guidelines

1. **One Responsibility Per File**
   - Each file should have one clear purpose
   - File name should match the main class/function

2. **Use Barrel Files**
   - Each folder should have a barrel file (`folder_name.dart`)
   - Export all public APIs through barrel files
   - Never import individual files from outside the folder

3. **Follow Naming Conventions**
   ```dart
   // Entities
   location.entity.dart  →  class LocationEntity
   
   // Models
   user.model.dart       →  class UserModel
   
   // Use Cases
   get_user.usecase.dart →  class GetUserUseCase
   
   // Services
   network.service.dart  →  abstract class NetworkService
   network.service.impl.dart  →  class NetworkServiceImpl
   
   // Extensions
   string.extension.dart →  extension StringExtension
   
   // Helpers
   logger.helper.dart    →  class LoggerHelper
   
   // Constants
   api.cons.dart         →  class ApiConstants
   ```

4. **Keep Dependencies Clear**
   ```
   foundation/domain/  →  No dependencies (pure business logic)
   foundation/data/    →  Can depend on domain
   application/        →  Can depend on domain & infrastructure
   infrastructure/     →  Can depend on domain (interfaces only)
   ```

### Code Organization

#### ✅ Good Example

```dart
// lib/src/foundation/domain/usecases/user/get_user_profile.usecase.dart
import 'package:buma_core/src/foundation/domain/entities/entities.dart';
import 'package:buma_core/src/foundation/domain/usecases/base.usecase.dart';

class GetUserProfileUseCase extends BaseUseCase<UserEntity, String> {
  final UserRepository _repository;
  
  GetUserProfileUseCase(this._repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}
```

#### ❌ Bad Example

```dart
// Don't mix concerns
class GetUserProfileUseCase {
  // ❌ Use case should not directly use Dio
  final Dio _dio;
  
  // ❌ Use case should not have UI logic
  void showUserProfile(BuildContext context) { }
  
  // ❌ Use case should not handle storage directly
  Future<void> cacheUser(User user) {
    await Hive.box('users').put(user.id, user);
  }
}
```

### Import Guidelines

```dart
// ✅ Good: Import from barrel files
import 'package:buma_core/src/foundation/domain/entities/entities.dart';
import 'package:buma_core/src/infrastructure/network/network.dart';

// ❌ Bad: Import individual files
import 'package:buma_core/src/foundation/domain/entities/user/user.entity.dart';
import 'package:buma_core/src/infrastructure/network/impl/dio_network_service.impl.dart';

// ✅ Good: Group imports
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:dartz/dartz.dart';

// 4. Project imports
import 'package:buma_core/buma_core.dart';
```

### Documentation

```dart
/// Service for handling file operations including picking and compression.
///
/// This service provides cross-platform file picking and image compression
/// capabilities. It handles permission requests automatically.
///
/// Example:
/// ```dart
/// final file = await fileService.pickImage();
/// final compressed = await fileService.compressImage(file);
/// ```
abstract class FileService {
  /// Picks an image from the device gallery.
  ///
  /// Returns `null` if user cancels the operation.
  /// Throws [PermissionException] if permission is denied.
  Future<File?> pickImage();
  
  /// Compresses the given [file] to reduce file size.
  ///
  /// The compression quality can be controlled via [quality] parameter (0-100).
  /// Returns the compressed file.
  Future<File> compressImage(File file, {int quality = 85});
}
```

---

## ❓ FAQs

### Q: Kenapa tidak pakai folder `core/` di dalam `buma_core`?
**A:** Karena redundant. Package `buma_core` sudah menunjukkan bahwa semua isinya adalah "core". Menambahkan folder `core/` lagi akan membuat path seperti `buma_core/src/core/...` yang berlebihan.

### Q: Kenapa `shared/` diganti dengan `extensions/` dan `helpers/`?
**A:** 
1. Menghindari redundancy dengan project name "Shared" dan feature modules "shared_*"
2. Lebih deskriptif - langsung tahu isinya apa
3. Import path lebih pendek dan jelas

### Q: Kapan pakai `helpers/` vs `extensions/`?
**A:**
- **Extensions**: Menambahkan method ke existing type (String, List, dll)
- **Helpers**: Static utility functions yang standalone

### Q: Perbedaan `infrastructure/` vs `application/`?
**A:**
- **Infrastructure**: Services yang directly wrap 3rd party libraries (Firebase, Dio, Hive)
- **Application**: App-level services yang mungkin menggunakan infrastructure services

### Q: Bolehkah `domain/` depend on `infrastructure/`?
**A:** Tidak! Domain layer harus pure dan tidak boleh depend on infrastructure. Gunakan interfaces/abstract classes di domain, implementasinya di infrastructure.

### Q: Bagaimana handle service yang butuh dependency injection?
**A:** Define interface di `application/` atau `infrastructure/`, register implementation di `configuration/di/`.

### Q: Constants per-feature ditaruh dimana?
**A:** Jika constant hanya dipakai dalam satu feature, taruh di feature module tersebut, bukan di `buma_core/constants/`.

### Q: Bagaimana dengan test files?
**A:** Mirror structure di `test/` folder:
```
test/
├── foundation/
├── infrastructure/
├── application/
└── ...
```

---

## 📚 Additional Resources

### Related Documentation
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/tags/domain%20driven%20design.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

### Internal Documentation
- `README.md` - Package overview
- `CHANGELOG.md` - Version history
- `pubspec.yaml` - Dependencies

---

**Maintained by**: BUMA Engineering Team  
**Questions?**: Contact architecture team or create an issue


