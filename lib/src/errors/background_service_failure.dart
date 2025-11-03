import 'failures.dart';

/// Base class for background service-related failures
class BackgroundServiceFailure extends Failure {
  const BackgroundServiceFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Configuration failure - failed to configure service
class BackgroundServiceConfigurationFailure extends BackgroundServiceFailure {
  const BackgroundServiceConfigurationFailure({
    super.message = 'Failed to configure background service.',
    super.code,
    super.details,
  });
}

/// Start failure - failed to start service
class BackgroundServiceStartFailure extends BackgroundServiceFailure {
  const BackgroundServiceStartFailure({
    super.message = 'Failed to start background service.',
    super.code,
    super.details,
  });
}

/// Invoke failure - failed to send data to service
class BackgroundServiceInvokeFailure extends BackgroundServiceFailure {
  const BackgroundServiceInvokeFailure({
    super.message = 'Failed to invoke method on background service.',
    super.code,
    super.details,
  });
}

/// Status check failure - failed to check service status
class BackgroundServiceStatusFailure extends BackgroundServiceFailure {
  const BackgroundServiceStatusFailure({
    super.message = 'Failed to check background service status.',
    super.code,
    super.details,
  });
}

