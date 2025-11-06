import 'failures.dart';

/// Failure for authentication operations
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message: message);
}

/// User cancelled the authentication flow
class AuthenticationCancelledFailure extends AuthenticationFailure {
  const AuthenticationCancelledFailure()
      : super('User cancelled the authentication flow');
}

/// Invalid credentials provided
class InvalidCredentialsFailure extends AuthenticationFailure {
  const InvalidCredentialsFailure([String? message])
      : super(message ?? 'Invalid credentials provided');
}

/// Account already exists
class AccountAlreadyExistsFailure extends AuthenticationFailure {
  const AccountAlreadyExistsFailure([String? message])
      : super(message ?? 'An account with this email already exists');
}

/// Account not found
class AccountNotFoundFailure extends AuthenticationFailure {
  const AccountNotFoundFailure([String? message])
      : super(message ?? 'No account found with the provided credentials');
}

/// Network error during authentication
class AuthenticationNetworkFailure extends AuthenticationFailure {
  const AuthenticationNetworkFailure([String? message])
      : super(message ?? 'Network error occurred during authentication');
}

/// Token expired or invalid
class TokenExpiredFailure extends AuthenticationFailure {
  const TokenExpiredFailure([String? message])
      : super(message ?? 'Authentication token has expired');
}

/// Provider-specific configuration error
class AuthenticationConfigurationFailure extends AuthenticationFailure {
  const AuthenticationConfigurationFailure([String? message])
      : super(message ?? 'Authentication provider is not properly configured');
}

/// Insufficient permissions or scope
class InsufficientPermissionsFailure extends AuthenticationFailure {
  const InsufficientPermissionsFailure([String? message])
      : super(message ?? 'Insufficient permissions for this operation');
}

/// Provider not available on current platform
class ProviderNotAvailableFailure extends AuthenticationFailure {
  const ProviderNotAvailableFailure([String? message])
      : super(message ??
            'This authentication provider is not available on the current platform');
}
