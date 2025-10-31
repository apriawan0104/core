class ParsingHelper {
  const ParsingHelper._();

  /// Converts the dynamic data to a [Map<String, Object?>]
  /// if possible, or returns null.
  ///
  /// Returns null if the dynamic data is not a [Map<String, Object?>].
  static Map<String, Object?>? toMapOrNull(dynamic object) {
    if (object is Map<String, Object?>) {
      return object;
    }
    return null;
  }

  /// Converts the dynamic to a [String] if possible, or returns null.
  ///
  /// Returns null if the dynamic data is not a [String].
  static String? toStringOrNull(dynamic object) {
    if (object is String) {
      return object;
    }
    return null;
  }
}
