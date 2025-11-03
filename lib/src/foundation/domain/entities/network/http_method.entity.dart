/// HTTP request methods
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
  head,
  options;

  /// Convert to string
  String get value => name.toUpperCase();

  @override
  String toString() => value;
}

