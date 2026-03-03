# Use Case Pattern - BUMA Core

Dokumentasi lengkap tentang implementasi Use Case pattern di BUMA Core library.

## 📚 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Base Classes](#base-classes)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Testing](#testing)

---

## Overview

Use Case adalah abstraksi yang meng-encapsulate single business logic operation. Setiap use case merepresentasikan satu action atau operasi dalam aplikasi.

### Benefits

✅ **Single Responsibility** - Setiap use case melakukan satu hal saja  
✅ **Testable** - Mudah di-test dengan mock dependencies  
✅ **Reusable** - Dapat digunakan kembali di berbagai bagian aplikasi  
✅ **Type Safe** - Explicit error handling dengan `Either<Failure, T>`  
✅ **Maintainable** - Business logic terisolasi dan mudah di-maintain  

---

## Architecture

Use Cases berada di **Domain Layer** (Clean Architecture):

```
lib/src/foundation/domain/
├── entities/           # Domain entities
├── usecases/          # Use case abstractions
│   ├── usecase.dart   # Base classes (UseCaseAsync, UseCase, NoParams)
│   └── usecases.dart  # Barrel file
└── typedef/           # Type definitions (ValueGuard, Result)
```

**Dependency Flow:**
```
UI/Presentation Layer
        ↓
    Use Cases (Domain Layer)
        ↓
   Repositories (Domain Interface)
        ↓
  Data Sources (Infrastructure)
```

---

## Base Classes

### 1. `UseCaseAsync<T, Params>`

Untuk operasi **asynchronous** (network calls, database, file I/O).

```dart
abstract class UseCaseAsync<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
```

**Type Parameters:**
- `T` - Return type on success
- `Params` - Input parameter type

**Example:**
```dart
class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}
```

### 2. `UseCase<T, Params>`

Untuk operasi **synchronous** (validation, computation, transformation).

```dart
abstract class UseCase<T, Params> {
  Either<Failure, T> call(Params params);
}
```

**Example:**
```dart
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
```

### 3. `NoParams`

Parameter class untuk use case yang tidak memerlukan input.

```dart
class NoParams {
  const NoParams();
}
```

**Example:**
```dart
class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}
```

---

## Usage Examples

### Example 1: Async Use Case with Parameters

```dart
// 1. Define parameters
class GetUserParams {
  final String userId;
  const GetUserParams(this.userId);
}

// 2. Define use case
class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}

// 3. Register in DI
getIt.registerLazySingleton(
  () => GetUserUseCase(getIt<UserRepository>()),
);

// 4. Use in UI/Presentation
final useCase = getIt<GetUserUseCase>();
final result = await useCase(GetUserParams('123'));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('User: ${user.name}'),
);
```

### Example 2: Async Use Case without Parameters

```dart
// 1. Define use case
class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}

// 2. Use in UI
final result = await getCurrentUserUseCase(const NoParams());
```

### Example 3: Sync Use Case

```dart
// 1. Define parameters
class ValidateEmailParams {
  final String email;
  const ValidateEmailParams(this.email);
}

// 2. Define use case
class ValidateEmailUseCase implements UseCase<bool, ValidateEmailParams> {
  @override
  Either<Failure, bool> call(ValidateEmailParams params) {
    if (params.email.isEmpty) {
      return Left(ValidationFailure('Email cannot be empty'));
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(params.email)) {
      return Left(ValidationFailure('Invalid email format'));
    }
    
    return const Right(true);
  }
}

// 3. Use in UI
final result = validateEmailUseCase(ValidateEmailParams(email));
result.fold(
  (failure) => showError(failure.message),
  (isValid) => proceedWithLogin(),
);
```

### Example 4: Complex Business Logic

```dart
class CalculateDiscountParams {
  final double originalPrice;
  final double discountPercentage;
  final bool isMember;
  
  const CalculateDiscountParams({
    required this.originalPrice,
    required this.discountPercentage,
    this.isMember = false,
  });
}

class CalculateDiscountUseCase 
    implements UseCase<double, CalculateDiscountParams> {
  
  @override
  Either<Failure, double> call(CalculateDiscountParams params) {
    // Validation
    if (params.originalPrice < 0) {
      return Left(ValidationFailure('Price cannot be negative'));
    }
    
    if (params.discountPercentage < 0 || params.discountPercentage > 100) {
      return Left(ValidationFailure('Invalid discount percentage'));
    }
    
    // Business logic
    var discount = params.discountPercentage;
    
    // Member gets extra 5% discount
    if (params.isMember) {
      discount += 5;
      discount = discount.clamp(0, 100);
    }
    
    final discountAmount = params.originalPrice * (discount / 100);
    final finalPrice = params.originalPrice - discountAmount;
    
    return Right(finalPrice);
  }
}
```

---

## Best Practices

### ✅ DO's

1. **Single Responsibility**
   ```dart
   // ✅ GOOD - One responsibility
   class GetUserUseCase implements UseCaseAsync<User, GetUserParams> { }
   
   // ❌ BAD - Multiple responsibilities
   class GetUserAndPostsUseCase { } // Should be split
   ```

2. **Dependency Injection**
   ```dart
   // ✅ GOOD - Dependencies injected via constructor
   class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
     final UserRepository repository;
     GetUserUseCase(this.repository);
   }
   
   // ❌ BAD - Direct instantiation
   class GetUserUseCase {
     final repository = UserRepositoryImpl();
   }
   ```

3. **Return Either<Failure, T>**
   ```dart
   // ✅ GOOD - Explicit error handling
   Future<Either<Failure, User>> call(GetUserParams params);
   
   // ❌ BAD - Throwing exceptions
   Future<User> call(GetUserParams params) {
     throw Exception('Error');
   }
   ```

4. **Immutable Parameters**
   ```dart
   // ✅ GOOD - Immutable parameters
   class GetUserParams {
     final String userId;
     const GetUserParams(this.userId);
   }
   
   // ❌ BAD - Mutable parameters
   class GetUserParams {
     String userId;
     GetUserParams(this.userId);
   }
   ```

5. **Clear Naming**
   ```dart
   // ✅ GOOD - Clear and descriptive
   class GetUserByIdUseCase { }
   class ValidateEmailUseCase { }
   class CalculateDiscountUseCase { }
   
   // ❌ BAD - Unclear naming
   class UserUseCase { }
   class DoSomething { }
   ```

### ❌ DON'Ts

1. **Don't put UI logic in use cases**
   ```dart
   // ❌ BAD - UI concern in use case
   class GetUserUseCase {
     Future<Either<Failure, User>> call(GetUserParams params) async {
       final result = await repository.getUser(params.userId);
       showDialog('Success!'); // UI logic!
       return result;
     }
   }
   ```

2. **Don't access infrastructure directly**
   ```dart
   // ❌ BAD - Direct infrastructure access
   class GetUserUseCase {
     Future<Either<Failure, User>> call(GetUserParams params) async {
       final dio = Dio(); // Direct Dio usage!
       final response = await dio.get('/users/${params.userId}');
       return Right(User.fromJson(response.data));
     }
   }
   
   // ✅ GOOD - Use repository abstraction
   class GetUserUseCase {
     final UserRepository repository;
     
     Future<Either<Failure, User>> call(GetUserParams params) async {
       return repository.getUser(params.userId);
     }
   }
   ```

3. **Don't chain multiple use cases**
   ```dart
   // ❌ BAD - Chaining use cases
   class GetUserProfileUseCase {
     final GetUserUseCase getUserUseCase;
     final GetPostsUseCase getPostsUseCase;
     
     Future<Either<Failure, Profile>> call(params) async {
       final user = await getUserUseCase(params);
       final posts = await getPostsUseCase(params);
       // ...
     }
   }
   
   // ✅ GOOD - Let presentation layer orchestrate
   // In BLoC/Controller:
   final userResult = await getUserUseCase(params);
   final postsResult = await getPostsUseCase(params);
   ```

---

## Testing

### Unit Testing Use Cases

```dart
void main() {
  late GetUserUseCase useCase;
  late MockUserRepository mockRepository;
  
  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserUseCase(mockRepository);
  });
  
  group('GetUserUseCase', () {
    test('should return User when repository returns success', () async {
      // Arrange
      final user = User(id: '123', name: 'John');
      when(() => mockRepository.getUser('123'))
          .thenAnswer((_) async => Right(user));
      
      // Act
      final result = await useCase(GetUserParams('123'));
      
      // Assert
      expect(result, Right(user));
      verify(() => mockRepository.getUser('123')).called(1);
    });
    
    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = NetworkFailure('Connection error');
      when(() => mockRepository.getUser('123'))
          .thenAnswer((_) async => Left(failure));
      
      // Act
      final result = await useCase(GetUserParams('123'));
      
      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getUser('123')).called(1);
    });
  });
}
```

### Testing Synchronous Use Cases

```dart
void main() {
  late ValidateEmailUseCase useCase;
  
  setUp(() {
    useCase = ValidateEmailUseCase();
  });
  
  group('ValidateEmailUseCase', () {
    test('should return true for valid email', () {
      // Act
      final result = useCase(ValidateEmailParams('user@example.com'));
      
      // Assert
      expect(result, const Right(true));
    });
    
    test('should return Failure for invalid email', () {
      // Act
      final result = useCase(ValidateEmailParams('invalid-email'));
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Invalid')),
        (_) => fail('Should return failure'),
      );
    });
    
    test('should return Failure for empty email', () {
      // Act
      final result = useCase(ValidateEmailParams(''));
      
      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

---

## Complete Example

Lihat file lengkap di: [`example/usecases/usecase_example.dart`](../../example/usecases/usecase_example.dart)

---

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BUMA Core Architecture](../../../ARCHITECTURE.md)
- [ValueGuard Documentation](../typedef/value_guard.typedef.dart)
- [Failure Classes](../../../errors/failures.dart)

---

**Last Updated:** March 3, 2026  
**Version:** 1.0.0
