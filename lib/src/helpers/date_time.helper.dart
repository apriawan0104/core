import 'package:intl/intl.dart';

/// Fixed date and time patterns.
///
/// The pattern string stays inside this enum so callers never depend on
/// `package:intl`.
enum DateTimeFormatType {
  /// Format: `dd MMM yyyy`
  date('dd MMM yyyy'),

  /// Format: `yyyy-MM-dd`
  dateYMD('yyyy-MM-dd'),

  /// Format: `dd-MM-yyyy`
  dateDMY('dd-MM-yyyy'),

  /// Format: `E, d MMM yyyy`
  dateFullYMD('E, d MMM yyyy'),

  /// Format: `HH:mm`
  time('HH:mm'),

  /// Format: `HH:mm:ss`
  timeFull('HH:mm:ss');

  const DateTimeFormatType(this.value);

  /// `DateFormat` pattern for this type.
  final String value;
}

/// Pure date and time formatting.
///
/// Moved from `buma_core`. Formatting uses `package:intl` internally and
/// returns a [String]. The window for [isMorning] does not wrap past midnight:
/// an hour is morning when `startHour <= hour < endHour`.
class DateTimeHelper {
  const DateTimeHelper._();

  /// Formats [date] with [format].
  ///
  /// [locale] selects the intl locale, for example `id` or `en`. When it is
  /// omitted, intl uses its current default locale.
  static String getFormattedDateTime(
    DateTime date, {
    DateTimeFormatType format = DateTimeFormatType.date,
    String? locale,
  }) {
    return DateFormat(format.value, locale).format(date);
  }

  /// Current local calendar date in `yyyy-MM-dd`.
  ///
  /// Pass [now] to format a specific instant instead of [DateTime.now].
  static String getTransactionDate({DateTime? now, String? locale}) {
    return getFormattedDateTime(
      now ?? DateTime.now(),
      format: DateTimeFormatType.dateYMD,
      locale: locale,
    );
  }

  /// Whether the current local hour falls in the morning window.
  ///
  /// The default window is 06:00 inclusive through 17:00 exclusive.
  static bool get isMorning => isMorningAt(DateTime.now());

  /// Whether [date] falls in the morning window.
  ///
  /// [startHour] is inclusive and [endHour] is exclusive. Both are local hours.
  static bool isMorningAt(
    DateTime date, {
    int startHour = 6,
    int endHour = 17,
  }) {
    final hour = date.hour;
    return hour >= startHour && hour < endHour;
  }

  /// Whether the current local hour is outside the morning window.
  static bool get isEvening => !isMorning;

  /// Whether [date] is outside the morning window.
  static bool isEveningAt(
    DateTime date, {
    int startHour = 6,
    int endHour = 17,
  }) {
    return !isMorningAt(
      date,
      startHour: startHour,
      endHour: endHour,
    );
  }
}
