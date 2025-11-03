import 'failures.dart';

/// Base class for network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Connection failure - no internet or server unreachable
class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure({
    super.message = 'Connection failed. Please check your internet connection.',
    super.code,
    super.details,
  });
}

/// Timeout failure - request took too long
class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure({
    super.message = 'Request timeout. Please try again.',
    super.code,
    super.details,
  });
}

/// Server failure - 5xx errors
class ServerFailure extends NetworkFailure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    this.statusCode,
    super.code,
    super.details,
  });
}

/// Client failure - 4xx errors
class ClientFailure extends NetworkFailure {
  final int? statusCode;

  const ClientFailure({
    super.message = 'Bad request.',
    this.statusCode,
    super.code,
    super.details,
  });
}

/// Unauthorized failure - 401
class UnauthorizedFailure extends ClientFailure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized. Please login again.',
    super.code,
    super.details,
  }) : super(statusCode: 401);
}

/// Forbidden failure - 403
class ForbiddenFailure extends ClientFailure {
  const ForbiddenFailure({
    super.message = 'Access forbidden.',
    super.code,
    super.details,
  }) : super(statusCode: 403);
}

/// Not found failure - 404
class NotFoundFailure extends ClientFailure {
  const NotFoundFailure({
    super.message = 'Resource not found.',
    super.code,
    super.details,
  }) : super(statusCode: 404);
}

/// Parse failure - invalid response format
class ParseFailure extends NetworkFailure {
  const ParseFailure({
    super.message = 'Failed to parse response.',
    super.code,
    super.details,
  });
}

/// Cancel failure - request was cancelled
class CancelFailure extends NetworkFailure {
  const CancelFailure({
    super.message = 'Request was cancelled.',
    super.code,
    super.details,
  });
}

/// Unknown network failure - unexpected error
class UnknownNetworkFailure extends NetworkFailure {
  const UnknownNetworkFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
    super.details,
  });
}
