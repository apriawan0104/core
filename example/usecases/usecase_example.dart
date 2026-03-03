// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_brace_in_string_interps

import 'package:dartz/dartz.dart';
import 'package:app_core/app_core.dart';

// ============================================================================
// EXAMPLE 1: Async Use Case with Parameters
// ============================================================================

/// Parameters for GetUserUseCase
class GetUserParams {
  final String userId;

  const GetUserParams(this.userId);
}

/// Example domain entity
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

/// Example repository interface
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String userId);
}

/// Example use case: Get user by ID
class GetUserUseCase implements UseCaseAsync<User, GetUserParams> {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return repository.getUser(params.userId);
  }
}

// ============================================================================
// EXAMPLE 2: Async Use Case without Parameters
// ============================================================================

/// Example use case: Get current logged-in user
class GetCurrentUserUseCase implements UseCaseAsync<User, NoParams> {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    // Logic to get current user
    return repository.getUser('current');
  }
}

// ============================================================================
// EXAMPLE 3: Sync Use Case with Validation
// ============================================================================

/// Parameters for ValidateEmailUseCase
class ValidateEmailParams {
  final String email;

  const ValidateEmailParams(this.email);
}

/// Example use case: Validate email format
class ValidateEmailUseCase implements UseCase<bool, ValidateEmailParams> {
  @override
  Either<Failure, bool> call(ValidateEmailParams params) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (params.email.isEmpty) {
      return Left(
        Failure(message: 'Email cannot be empty'),
      );
    }

    if (!emailRegex.hasMatch(params.email)) {
      return Left(
        Failure(message: 'Invalid email format'),
      );
    }

    return const Right(true);
  }
}

// ============================================================================
// EXAMPLE 4: Use Case with Business Logic
// ============================================================================

/// Parameters for CalculateDiscountUseCase
class CalculateDiscountParams {
  final double originalPrice;
  final double discountPercentage;

  const CalculateDiscountParams({
    required this.originalPrice,
    required this.discountPercentage,
  });
}

/// Example use case: Calculate discount price
class CalculateDiscountUseCase
    implements UseCase<double, CalculateDiscountParams> {
  @override
  Either<Failure, double> call(CalculateDiscountParams params) {
    if (params.originalPrice < 0) {
      return Left(
        Failure(message: 'Price cannot be negative'),
      );
    }

    if (params.discountPercentage < 0 || params.discountPercentage > 100) {
      return Left(
        Failure(message: 'Discount must be between 0 and 100'),
      );
    }

    final discountAmount =
        params.originalPrice * (params.discountPercentage / 100);
    final finalPrice = params.originalPrice - discountAmount;

    return Right(finalPrice);
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

void main() async {
  // Mock repository for demonstration
  final mockRepository = MockUserRepository();

  // Example 1: Async use case with parameters
  print('=== Example 1: Get User by ID ===');
  final getUserUseCase = GetUserUseCase(mockRepository);
  final userResult = await getUserUseCase(const GetUserParams('123'));

  userResult.fold(
    (failure) => print('Error: ${failure.message}'),
    (user) => print('Success: User ${user.name} (${user.email})'),
  );

  // Example 2: Async use case without parameters
  print('\n=== Example 2: Get Current User ===');
  final getCurrentUserUseCase = GetCurrentUserUseCase(mockRepository);
  final currentUserResult = await getCurrentUserUseCase(const NoParams());

  currentUserResult.fold(
    (failure) => print('Error: ${failure.message}'),
    (user) => print('Success: Current user is ${user.name}'),
  );

  // Example 3: Sync use case with validation
  print('\n=== Example 3: Validate Email ===');
  final validateEmailUseCase = ValidateEmailUseCase();
  final emailValidation =
      validateEmailUseCase(const ValidateEmailParams('user@example.com'));

  emailValidation.fold(
    (failure) => print('Invalid: ${failure.message}'),
    (isValid) => print('Valid: Email is correct'),
  );

  // Example 4: Use case with business logic
  print('\n=== Example 4: Calculate Discount ===');
  final calculateDiscountUseCase = CalculateDiscountUseCase();
  final discountResult = calculateDiscountUseCase(
    const CalculateDiscountParams(
      originalPrice: 100.0,
      discountPercentage: 20.0,
    ),
  );

  discountResult.fold(
    (failure) => print('Error: ${failure.message}'),
    (finalPrice) => print('Final price after discount: \$${finalPrice}'),
  );
}

// ============================================================================
// MOCK REPOSITORY FOR DEMONSTRATION
// ============================================================================

class MockUserRepository implements UserRepository {
  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    if (userId == '123' || userId == 'current') {
      return const Right(
        User(
          id: '123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        ),
      );
    }

    return Left(
      Failure(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      ),
    );
  }
}
