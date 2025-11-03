import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;

import '../../../errors/errors.dart';
import '../../../foundation/domain/entities/network/entities.dart';
import '../../../foundation/domain/entities/network/request_options.entity.dart'
    as request_options;
import '../contract/contracts.dart';

/// Dio implementation of HttpClient
///
/// This implementation wraps the Dio package to provide a consistent
/// interface that follows the Dependency Inversion Principle.
///
/// Can be easily replaced with other HTTP client implementations
/// (e.g., http package, Chopper) without affecting consumer code.
class DioHttpClient implements HttpClient {
  final dio.Dio _dio;
  final List<RequestInterceptor> _requestInterceptors = [];
  final List<ResponseInterceptor> _responseInterceptors = [];
  final List<ErrorInterceptor> _errorInterceptors = [];

  DioHttpClient({
    required String baseUrl,
    Map<String, dynamic>? headers,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
    bool enableLogging = false,
  }) : _dio = dio.Dio(
          dio.BaseOptions(
            baseUrl: baseUrl,
            headers: headers,
            connectTimeout: Duration(milliseconds: connectTimeout),
            receiveTimeout: Duration(milliseconds: receiveTimeout),
            sendTimeout: Duration(milliseconds: sendTimeout),
            validateStatus: (status) => true, // Don't throw on any status code
          ),
        ) {
    if (enableLogging) {
      _dio.interceptors.add(
        dio.LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    // Add custom interceptor handler
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  @override
  String get baseUrl => _dio.options.baseUrl;

  @override
  Map<String, dynamic> get defaultHeaders => _dio.options.headers;

  @override
  int get connectTimeout =>
      _dio.options.connectTimeout?.inMilliseconds ?? 30000;

  @override
  int get receiveTimeout =>
      _dio.options.receiveTimeout?.inMilliseconds ?? 30000;

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    RequestOptionsEntity? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> request<T>(
    RequestOptionsEntity options,
  ) async {
    try {
      final response = await _dio.request<T>(
        options.url,
        data: options.data,
        queryParameters: options.queryParameters,
        options: dio.Options(
          method: options.method.value,
          headers: options.headers,
          responseType: _convertResponseType(options.responseType),
          followRedirects: options.followRedirects,
          maxRedirects: options.maxRedirects,
        ),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, String>> download(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
        onReceiveProgress: onProgress,
      );
      return Right(savePath);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<NetworkFailure, HttpResponseEntity<T>>> upload<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    void Function(int sent, int total)? onProgress,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        ...?data,
        fieldName: await dio.MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        options: dio.Options(headers: headers),
        onSendProgress: onProgress,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  void addRequestInterceptor(RequestInterceptor interceptor) {
    _requestInterceptors.add(interceptor);
  }

  @override
  void addResponseInterceptor(ResponseInterceptor interceptor) {
    _responseInterceptors.add(interceptor);
  }

  @override
  void addErrorInterceptor(ErrorInterceptor interceptor) {
    _errorInterceptors.add(interceptor);
  }

  @override
  void clearInterceptors() {
    _requestInterceptors.clear();
    _responseInterceptors.clear();
    _errorInterceptors.clear();
  }

  @override
  void cancelAllRequests() {
    _dio.close(force: true);
  }

  @override
  void cancelRequest(String tag) {
    // Dio doesn't support canceling by tag directly
    // Implementation would need CancelToken management
    // For now, this is a placeholder
  }

  // ============== Private Helper Methods ==============

  Future<void> _onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    var requestOptions = RequestOptionsEntity(
      url: options.uri.toString(),
      method: _convertHttpMethod(options.method),
      headers: options.headers,
      queryParameters: options.queryParameters,
      data: options.data,
    );

    // Apply custom interceptors
    for (final interceptor in _requestInterceptors) {
      requestOptions = await interceptor(requestOptions);
    }

    // Update Dio options if modified
    options.headers = requestOptions.headers ?? {};
    options.queryParameters = requestOptions.queryParameters ?? {};
    options.data = requestOptions.data;

    handler.next(options);
  }

  Future<void> _onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) async {
    var httpResponse = _convertToHttpResponse(response);

    // Apply custom interceptors
    for (final interceptor in _responseInterceptors) {
      httpResponse = await interceptor(httpResponse);
    }

    handler.next(response);
  }

  Future<void> _onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
    var failure = _handleError(err);

    // Apply custom error interceptors
    for (final interceptor in _errorInterceptors) {
      final result = await interceptor(failure);
      result.fold(
        (newFailure) => failure = newFailure,
        (response) {
          // Interceptor recovered from error
          handler.resolve(dio.Response(
            requestOptions: err.requestOptions,
            data: response.data,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            headers:
                dio.Headers.fromMap(_convertHeadersToListMap(response.headers)),
          ));
          return;
        },
      );
    }

    handler.next(err);
  }

  Either<NetworkFailure, HttpResponseEntity<T>> _handleResponse<T>(
    dio.Response<T> response,
  ) {
    final statusCode = response.statusCode ?? 0;

    // Check for successful status codes
    if (statusCode >= 200 && statusCode < 300) {
      return Right(HttpResponseEntity<T>(
        data: response.data,
        statusCode: statusCode,
        statusMessage: response.statusMessage,
        headers: response.headers.map,
      ));
    }

    // Handle error status codes
    return Left(_createFailureFromStatusCode(
      statusCode,
      response.statusMessage,
      response.data,
    ));
  }

  NetworkFailure _handleError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          return TimeoutFailure(
            message: error.message ?? 'Request timeout',
            details: error,
          );

        case dio.DioExceptionType.connectionError:
          return ConnectionFailure(
            message: error.message ?? 'Connection failed',
            details: error,
          );

        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          return _createFailureFromStatusCode(
            statusCode,
            error.message,
            error.response?.data,
          );

        case dio.DioExceptionType.cancel:
          return CancelFailure(
            message: 'Request was cancelled',
            details: error,
          );

        case dio.DioExceptionType.badCertificate:
          return ConnectionFailure(
            message: 'SSL certificate verification failed',
            details: error,
          );

        case dio.DioExceptionType.unknown:
          if (error.error is SocketException) {
            return ConnectionFailure(
              message: 'No internet connection',
              details: error,
            );
          }
          return UnknownNetworkFailure(
            message: error.message ?? 'An unexpected error occurred',
            details: error,
          );
      }
    }

    return UnknownNetworkFailure(
      message: error.toString(),
      details: error,
    );
  }

  NetworkFailure _createFailureFromStatusCode(
    int statusCode,
    String? message,
    dynamic data,
  ) {
    switch (statusCode) {
      case 401:
        return UnauthorizedFailure(
          message: message ?? 'Unauthorized',
          details: data,
        );
      case 403:
        return ForbiddenFailure(
          message: message ?? 'Access forbidden',
          details: data,
        );
      case 404:
        return NotFoundFailure(
          message: message ?? 'Resource not found',
          details: data,
        );
      case >= 400 && < 500:
        return ClientFailure(
          statusCode: statusCode,
          message: message ?? 'Client error',
          details: data,
        );
      case >= 500 && < 600:
        return ServerFailure(
          statusCode: statusCode,
          message: message ?? 'Server error',
          details: data,
        );
      default:
        return UnknownNetworkFailure(
          message: message ?? 'Unknown error',
          details: data,
        );
    }
  }

  HttpResponseEntity<dynamic> _convertToHttpResponse(dio.Response response) {
    return HttpResponseEntity(
      data: response.data,
      statusCode: response.statusCode ?? 0,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }

  /// Convert headers map to list map for Dio Headers
  Map<String, List<String>> _convertHeadersToListMap(
      Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<String>());
      }
      return MapEntry(key, [value.toString()]);
    });
  }

  HttpMethod _convertHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.get;
      case 'POST':
        return HttpMethod.post;
      case 'PUT':
        return HttpMethod.put;
      case 'PATCH':
        return HttpMethod.patch;
      case 'DELETE':
        return HttpMethod.delete;
      case 'HEAD':
        return HttpMethod.head;
      case 'OPTIONS':
        return HttpMethod.options;
      default:
        return HttpMethod.get;
    }
  }

  dio.ResponseType _convertResponseType(
    request_options.ResponseType type,
  ) {
    switch (type) {
      case request_options.ResponseType.json:
        return dio.ResponseType.json;
      case request_options.ResponseType.stream:
        return dio.ResponseType.stream;
      case request_options.ResponseType.plain:
        return dio.ResponseType.plain;
      case request_options.ResponseType.bytes:
        return dio.ResponseType.bytes;
    }
  }
}
