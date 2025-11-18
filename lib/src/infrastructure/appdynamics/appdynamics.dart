// AppDynamics Infrastructure
//
// Dependency-independent AppDynamics Mobile Real User Monitoring (RUM) service.
//
// This module provides:
// - Abstract interface for AppDynamics monitoring (dependency-independent)
// - AppDynamics Agent implementation (wraps appdynamics_agent package)
// - Configuration models and data structures
// - Error handling with Failure classes
//
// ## Quick Start
//
// ```dart
// import 'package:app_core/app_core.dart';
//
// // Initialize AppDynamics
// final appDynamics = AppDynamicsAgentServiceImpl();
// final config = AppDynamicsConfig(
//   appKey: 'YOUR_EUM_APP_KEY',
//   loggingLevel: AppDynamicsLoggingLevel.verbose,
// );
// await appDynamics.initialize(config);
//
// // Track errors
// await appDynamics.reportError('Something went wrong');
//
// // Track custom metrics
// await appDynamics.reportMetric('checkout_duration', 1250.5);
//
// // Track user flows with session frames
// final frame = await appDynamics.startSessionFrame('checkout_process');
// // ... perform operations ...
// await appDynamics.endSessionFrame(frame);
// ```
//
// See [doc/README.md] for detailed documentation.

export 'contract/contracts.dart';
export 'impl/impl.dart';
export 'models/models.dart';
export 'constants/constants.dart';
