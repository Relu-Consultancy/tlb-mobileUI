/// Whether a listing's run is over.
///
/// Only events carry a schedule — `start_datetime` / `end_datetime`. Classes,
/// programs and venues have no end date at all (they recur, or in the case of a
/// venue simply exist), so nothing here applies to them.
///
/// The public **list** endpoint now returns `end_datetime` on every card
/// (confirmed live 2026-08-24), so a finished event can be filtered out of a
/// list without fetching its detail — see [hasEnded]. The list also carries a
/// field named `has_started`, but do not use it: live data shows it is
/// actually `end_datetime < now` (an event that had visibly started but not
/// yet ended came back `has_started: false`), the opposite of what its name
/// says. Comparing `end_datetime` directly, as this class does, sidesteps
/// that mislabelling entirely.
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
