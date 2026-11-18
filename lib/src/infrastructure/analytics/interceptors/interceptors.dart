/// Analytics Interceptors
///
/// This module provides interceptors for automatic error reporting
/// and analytics tracking.
///
/// ## Available Interceptors
///
/// - [CrashReportingInterceptor] - Automatically report network errors to crash reporter
///
/// ## Usage
///
/// Import this file to access all analytics interceptors:
///
/// ```dart
/// import 'package:app_core/app_core.dart';
/// import 'package:get_it/get_it.dart';
///
/// final getIt = GetIt.instance;
///
/// final interceptor = CrashReportingInterceptor(
///   crashReporter: getIt<CrashReporterService>(),
/// );
/// ```
library;

export 'crash_reporting.interceptor.dart';
