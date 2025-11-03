/// Background Service Infrastructure
/// 
/// Provides abstraction for running Dart code in background even when
/// app is closed or minimized.
/// 
/// Current implementation uses flutter_background_service package but can
/// be easily replaced with other providers.
/// 
/// See [doc/README.md] for complete documentation and examples.
library;

// Contracts
export 'contract/contracts.dart';

// Constants
export 'constants/constants.dart';

// Implementations (for consumer app DI setup only)
export 'impl/impl.dart';

