import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';

/// Result type abstraction
///
/// This typedef abstracts the Either type from dartz package,
/// allowing easy switching to fpdart or custom implementations in the future.
///
/// Following the Dependency Independence principle, this abstraction allows
/// the core library to change the underlying Either implementation without
/// affecting consumer code.
///
/// ## Generic Parameters
///
/// - `L`: Left type (typically represents failure/error)
/// - `R`: Right type (represents success value)
///
/// ## Usage
///
/// ```dart
/// // Using Result directly
/// Future<Result<NetworkFailure, User>> getUser(String id);
///
/// // Using FailableResult (when Left is always Failure)
/// Future<FailableResult<User>> getUser(String id);
///
/// // Creating results
/// Result<Failure, String> success = ResultExtension.success('Hello');
/// Result<Failure, String> failure = ResultExtension.failure(
///   Failure(message: 'Error'),
/// );
/// ```
///
/// ## Benefits
///
/// - ✅ Easy to switch between Either implementations (dartz, fpdart, custom)
/// - ✅ Cleaner API - shorter type signatures
/// - ✅ Consistent error handling across the codebase
/// - ✅ Future-proof - implementation changes don't affect consumers
typedef Result<L, R> = Either<L, R>;

/// Extension methods for Result type
///
/// Provides convenient factory methods for creating Result instances.
extension ResultExtension<L, R> on Result<L, R> {
  /// Create a successful result (Right)
  ///
  /// Example:
  /// ```dart
  /// final result = ResultExtension.success<Failure, String>('Success!');
  /// ```
  static Result<L, R> success<L, R>(R value) => Right(value);

  /// Create a failed result (Left)
  ///
  /// Example:
  /// ```dart
  /// final result = ResultExtension.failure<Failure, String>(
  ///   Failure(message: 'Something went wrong'),
  /// );
  /// ```
  static Result<L, R> failure<L, R>(L error) => Left(error);
}

/// Specialized Result type for operations that might fail
///
/// This is a convenience typedef where the Left side is always a [Failure].
/// Use this when you want cleaner type signatures and always use Failure
/// as the error type.
///
/// ## Usage
///
/// ```dart
/// // Before (verbose)
/// Future<Either<Failure, User>> getUser();
///
/// // After (cleaner)
/// Future<FailableResult<User>> getUser();
/// ```
typedef FailableResult<T> = Result<Failure, T>;

/// Extension methods for FailableResult
///
/// Provides convenient factory methods for creating FailableResult instances.
extension FailableResultExtension on Never {
  /// Create a successful FailableResult
  ///
  /// Example:
  /// ```dart
  /// final result = FailableResultExtension.ok('Success!');
  /// ```
  static FailableResult<T> ok<T>(T value) => Right(value);

  /// Create a failed FailableResult
  ///
  /// Example:
  /// ```dart
  /// final result = FailableResultExtension.error(
  ///   Failure(message: 'Error occurred'),
  /// );
  /// ```
  static FailableResult<T> error<T>(Failure failure) => Left(failure);
}

