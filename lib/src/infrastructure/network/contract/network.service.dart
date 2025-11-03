import 'package:dartz/dartz.dart';

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/network/entities.dart';

/// HTTP Client Service Interface
///
/// Generic HTTP client interface that is independent of any specific implementation.
/// Can be implemented with Dio, http, Chopper, or any other HTTP client library.
///
/// Features:
/// - Request/Response interceptors support
/// - Timeout configuration
/// - Error handling with Either<Failure, Success>
/// - Type-safe responses
/// - Cancel request support
///
/// Example:
/// ```dart
/// final client = getIt<HttpClient>();
///
/// final result = await client.get<Map<String, dynamic>>(
///   '/users',
///   queryParameters: {'page': 1},
/// );
///
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (response) => print('Data: ${response.data}'),
/// );
/// ```
abstract class HttpClient {
  /// Base URL for all requests
  String get baseUrl;

  /// Default headers for all requests
  Map<String, dynamic> get defaultHeaders;

  /// Connection timeout in milliseconds
  int get connectTimeout;

  /// Receive timeout in milliseconds
  int get receiveTimeout;

  /// Performs GET request
  ///
  /// [path] - Request path (will be appended to baseUrl)
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers for this request
  /// [options] - Custom request options
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  });

  /// Performs POST request
  ///
  /// [path] - Request path (will be appended to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers for this request
  /// [options] - Custom request options
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  });

  /// Performs PUT request
  ///
  /// [path] - Request path (will be appended to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers for this request
  /// [options] - Custom request options
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  });

  /// Performs PATCH request
  ///
  /// [path] - Request path (will be appended to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers for this request
  /// [options] - Custom request options
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  });

  /// Performs DELETE request
  ///
  /// [path] - Request path (will be appended to baseUrl)
  /// [data] - Request body data (optional)
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers for this request
  /// [options] - Custom request options
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  });

  /// Performs custom request with full options
  ///
  /// [options] - Complete request configuration
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> request<T>(
    RequestOptionsEntity options,
  );

  /// Download file from URL
  ///
  /// [url] - Full URL or path
  /// [savePath] - Local path to save the file
  /// [onProgress] - Optional progress callback (received, total)
  /// [queryParameters] - URL query parameters
  /// [headers] - Additional headers
  ///
  /// Returns [Either<NetworkFailure, String>] - Success returns the save path
  Future<Either<NetworkFailure, String>> download(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  /// Upload file to server
  ///
  /// [path] - Request path
  /// [filePath] - Local file path to upload
  /// [fieldName] - Form field name for the file
  /// [data] - Additional form data
  /// [onProgress] - Optional progress callback (sent, total)
  /// [headers] - Additional headers
  ///
  /// Returns [Either<NetworkFailure, HttpResponseEntity<T>>]
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> upload<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    void Function(int sent, int total)? onProgress,
    Map<String, dynamic>? headers,
  });

  /// Add request interceptor
  ///
  /// Interceptors can modify requests before they are sent.
  /// Multiple interceptors can be added and will be called in order.
  void addRequestInterceptor(RequestInterceptor interceptor);

  /// Add response interceptor
  ///
  /// Interceptors can modify responses before they are returned.
  /// Multiple interceptors can be added and will be called in order.
  void addResponseInterceptor(ResponseInterceptor interceptor);

  /// Add error interceptor
  ///
  /// Interceptors can handle or modify errors.
  void addErrorInterceptor(ErrorInterceptor interceptor);

  /// Clear all interceptors
  void clearInterceptors();

  /// Cancel all pending requests
  void cancelAllRequests();

  /// Cancel specific request by tag
  void cancelRequest(String tag);
}

/// Request interceptor function type
///
/// Can modify the request options before the request is sent.
/// Return modified options or original options.
typedef RequestInterceptor = Future<RequestOptionsEntity> Function(
  RequestOptionsEntity options,
);

/// Response interceptor function type
///
/// Can modify the response before it is returned.
/// Return modified response or original response.
typedef ResponseInterceptor = Future<HttpResponseEntity<dynamic>> Function(
  HttpResponseEntity<dynamic> response,
);

/// Error interceptor function type
///
/// Can handle or modify errors.
/// Return a failure to continue the error chain, or a response to recover.
typedef ErrorInterceptor
    = Future<Either<NetworkFailure, HttpResponseEntity<dynamic>>> Function(
  NetworkFailure failure,
);
