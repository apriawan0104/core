import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';

/// ValueGuard - Type-safe wrapper for operations that can fail
///
/// [ValueGuard] is a type alias for [Either<Failure, T>] that represents
/// a value that is "guarded" against failures. Every operation that can fail
/// should return a [ValueGuard] instead of throwing exceptions or returning null.
///
/// This abstraction provides:
/// - **Dependency Independence**: Abstracts the underlying Either implementation
/// - **Type Safety**: Forces explicit handling of success and failure cases
/// - **Consistency**: Unified error handling pattern across all apps
/// - **Future-proof**: Can switch from dartz to fpdart without breaking consumer code
///
/// ## Why ValueGuard?
///
/// The name "ValueGuard" emphasizes that:
/// - The value is **protected** from unhandled errors
/// - Consumers **must explicitly handle** both success and failure cases
/// - No surprises from exceptions or null values
///
/// ## Generic Parameter
///
/// - `T`: The type of the successful value
///
/// ## Usage Examples
///
/// ### Basic Usage
///
/// ```dart
/// // Service interface
/// abstract class UserService {
///   Future<ValueGuard<User>> getUser(String id);
///   Future<ValueGuard<void>> deleteUser(String id);
/// }
///
/// // Implementation
/// class UserServiceImpl implements UserService {
///   @override
///   Future<ValueGuard<User>> getUser(String id) async {
///     return ValueGuards.tryCatchAsync(
///       () async {
///         final response = await api.get('/users/$id');
///         return User.fromJson(response.data);
///       },
///       (error, stack) => NetworkFailure(error.toString()),
///     );
///   }
/// }
/// ```
///
/// ### Handling Results
///
/// ```dart
/// // Using fold (recommended)
/// final result = await userService.getUser('123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => displayUser(user),
/// );
///
/// // Using extensions
/// if (result.isSuccess) {
///   final user = result.valueOrNull!;
///   print('Welcome ${user.name}');
/// }
///
/// // Get value with default
/// final user = result.getOrElse(User.guest());
/// ```
///
/// ### Creating ValueGuards
///
/// ```dart
/// // Success
/// ValueGuard<String> success = ValueGuards.success('Hello');
/// // or
/// ValueGuard<String> success = Right('Hello');
///
/// // Failure
/// ValueGuard<String> failure = ValueGuards.failure(
///   NetworkFailure('Connection timeout'),
/// );
/// // or
/// ValueGuard<String> failure = Left(NetworkFailure('Connection timeout'));
///
/// // From nullable value
/// ValueGuard<User> result = ValueGuards.fromNullable(
///   user,
///   () => NotFoundFailure('User not found'),
/// );
///
/// // Try-catch wrapper
/// ValueGuard<String> result = ValueGuards.tryCatch(
///   () => jsonDecode(jsonString),
///   (error, stack) => ParseFailure(error.toString()),
/// );
/// ```
///
/// ### Transformation
///
/// ```dart
/// // Map successful value
/// ValueGuard<int> length = nameResult.mapValue((name) => name.length);
///
/// // Map failure
/// ValueGuard<User> customError = userResult.mapFailure(
///   (failure) => CustomFailure(failure.message),
/// );
///
/// // Chain operations
/// ValueGuard<Profile> profile = await userResult.flatMapAsync(
///   (user) => profileService.getProfile(user.id),
/// );
/// ```
///
/// ## Best Practices
///
/// ### ✅ DO
///
/// ```dart
/// // Use ValueGuard for all fallible operations
/// Future<ValueGuard<Data>> fetchData();
///
/// // Handle both cases explicitly
/// result.fold(
///   (failure) => handleError(failure),
///   (data) => handleSuccess(data),
/// );
///
/// // Use helper methods for common patterns
/// final result = ValueGuards.tryCatchAsync(...);
/// ```
///
/// ### ❌ DON'T
///
/// ```dart
/// // Don't throw exceptions in services
/// Future<User> getUser() async {
///   throw Exception('Error'); // BAD!
/// }
///
/// // Don't return null for errors
/// Future<User?> getUser(); // BAD!
///
/// // Don't ignore failures
/// final user = result.valueOrNull; // BAD! (unless you have good reason)
/// ```
///
/// ## Migration from Either<Failure, T>
///
/// If your code currently uses `Either<Failure, T>`, you can easily migrate:
///
/// ```dart
/// // Before
/// Future<Either<Failure, User>> getUser(String id);
///
/// // After (just change the type)
/// Future<ValueGuard<User>> getUser(String id);
///
/// // Implementation code stays the same!
/// ```
///
/// ## Dependency Independence
///
/// This typedef abstracts the underlying Either implementation. If we need to
/// switch from dartz to fpdart or a custom implementation, only this typedef
/// needs to change - all consumer code remains unchanged.
///
/// See also:
/// - [Failure] - Base failure class
/// - [ValueGuards] - Helper methods for creating ValueGuards
/// - [ValueGuardExtension] - Extension methods for convenience
typedef ValueGuard<T> = Either<Failure, T>;

/// Extension methods for convenient [ValueGuard] handling
///
/// Provides utility methods to work with [ValueGuard] more easily.
extension ValueGuardExtension<T> on ValueGuard<T> {
  /// Returns true if this is a successful result
  ///
  /// Example:
  /// ```dart
  /// final result = await getUser();
  /// if (result.isSuccess) {
  ///   print('Got user successfully');
  /// }
  /// ```
  bool get isSuccess => isRight();

  /// Returns true if this is a failed result
  ///
  /// Example:
  /// ```dart
  /// final result = await getUser();
  /// if (result.isFailure) {
  ///   print('Failed to get user');
  /// }
  /// ```
  bool get isFailure => isLeft();

  /// Gets the value if successful, otherwise returns null
  ///
  /// **Warning**: Only use this if you have a valid reason to ignore the failure.
  /// Prefer using `fold()` or `getOrElse()` instead.
  ///
  /// Example:
  /// ```dart
  /// final user = result.valueOrNull;
  /// if (user != null) {
  ///   print(user.name);
  /// }
  /// ```
  T? get valueOrNull => fold((l) => null, (r) => r);

  /// Gets the failure if failed, otherwise returns null
  ///
  /// Example:
  /// ```dart
  /// final failure = result.failureOrNull;
  /// if (failure != null) {
  ///   logger.error(failure.message);
  /// }
  /// ```
  Failure? get failureOrNull => fold((l) => l, (r) => null);

  /// Gets the value if successful, otherwise throws an exception
  ///
  /// **Warning**: Only use this in situations where a failure is truly exceptional
  /// and should crash the app (e.g., critical initialization that must succeed).
  ///
  /// Example:
  /// ```dart
  /// final config = await loadConfig().then((r) => r.valueOrThrow);
  /// ```
  ///
  /// Throws: [Exception] containing the failure message
  T get valueOrThrow => fold(
        (failure) => throw Exception(failure.message),
        (value) => value,
      );

  /// Gets the value if successful, otherwise returns [defaultValue]
  ///
  /// This is the recommended way to provide a fallback value.
  ///
  /// Example:
  /// ```dart
  /// final user = result.getOrElse(User.guest());
  /// print('Hello ${user.name}');
  /// ```
  T getOrElse(T defaultValue) => fold(
        (_) => defaultValue,
        (value) => value,
      );

  /// Gets the value if successful, otherwise computes and returns a fallback
  ///
  /// Use this when the fallback value is expensive to compute and should
  /// only be created when needed.
  ///
  /// Example:
  /// ```dart
  /// final user = result.getOrElseCompute(
  ///   (failure) {
  ///     logger.warn('Using guest user due to: ${failure.message}');
  ///     return User.guest();
  ///   },
  /// );
  /// ```
  T getOrElseCompute(T Function(Failure) orElse) => fold(
        (failure) => orElse(failure),
        (value) => value,
      );

  /// Maps the successful value using [transform]
  ///
  /// The failure (if any) is preserved unchanged.
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<int> length = nameResult.mapValue((name) => name.length);
  /// ```
  ValueGuard<R> mapValue<R>(R Function(T) transform) {
    return map(transform);
  }

  /// Maps the failure using [transform]
  ///
  /// The successful value (if any) is preserved unchanged.
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<User> result = userResult.mapFailure(
  ///   (failure) => CustomFailure('User error: ${failure.message}'),
  /// );
  /// ```
  ValueGuard<T> mapFailure(Failure Function(Failure) transform) {
    return leftMap(transform);
  }

  /// FlatMap for chaining operations that return ValueGuard
  ///
  /// If this is a success, applies [transform] to the value.
  /// If this is a failure, returns the failure without calling [transform].
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<Profile> profile = userResult.flatMap(
  ///   (user) => getProfile(user.id),
  /// );
  /// ```
  ValueGuard<R> flatMap<R>(ValueGuard<R> Function(T) transform) {
    return flatMap(transform);
  }

  /// Async version of flatMap for chaining async operations
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<Profile> profile = await userResult.flatMapAsync(
  ///   (user) => profileService.getProfile(user.id),
  /// );
  /// ```
  Future<ValueGuard<R>> flatMapAsync<R>(
    Future<ValueGuard<R>> Function(T) transform,
  ) async {
    return fold(
      (failure) => Left(failure),
      (value) => transform(value),
    );
  }

  /// Executes [onSuccess] if this is a success, otherwise does nothing
  ///
  /// Useful for side effects (logging, analytics, etc.)
  ///
  /// Example:
  /// ```dart
  /// result.onSuccess((user) {
  ///   analytics.logEvent('user_loaded', {'userId': user.id});
  /// });
  /// ```
  ///
  /// Returns: this ValueGuard (allows chaining)
  ValueGuard<T> onSuccess(void Function(T) onSuccess) {
    return fold(
      (failure) => Left(failure),
      (value) {
        onSuccess(value);
        return Right(value);
      },
    );
  }

  /// Executes [onFailure] if this is a failure, otherwise does nothing
  ///
  /// Useful for side effects (logging, analytics, etc.)
  ///
  /// Example:
  /// ```dart
  /// result.onFailure((failure) {
  ///   logger.error('Operation failed: ${failure.message}');
  /// });
  /// ```
  ///
  /// Returns: this ValueGuard (allows chaining)
  ValueGuard<T> onFailure(void Function(Failure) onFailure) {
    return fold(
      (failure) {
        onFailure(failure);
        return Left(failure);
      },
      (value) => Right(value),
    );
  }

  /// Swaps success and failure
  ///
  /// Rarely used, but can be useful in specific scenarios.
  ///
  /// Example:
  /// ```dart
  /// // ValueGuard<User> -> ValueGuard<Failure> (with Failure as success)
  /// final swapped = result.swap();
  /// ```
  Either<T, Failure> swap() {
    return fold(
      (failure) => Right(failure),
      (value) => Left(value),
    );
  }
}

/// Helper class for creating [ValueGuard] instances
///
/// Provides convenient factory methods and utility functions for common patterns.
class ValueGuards {
  // Private constructor to prevent instantiation
  const ValueGuards._();

  /// Creates a successful [ValueGuard] with [value]
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<String> result = ValueGuards.success('Hello');
  /// ```
  static ValueGuard<T> success<T>(T value) => Right(value);

  /// Creates a failed [ValueGuard] with [failure]
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<User> result = ValueGuards.failure(
  ///   NotFoundFailure('User not found'),
  /// );
  /// ```
  static ValueGuard<T> failure<T>(Failure failure) => Left(failure);

  /// Creates a [ValueGuard] from a nullable value
  ///
  /// Returns [onNull] failure if value is null, otherwise wraps the value.
  ///
  /// Example:
  /// ```dart
  /// final user = findUser('123'); // returns User?
  /// ValueGuard<User> result = ValueGuards.fromNullable(
  ///   user,
  ///   () => NotFoundFailure('User not found'),
  /// );
  /// ```
  static ValueGuard<T> fromNullable<T>(
    T? value,
    Failure Function() onNull,
  ) {
    return value != null ? Right(value) : Left(onNull());
  }

  /// Creates a [ValueGuard] by executing [function]
  ///
  /// Catches any exceptions and converts them to [Failure] using [onError].
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<Map<String, dynamic>> result = ValueGuards.tryCatch(
  ///   () => jsonDecode(jsonString),
  ///   (error, stack) => ParseFailure('Invalid JSON: $error'),
  /// );
  /// ```
  static ValueGuard<T> tryCatch<T>(
    T Function() function,
    Failure Function(Object error, StackTrace stack) onError,
  ) {
    try {
      return Right(function());
    } catch (error, stack) {
      return Left(onError(error, stack));
    }
  }

  /// Async version of [tryCatch]
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<User> result = await ValueGuards.tryCatchAsync(
  ///   () => api.getUser('123'),
  ///   (error, stack) => NetworkFailure('Failed to fetch user: $error'),
  /// );
  /// ```
  static Future<ValueGuard<T>> tryCatchAsync<T>(
    Future<T> Function() function,
    Failure Function(Object error, StackTrace stack) onError,
  ) async {
    try {
      final value = await function();
      return Right(value);
    } catch (error, stack) {
      return Left(onError(error, stack));
    }
  }

  /// Combines multiple [ValueGuard] results
  ///
  /// Returns success with list of all values if all are successful.
  /// Returns the first failure encountered if any fail.
  ///
  /// Example:
  /// ```dart
  /// final results = await ValueGuards.all([
  ///   getUser('1'),
  ///   getUser('2'),
  ///   getUser('3'),
  /// ]);
  ///
  /// results.fold(
  ///   (failure) => print('At least one failed: ${failure.message}'),
  ///   (users) => print('All succeeded: ${users.length} users'),
  /// );
  /// ```
  static ValueGuard<List<T>> all<T>(List<ValueGuard<T>> results) {
    final values = <T>[];

    for (final result in results) {
      final fold = result.fold(
        (failure) => Left(failure),
        (value) {
          values.add(value);
          return null;
        },
      );

      // If we got a Left (failure), return it immediately
      if (fold != null) {
        return fold as ValueGuard<List<T>>;
      }
    }

    return Right(values);
  }

  /// Async version of [all]
  ///
  /// Example:
  /// ```dart
  /// final results = await ValueGuards.allAsync([
  ///   userService.getUser('1'),
  ///   userService.getUser('2'),
  ///   userService.getUser('3'),
  /// ]);
  /// ```
  static Future<ValueGuard<List<T>>> allAsync<T>(
    List<Future<ValueGuard<T>>> futures,
  ) async {
    final results = await Future.wait(futures);
    return all(results);
  }

  /// Converts a boolean condition to ValueGuard
  ///
  /// Returns success with [value] if [condition] is true,
  /// otherwise returns [onFalse] failure.
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<String> result = ValueGuards.fromCondition(
  ///   email.contains('@'),
  ///   () => email,
  ///   () => ValidationFailure('Invalid email format'),
  /// );
  /// ```
  static ValueGuard<T> fromCondition<T>(
    bool condition,
    T Function() value,
    Failure Function() onFalse,
  ) {
    return condition ? Right(value()) : Left(onFalse());
  }

  /// Creates a ValueGuard from Either
  ///
  /// Useful when working with code that returns raw Either.
  ///
  /// Example:
  /// ```dart
  /// Either<String, int> either = someFunction();
  /// ValueGuard<int> guard = ValueGuards.fromEither(
  ///   either,
  ///   (error) => Failure(message: error),
  /// );
  /// ```
  static ValueGuard<R> fromEither<L, R>(
    Either<L, R> either,
    Failure Function(L) onLeft,
  ) {
    return either.fold(
      (left) => Left(onLeft(left)),
      (right) => Right(right),
    );
  }

  /// Delays execution and returns a successful ValueGuard
  ///
  /// Useful for testing or adding intentional delays.
  ///
  /// Example:
  /// ```dart
  /// ValueGuard<String> result = await ValueGuards.delayed(
  ///   Duration(seconds: 2),
  ///   'Hello after 2 seconds',
  /// );
  /// ```
  static Future<ValueGuard<T>> delayed<T>(Duration duration, T value) async {
    await Future.delayed(duration);
    return Right(value);
  }
}
