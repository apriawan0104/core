# Migration Guide: Legacy to New Use Case Pattern

Panduan untuk migrate dari pattern use case lama ke pattern baru yang menggunakan `UseCaseAsync` dan `UseCase`.

## 📋 Overview

### Old Pattern (❌ Deprecated)

```dart
// Old pattern might look like:
abstract class BaseUseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

// Or even:
class GetUserUseCase {
  Future<User?> execute(String userId) async {
    try {
      return await repository.getUser(userId);
    } catch (e) {
      return null; // ❌ Lost error information
    }
  }
}
```

### New Pattern (✅ Recommended)

```dart
// Clear separation between async and sync
abstract class UseCaseAsync<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class UseCase<T, Params> {
  Either<Failure, T> call(Params params);
}
```

---

## 🔄 Migration Steps

### Step 1: Identify Use Case Type

Tentukan apakah use case Anda asynchronous atau synchronous.

#### Async Use Cases (network, database, file I/O)
- API calls
- Database queries
- File operations
- Any I/O operations

#### Sync Use Cases (computation, validation)
- Data validation
- Business calculations
- Data transformation
- Pure functions

### Step 2: Update Base Class

#### Before (Old Pattern)

```dart
class GetUserUseCase extends BaseUseCase<User, String> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(String userId) async {
    return repository.getUser(userId);
  }
}
```

#### After (New Pattern)

```dart
// 1. Create parameter class (if needed)
class GetUserParams {
  final String userId;
  const GetUserParams(this.userId);
}

// 2. Implement UseCaseAsync
class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}
```

### Step 3: Update Parameter Passing

#### Simple Single Parameter

**Before:**
```dart
class GetUserUseCase extends BaseUseCase<User, String> {
  @override
  Future<Either<Failure, User>> call(String userId) async {
    // ...
  }
}

// Usage
final result = await useCase.call('123');
```

**After:**
```dart
class GetUserParams {
  final String userId;
  const GetUserParams(this.userId);
}

class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    // ...
  }
}

// Usage
final result = await useCase(GetUserParams('123'));
```

#### Multiple Parameters

**Before:**
```dart
class LoginUseCase extends BaseUseCase<User, Map<String, dynamic>> {
  @override
  Future<Either<Failure, User>> call(Map<String, dynamic> params) async {
    final email = params['email'] as String;
    final password = params['password'] as String;
    // ... ❌ Not type-safe!
  }
}
```

**After:**
```dart
class LoginParams {
  final String email;
  final String password;
  final bool rememberMe;
  
  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class LoginUseCase implements UseCaseAsync<User, LoginParams> {
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // ... ✅ Type-safe!
  }
}
```

#### No Parameters

**Before:**
```dart
class GetCurrentUserUseCase extends BaseUseCase<User, void> {
  @override
  Future<Either<Failure, User>> call(void params) async {
    // ...
  }
}

// Usage
final result = await useCase.call(null); // ❌ Awkward
```

**After:**
```dart
class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    // ...
  }
}

// Usage
final result = await useCase(const NoParams()); // ✅ Clear
```

### Step 4: Update DI Registration

**Before:**
```dart
getIt.registerFactory<GetUserUseCase>(
  () => GetUserUseCase(getIt()),
);
```

**After (Same):**
```dart
// No changes needed in DI registration!
getIt.registerFactory<GetUserUseCase>(
  () => GetUserUseCase(getIt()),
);
```

### Step 5: Update Usage in Presentation Layer

**Before:**
```dart
// In BLoC/Cubit
final result = await getUserUseCase.call('123');
```

**After:**
```dart
// In BLoC/Cubit
final result = await getUserUseCase(GetUserParams('123'));
```

---

## 🔍 Common Migration Scenarios

### Scenario 1: Exception-Based to Either-Based

**Before:**
```dart
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<User?> execute(String userId) async {
    try {
      return await repository.getUser(userId);
    } catch (e) {
      print('Error: $e');
      return null; // ❌ Lost error information
    }
  }
}

// Usage
final user = await useCase.execute('123');
if (user != null) {
  // Success
} else {
  // Error, but we don't know why!
}
```

**After:**
```dart
class GetUserParams {
  final String userId;
  const GetUserParams(this.userId);
}

class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}

// Usage
final result = await useCase(GetUserParams('123'));
result.fold(
  (failure) => print('Error: ${failure.message}'), // ✅ Know exactly what failed
  (user) => print('Success: ${user.name}'),
);
```

### Scenario 2: Callback-Based to Either-Based

**Before:**
```dart
class GetUserUseCase {
  Future<void> execute(
    String userId, {
    required Function(User) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final user = await repository.getUser(userId);
      onSuccess(user);
    } catch (e) {
      onError(e.toString());
    }
  }
}

// Usage - ❌ Callback hell
await useCase.execute(
  '123',
  onSuccess: (user) {
    // Handle success
  },
  onError: (error) {
    // Handle error
  },
);
```

**After:**
```dart
class GetUserParams {
  final String userId;
  const GetUserParams(this.userId);
}

class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}

// Usage - ✅ Clean and composable
final result = await useCase(GetUserParams('123'));
result.fold(
  (failure) => handleError(failure),
  (user) => handleSuccess(user),
);
```

### Scenario 3: Synchronous Validation

**Before:**
```dart
class ValidateEmailUseCase {
  bool execute(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

// Usage - ❌ No error details
if (useCase.execute(email)) {
  // Valid
} else {
  // Invalid, but why?
}
```

**After:**
```dart
class ValidateEmailParams {
  final String email;
  const ValidateEmailParams(this.email);
}

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

// Usage - ✅ Clear error information
final result = useCase(ValidateEmailParams(email));
result.fold(
  (failure) => showError(failure.message), // Know exactly what's wrong
  (_) => proceedWithLogin(),
);
```

---

## ✅ Migration Checklist

Use this checklist for each use case you migrate:

### Planning
- [ ] Identify if use case is async or sync
- [ ] List all input parameters
- [ ] Check if parameters need to be grouped into a class
- [ ] Identify error cases and failure types

### Implementation
- [ ] Create parameter class (if needed)
- [ ] Implement correct interface (`UseCaseAsync` or `UseCase`)
- [ ] Replace return type with `Either<Failure, T>` or `Future<Either<Failure, T>>`
- [ ] Update error handling to return `Left(Failure)`
- [ ] Update success cases to return `Right(value)`

### Integration
- [ ] Update DI registration (if needed)
- [ ] Update usage in presentation layer
- [ ] Update tests to use new pattern
- [ ] Verify all call sites are updated

### Testing
- [ ] Test success cases
- [ ] Test failure cases
- [ ] Test parameter validation
- [ ] Test integration with repository

---

## 🧪 Testing Migration

### Before (Old Tests)

```dart
test('should return user when repository returns user', () async {
  // Arrange
  final user = User(id: '123', name: 'John');
  when(() => mockRepository.getUser('123'))
      .thenAnswer((_) async => user);
  
  // Act
  final result = await useCase.execute('123');
  
  // Assert
  expect(result, user);
});
```

### After (New Tests)

```dart
test('should return Right(User) when repository succeeds', () async {
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

test('should return Left(Failure) when repository fails', () async {
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
```

---

## 🎯 Benefits After Migration

✅ **Type Safety**: Parameters are strongly typed  
✅ **Error Handling**: Explicit error handling with Either  
✅ **Testability**: Easy to test with clear success/failure cases  
✅ **Maintainability**: Clear separation between async and sync operations  
✅ **Consistency**: All use cases follow same pattern  
✅ **Documentation**: Self-documenting code with clear interfaces  

---

## 📚 Additional Resources

- [Use Case Pattern README](./README.md) - Complete documentation
- [Quick Start Guide](./QUICK_START.md) - Get started quickly
- [Examples](../../../example/usecases/usecase_example.dart) - Working examples
- [Architecture Guide](../../../../ARCHITECTURE.md) - Project architecture

---

## 💬 Need Help?

If you encounter issues during migration:

1. Check the [README](./README.md) for detailed explanations
2. Review [examples](../../../example/usecases/usecase_example.dart)
3. Refer to existing implementations in the codebase
4. Consult with the team

---

**Happy Migrating! 🚀**
