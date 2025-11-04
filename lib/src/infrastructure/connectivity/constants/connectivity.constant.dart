/// Constants for Connectivity Service
class ConnectivityConstants {
  ConnectivityConstants._();

  /// Default check interval for connectivity monitoring
  static const Duration defaultCheckInterval = Duration(seconds: 10);

  /// Default timeout for connectivity check requests
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Minimum check interval (to prevent too frequent checks)
  static const Duration minCheckInterval = Duration(seconds: 1);

  /// Maximum check interval
  static const Duration maxCheckInterval = Duration(minutes: 5);

  /// Default endpoints for connectivity checking
  static const List<String> defaultEndpoints = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://www.apple.com',
  ];

  /// HTTP status codes considered as successful connection
  static const List<int> successStatusCodes = [200, 204, 301, 302];

  /// Service name identifier
  static const String serviceName = 'ConnectivityService';

  /// Log messages
  static const String logInitialized = 'ConnectivityService initialized';
  static const String logChecking = 'Checking internet connection...';
  static const String logConnected = 'Internet connection: Connected';
  static const String logDisconnected = 'Internet connection: Disconnected';
  static const String logError = 'ConnectivityService error';
  static const String logDisposed = 'ConnectivityService disposed';
}
