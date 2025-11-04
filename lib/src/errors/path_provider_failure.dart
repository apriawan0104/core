import 'package:app_core/src/errors/failures.dart';

/// Failure class for path provider operations
class PathProviderFailure extends Failure {
  const PathProviderFailure(String message) : super(message: message);
}

/// Failure when a directory is not available on the current platform
class DirectoryNotSupportedFailure extends PathProviderFailure {
  const DirectoryNotSupportedFailure(super.message);
}

/// Failure when unable to access a directory
class DirectoryAccessFailure extends PathProviderFailure {
  const DirectoryAccessFailure(super.message);
}

/// Failure when a directory does not exist
class DirectoryNotFoundFailure extends PathProviderFailure {
  const DirectoryNotFoundFailure(super.message);
}

/// Failure when unable to create a directory
class DirectoryCreationFailure extends PathProviderFailure {
  const DirectoryCreationFailure(super.message);
}
