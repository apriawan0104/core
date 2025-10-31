import 'package:equatable/equatable.dart';

class NotificationData extends Equatable {
  const NotificationData({
    required this.routeName,
    this.pathParameter,
    this.queryParameter,
  });

  final String routeName;
  final Map<String, String>? pathParameter;
  final Map<String, Object?>? queryParameter;

  @override
  List<Object?> get props => [routeName, pathParameter, queryParameter];
}

