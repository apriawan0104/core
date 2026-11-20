import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeHelper', () {
    final sample = DateTime(2026, 11, 20, 8, 5, 9);

    test('formats each pattern', () {
      expect(
        DateTimeHelper.getFormattedDateTime(
          sample,
          format: DateTimeFormatType.dateYMD,
        ),
        '2026-11-20',
      );
      expect(
        DateTimeHelper.getFormattedDateTime(
          sample,
          format: DateTimeFormatType.dateDMY,
        ),
        '20-11-2026',
      );
      expect(
        DateTimeHelper.getFormattedDateTime(
          sample,
          format: DateTimeFormatType.time,
        ),
        '08:05',
      );
      expect(
        DateTimeHelper.getFormattedDateTime(
          sample,
          format: DateTimeFormatType.timeFull,
        ),
        '08:05:09',
      );
      expect(
        DateTimeHelper.getFormattedDateTime(sample),
        '20 Nov 2026',
      );
    });

    test('getTransactionDate uses the given clock', () {
      expect(
        DateTimeHelper.getTransactionDate(now: sample),
        '2026-11-20',
      );
    });

    test('morning window is 06:00 inclusive through 17:00 exclusive', () {
      expect(
        DateTimeHelper.isMorningAt(DateTime(2026, 11, 20, 6)),
        isTrue,
      );
      expect(
        DateTimeHelper.isMorningAt(DateTime(2026, 11, 20, 16, 59)),
        isTrue,
      );
      expect(
        DateTimeHelper.isMorningAt(DateTime(2026, 11, 20, 5, 59)),
        isFalse,
      );
      expect(
        DateTimeHelper.isMorningAt(DateTime(2026, 11, 20, 17)),
        isFalse,
      );
      expect(
        DateTimeHelper.isEveningAt(DateTime(2026, 11, 20, 17)),
        isTrue,
      );
      expect(
        DateTimeHelper.isEveningAt(DateTime(2026, 11, 20, 8)),
        isFalse,
      );
    });

    test('morning window bounds can be overridden', () {
      final noon = DateTime(2026, 11, 20, 12);
      expect(
        DateTimeHelper.isMorningAt(noon, startHour: 12, endHour: 13),
        isTrue,
      );
      expect(
        DateTimeHelper.isEveningAt(noon, startHour: 12, endHour: 13),
        isFalse,
      );
    });
  });
}
