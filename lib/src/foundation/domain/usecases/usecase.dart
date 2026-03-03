// ignore_for_file: one_member_abstracts

import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';

/// Abstract base class for an asynchronous use case.
///
/// A use case represents a single action or operation in the application.
/// Each use case typically performs a specific task or retrieves data from
/// a repository. It helps to encapsulate the business logic of the application
/// in a reusable and testable manner.
///
/// Use [UseCaseAsync] when the operation is asynchronous (e.g., network calls,
/// database operations, file I/O).
///
/// ## Type Parameters
///
/// - `T`: The type of result returned by the use case on success
/// - `Params`: The type of input parameters accepted by the use case
///
/// ## Usage Example
///
/// ```dart
/// // Define parameters
/// class GetUserParams {
///   final String userId;
///   const GetUserParams(this.userId);
/// }
///
/// // Define use case
/// class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
///   final UserRepository repository;
///
///   GetUserUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(GetUserParams params) async {
///     return repository.getUser(params.userId);
///   }
/// }
///
/// // Use in consumer code
/// final useCase = GetUserUseCase(userRepository);
/// final result = await useCase(GetUserParams('123'));
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Success: ${user.name}'),
/// );
/// ```
///
/// ## Best Practices
///
/// 1. **Single Responsibility**: Each use case should do one thing only
/// 2. **Dependency Injection**: Inject repositories via constructor
/// 3. **Error Handling**: Always return Either<Failure, T> for explicit error handling
/// 4. **Testability**: Easy to test by mocking repository dependencies
/// 5. **Reusability**: Can be reused across different parts of the application
///
/// ## See Also
///
/// - [UseCase] for synchronous operations
/// - [NoParams] for use cases that don't require parameters
abstract class UseCaseAsync<T, Params> {
  /// Executes the use case with the given input parameters.
  ///
  /// Returns a [Future] that resolves to an [Either] containing either
  /// a [Failure] if an error occurs or the result [T] of the use case operation.
  ///
  /// The method is called directly on the use case instance:
  /// ```dart
  /// final result = await myUseCase(params);
  /// ```
  Future<Either<Failure, T>> call(Params params);
}

/// Abstract base class for a synchronous use case.
///
/// A use case represents a single action or operation in the application.
/// Each use case typically performs a specific task or retrieves data from
/// a repository. It helps to encapsulate the business logic of the application
/// in a reusable and testable manner.
///
/// Use [UseCase] when the operation is synchronous (e.g., data transformation,
/// validation, computation).
///
/// ## Type Parameters
///
/// - `T`: The type of result returned by the use case on success
/// - `Params`: The type of input parameters accepted by the use case
///
/// ## Usage Example
///
/// ```dart
/// // Define parameters
/// class ValidateEmailParams {
///   final String email;
///   const ValidateEmailParams(this.email);
/// }
///
/// // Define use case
/// class ValidateEmailUseCase implements UseCase<bool, ValidateEmailParams> {
///   @override
///   Either<Failure, bool> call(ValidateEmailParams params) {
///     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
///     
///     if (emailRegex.hasMatch(params.email)) {
///       return Right(true);
///     } else {
///       return Left(ValidationFailure('Invalid email format'));
///     }
///   }
/// }
///
/// // Use in consumer code
/// final useCase = ValidateEmailUseCase();
/// final result = useCase(ValidateEmailParams('user@example.com'));
///
/// result.fold(
///   (failure) => print('Invalid: ${failure.message}'),
///   (isValid) => print('Valid: $isValid'),
/// );
/// ```
///
/// ## When to Use
///
/// - Data transformation or computation
/// - Validation logic
/// - Business rules that don't require I/O
/// - Operations that complete immediately
///
/// ## Best Practices
///
/// 1. **Single Responsibility**: Each use case should do one thing only
/// 2. **Pure Functions**: Prefer pure functions without side effects
/// 3. **Error Handling**: Always return Either<Failure, T> for explicit error handling
/// 4. **Testability**: Easy to test with no async complexity
/// 5. **Composability**: Can be composed with other use cases
///
/// ## See Also
///
/// - [UseCaseAsync] for asynchronous operations
/// - [NoParams] for use cases that don't require parameters
abstract class UseCase<T, Params> {
  /// Executes the use case with the given input parameters.
  ///
  /// Returns an [Either] containing either a [Failure] if an error occurs
  /// or the result [T] of the use case operation.
  ///
  /// The method is called directly on the use case instance:
  /// ```dart
  /// final result = myUseCase(params);
  /// ```
  Either<Failure, T> call(Params params);
}

/// A special parameter class to indicate that a use case requires no parameters.
///
/// Use this when your use case doesn't need any input parameters instead of
/// using `void` or nullable types.
///
/// ## Usage Example
///
/// ```dart
/// // Use case that doesn't need parameters
/// class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
///   final AuthRepository repository;
///
///   GetCurrentUserUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(NoParams params) async {
///     return repository.getCurrentUser();
///   }
/// }
///
/// // Use in consumer code
/// final useCase = GetCurrentUserUseCase(authRepository);
/// final result = await useCase(NoParams());
/// ```
class NoParams {
  /// Creates a [NoParams] instance.
  const NoParams();
}
