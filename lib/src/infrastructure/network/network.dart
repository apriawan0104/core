/// Network infrastructure layer
/// 
/// Provides HTTP networking capabilities with dependency-independent design.
/// 
/// Features:
/// - Generic HttpClient interface
/// - Dio implementation (easily replaceable)
/// - Type-safe requests with Either<Failure, Success>
/// - Request/Response/Error interceptors
/// - File upload/download support
/// - Comprehensive error handling
/// 
/// Example usage:
/// ```dart
/// // Setup
/// getIt.registerLazySingleton<HttpClient>(
///   () => DioHttpClient(
///     baseUrl: 'https://api.example.com',
///     enableLogging: true,
///   ),
/// );
/// 
/// // Use in repository
/// class UserRepository {
///   final HttpClient _client;
///   
///   UserRepository(this._client);
///   
///   Future<Either<NetworkFailure, User>> getUser(String id) async {
///     final result = await _client.get<Map<String, dynamic>>('/users/$id');
///     
///     return result.fold(
///       (failure) => Left(failure),
///       (response) => Right(User.fromJson(response.data!)),
///     );
///   }
/// }
/// ```
library network;

// Contracts (always export - these define the interface)
export 'contract/contracts.dart';

// Constants
export 'constants/constants.dart';

// Implementations (export so consumer can use, but they depend on contracts)
export 'impl/impl.dart';

