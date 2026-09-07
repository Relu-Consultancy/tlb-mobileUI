import 'name_case.dart';

/// One date format for the whole app: **"Sat, 22 Mar 2026"**.
///
/// Before this existed, thirteen private helpers across the screens produced
/// eight different shapes — "22 Mar 2026", "Sat 22 Mar", "Sat, Mar 22",
/// "Saturday, Mar 22", "Mar 22, 2026" — so two cards side by side could
/// disagree. Everything that renders a date as a single label now comes
/// through here.
///
/// The year is always shown. Dropping it only reads well for dates near today,
/// and the same helper labels bookings, refunds and reviews from the past.
///
/// Times are [TimeFormat]'s job; this deliberately does dates only.
class DateFormat {
  const DateFormat._();

  /// Indexed by `DateTime.weekday - 1` (Dart weeks start on Monday).
  static const _weekdaysFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday',
  ];
  static const _weekdaysShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Sat, 22 Mar 2026" — the app's date label.
  static String card(DateTime d) =>
      '${_weekdaysShort[d.weekday - 1]}, ${d.day} '
      '${_monthsShort[d.month - 1]} ${d.year}';

  /// [card] for an API date ("2026-03-22") or datetime ("2026-03-22T18:30:00Z").
  ///
  /// Returns [fallback] when the value is missing or unparseable, so a bad row
  /// shows "TBA" rather than a raw ISO string.
  static String cardFrom(String? raw, {String fallback = 'TBA'}) {
    if (raw == null || raw.isEmpty) return fallback;
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? fallback : card(parsed);
  }

  /// "Monday" (or "Mon") from the API's lowercase `"monday"`.
  ///
  /// A value that isn't a weekday name is capitalised and returned as-is —
  /// better a readable unknown than a dropped one.
  static String weekday(String raw, {bool short = false}) {
    final key = raw.trim().toLowerCase();
    final i = _weekdaysFull.indexWhere((d) => d.toLowerCase() == key);
    if (i == -1) {
      final fallback = short && raw.length > 3 ? raw.substring(0, 3) : raw;
      return NameCase.of(fallback);
    }
    return short ? _weekdaysShort[i] : _weekdaysFull[i];
  }

  /// "Monday, Wednesday" (or "Mon, Wed") from `["monday", "wednesday"]` — a
  /// batch's recurring days as the API sends them.
  static String weekdayList(Iterable<String> raw, {bool short = false}) =>
      raw.map((d) => weekday(d, short: short)).join(', ');

  /// The day and month names on their own, for the rare layout that stacks
  /// the parts of a date rather than printing one label — a calendar day tile
  /// showing "Sat / 22 / Mar" down three lines. Prefer [card] everywhere else.
  static String weekdayOf(DateTime d, {bool short = true}) =>
      short ? _weekdaysShort[d.weekday - 1] : _weekdaysFull[d.weekday - 1];

  static String monthOf(DateTime d) => _monthsShort[d.month - 1];
}
