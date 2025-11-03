/// Network constants
class NetworkConstants {
  NetworkConstants._();

  /// Default connection timeout in milliseconds
  static const int defaultConnectTimeout = 30000;

  /// Default receive timeout in milliseconds
  static const int defaultReceiveTimeout = 30000;

  /// Default send timeout in milliseconds
  static const int defaultSendTimeout = 30000;

  /// Default max redirects
  static const int defaultMaxRedirects = 5;

  /// Common HTTP headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  static const String headerCacheControl = 'Cache-Control';
  static const String headerIfModifiedSince = 'If-Modified-Since';
  static const String headerIfNoneMatch = 'If-None-Match';

  /// Common content types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormUrlEncoded =
      'application/x-www-form-urlencoded';
  static const String contentTypeMultipartFormData = 'multipart/form-data';
  static const String contentTypeText = 'text/plain';
  static const String contentTypeHtml = 'text/html';
  static const String contentTypeXml = 'application/xml';

  /// HTTP status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusMethodNotAllowed = 405;
  static const int statusConflict = 409;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
  static const int statusGatewayTimeout = 504;
}
