/// Formats a 24-hour time string as 12-hour clock time.
///
/// `"16:00:00"` -> `"4 PM"`, `"16:30:00"` -> `"4:30 PM"`. An on-the-hour time
/// drops the `:00` minutes — the style every batch-schedule row in the app
/// has used since the classes/programs batch pickers first needed one, kept
/// here as the one shared definition instead of a private copy per screen.
class TimeFormat {
  const TimeFormat._();

  static String h12(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    var h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final ampm = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return m == '00' ? '$h $ampm' : '$h:$m $ampm';
  }
}
