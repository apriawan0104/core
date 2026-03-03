# Use Case Quick Start Guide

Panduan cepat untuk mulai menggunakan Use Case pattern di BUMA Core.

## 🚀 Quick Start (5 minutes)

### Step 1: Import Use Case Abstractions

```dart
import 'package:app_core/app_core.dart';
```

### Step 2: Create Your Use Case

#### Option A: Async Use Case (Network/Database/File I/O)

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
```

#### Option B: Sync Use Case (Validation/Computation)

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(params.email)) {
      return Left(ValidationFailure('Invalid email format'));
    }
    
    return const Right(true);
  }
}
```

#### Option C: Use Case without Parameters

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

### Step 3: Register in DI Container

```dart
// In your DI setup file
void setupUseCases() {
  // Register use case
  getIt.registerLazySingleton(
    () => GetUserUseCase(getIt<UserRepository>()),
  );
  
  getIt.registerLazySingleton(() => ValidateEmailUseCase());
  
  getIt.registerLazySingleton(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
}
```

### Step 4: Use in Your App

#### In BLoC/Cubit

```dart
class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;
  
  UserCubit(this.getUserUseCase) : super(UserInitial());
  
  Future<void> loadUser(String userId) async {
    emit(UserLoading());
    
    final result = await getUserUseCase(GetUserParams(userId));
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }
}
```

#### In Controller (GetX)

```dart
class UserController extends GetxController {
  final GetUserUseCase getUserUseCase;
  
  UserController(this.getUserUseCase);
  
  final user = Rxn<User>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  Future<void> loadUser(String userId) async {
    isLoading.value = true;
    
    final result = await getUserUseCase(GetUserParams(userId));
    
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (loadedUser) => user.value = loadedUser,
    );
    
    isLoading.value = false;
  }
}
```

#### In ViewModel/Notifier

```dart
class UserViewModel extends ChangeNotifier {
  final GetUserUseCase getUserUseCase;
  
  UserViewModel(this.getUserUseCase);
  
  User? _user;
  User? get user => _user;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await getUserUseCase(GetUserParams(userId));
    
    result.fold(
      (failure) => _errorMessage = failure.message,
      (loadedUser) => _user = loadedUser,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 📝 Common Patterns

### Pattern 1: Multiple Parameters

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
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Validation
    if (params.email.isEmpty || params.password.isEmpty) {
      return Left(ValidationFailure('Email and password are required'));
    }
    
    // Business logic
    return repository.login(
      params.email,
      params.password,
      params.rememberMe,
    );
  }
}
```

### Pattern 2: Chaining with fold()

```dart
Future<void> loginAndLoadProfile() async {
  final loginResult = await loginUseCase(loginParams);
  
  await loginResult.fold(
    (failure) async {
      emit(AuthError(failure.message));
    },
    (user) async {
      // Chain to next use case
      final profileResult = await getProfileUseCase(NoParams());
      
      profileResult.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) => emit(AuthSuccess(user, profile)),
      );
    },
  );
}
```

### Pattern 3: Combining Multiple Use Cases

```dart
Future<void> loadDashboardData() async {
  emit(DashboardLoading());
  
  // Execute multiple use cases in parallel
  final results = await Future.wait([
    getUserUseCase(NoParams()),
    getStatsUseCase(NoParams()),
    getNotificationsUseCase(NoParams()),
  ]);
  
  final userResult = results[0] as Either<Failure, User>;
  final statsResult = results[1] as Either<Failure, Stats>;
  final notificationsResult = results[2] as Either<Failure, List<Notification>>;
  
  // Check if any failed
  if (userResult.isLeft() || statsResult.isLeft() || notificationsResult.isLeft()) {
    emit(DashboardError('Failed to load dashboard data'));
    return;
  }
  
  // All succeeded
  final user = userResult.getOrElse(() => throw Exception());
  final stats = statsResult.getOrElse(() => throw Exception());
  final notifications = notificationsResult.getOrElse(() => throw Exception());
  
  emit(DashboardLoaded(user, stats, notifications));
}
```

---

## 🎯 Best Practices Checklist

Before implementing a use case, check these:

- [ ] ✅ Use case has single responsibility
- [ ] ✅ Dependencies injected via constructor
- [ ] ✅ Returns `Either<Failure, T>` for explicit error handling
- [ ] ✅ Parameters are immutable (use `final` and `const`)
- [ ] ✅ No UI logic in use case
- [ ] ✅ No direct infrastructure access (use repository)
- [ ] ✅ Clear, descriptive naming (e.g., `GetUserByIdUseCase`)
- [ ] ✅ Registered in DI container
- [ ] ✅ Unit tested with mock dependencies

---

## 📚 Next Steps

1. **Read Full Documentation**: [README.md](./README.md)
2. **See Complete Examples**: [example/usecases/usecase_example.dart](../../../example/usecases/usecase_example.dart)
3. **Understand Architecture**: [ARCHITECTURE.md](../../../../ARCHITECTURE.md)
4. **Learn Error Handling**: [ValueGuard Documentation](../typedef/value_guard.typedef.dart)

---

## 💡 Pro Tips

1. **Keep it Simple**: Don't over-engineer. A use case should be straightforward.
2. **Test First**: Write tests before implementation (TDD).
3. **Reuse**: If similar logic exists, extract common parts.
4. **Document**: Add dartdoc comments for complex business rules.
5. **Type Safety**: Use strong typing for parameters and return values.

---

**Happy Coding! 🚀**
