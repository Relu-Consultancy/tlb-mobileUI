/// Whether a listing's run is over.
///
/// Only events carry a schedule — `start_datetime` / `end_datetime`. Classes,
/// programs and venues have no end date at all (they recur, or in the case of a
/// venue simply exist), so nothing here applies to them.
///
/// Note the public **list** endpoint returns `start_datetime` and `has_started`
/// but **not** `end_datetime`; only the detail response carries it. So a
/// finished event can only be identified once its detail has been fetched —
/// see [hasEnded]. Hiding finished events from a list needs `end_datetime` (or
/// a `has_ended` flag) on the list card.
class ListingSchedule {
  const ListingSchedule._();

  /// True once the event's end has passed.
  ///
  /// [now] is injectable so this is testable without leaning on the clock.
  static bool hasEnded(DateTime? end, {DateTime? now}) {
    if (end == null) return false;
    return end.isBefore(now ?? DateTime.now());
  }

  /// True while the event is running — started, but not yet finished.
  static bool isInProgress(DateTime? start, DateTime? end, {DateTime? now}) {
    final t = now ?? DateTime.now();
    if (start == null || start.isAfter(t)) return false;
    return !hasEnded(end, now: t);
  }
}
