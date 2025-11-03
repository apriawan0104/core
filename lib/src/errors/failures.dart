/// Base failure class for all errors in the application
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    if (code != null) {
      return 'Failure(code: $code, message: $message)';
    }
    return 'Failure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Failure &&
        other.message == message &&
        other.code == code &&
        other.details == details;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode ^ details.hashCode;
}
