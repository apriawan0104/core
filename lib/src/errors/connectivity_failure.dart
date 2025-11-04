import 'failures.dart';

/// Base class for connectivity-related failures
class ConnectivityFailure extends Failure {
  const ConnectivityFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Internet connection check failure
class InternetCheckFailure extends ConnectivityFailure {
  const InternetCheckFailure({
    super.message = 'Failed to check internet connection.',
    super.code,
    super.details,
  });
}

/// No internet connection failure
class NoInternetFailure extends ConnectivityFailure {
  const NoInternetFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
    super.details,
  });
}

/// Connectivity listener failure
class ConnectivityListenerFailure extends ConnectivityFailure {
  const ConnectivityListenerFailure({
    super.message = 'Failed to listen to connectivity changes.',
    super.code,
    super.details,
  });
}

/// Custom connectivity check endpoint failure
class ConnectivityEndpointFailure extends ConnectivityFailure {
  const ConnectivityEndpointFailure({
    super.message = 'Failed to reach connectivity check endpoint.',
    super.code,
    super.details,
  });
}

/// Unknown connectivity failure
class UnknownConnectivityFailure extends ConnectivityFailure {
  const UnknownConnectivityFailure({
    super.message = 'An unexpected connectivity error occurred.',
    super.code,
    super.details,
  });
}

