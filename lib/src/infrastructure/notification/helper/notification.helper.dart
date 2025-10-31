import 'dart:convert';

import '../../../foundation/domain/entities/notification/entities.dart';
import '../../../helpers/helpers.dart';
import '../constants/constants.dart';

class NotificationHelper {
  const NotificationHelper._();

  static NotificationData? parseNotificationData(
    String? payload,
  ) {
    final notificationPayload = jsonDecode(payload ?? '');
    final isNotificationPayloadValid =
        notificationPayload is Map<String, Object?>;

    if (isNotificationPayloadValid) {
      final layoutData = jsonDecode(
        notificationPayload[NotificationPayloadConstant.layout].toString(),
      );
      final isLayoutDataValid = layoutData is Map<String, Object?>;

      if (isLayoutDataValid) {
        try {
          final routeName = ParsingHelper.toStringOrNull(
            layoutData[NotificationPayloadConstant.routeName],
          );
          final pathParameter = ParsingHelper.toMapOrNull(
            layoutData[NotificationPayloadConstant.pathParameter],
          );
          final queryParameter = ParsingHelper.toMapOrNull(
            layoutData[NotificationPayloadConstant.queryParameter],
          );

          if (routeName != null) {
            return NotificationData(
              routeName: routeName,
              pathParameter: pathParameter?.cast<String, String>(),
              queryParameter: queryParameter,
            );
          }
        } catch (e, stackTrace) {
          logger.e(
            'Error while parsing notification payload',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    }

    return null;
  }
}
