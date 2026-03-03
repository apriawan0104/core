/// Use case abstractions for encapsulating business logic
///
/// This module provides base classes for implementing use cases following
/// Clean Architecture principles.
///
/// ## Available Classes
///
/// - [UseCaseAsync]: For asynchronous operations (network, database, I/O)
/// - [UseCase]: For synchronous operations (validation, computation)
/// - [NoParams]: Parameter class for use cases that require no input
///
/// ## Usage
///
/// ```dart
/// import 'package:buma_core/src/foundation/domain/usecases/usecases.dart';
/// ```
library usecases;

export 'usecase.dart';
