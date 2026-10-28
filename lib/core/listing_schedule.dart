/// Whether a listing's run is over.
///
/// Applies to **events and programs** — both carry a real `start_datetime` /
/// `end_datetime`. For a program, `end_datetime` is the *latest* active
/// batch's end (a program is over only once every batch is, unlike an
/// event's single start/end), aggregated server-side — the client still just
/// compares the one field.
///
/// Classes and venues have no end date at all, by design, not by omission:
///  - A class is an open-ended recurring schedule — its batches have a daily
///    start_time/end_time but no end_date column, so there is no date on
///    which a class finishes. Use `ApiClass.isPaused` instead: the
///    partner-controlled "not currently bookable" signal for a class.
///  - A venue is a permanently bookable space; its availability rows are
///    individual slots, not a run of dates. A venue with no upcoming slots
///    needs more slots published — it has not "ended".
/// Nothing in this class applies to either type; passing a class's or
/// venue's (always-null) `endDatetime` through [hasEnded] harmlessly
/// returns false, but the real signal for a class is `isPaused`, checked
/// separately at each call site.
///
/// The public **list** endpoint returns `end_datetime` on every event and
/// program card (confirmed live 2026-08-24), so a finished one can be
/// filtered out of a list without fetching its detail — see [hasEnded]. The
/// list also carries a field named `has_started`, but do not use it: live
/// event data shows it is actually `end_datetime < now`, not `start_datetime
/// < now` (an event that had visibly started but not yet ended came back
/// `has_started: false`), the opposite of what its name says. Comparing
/// `end_datetime` directly, as this class does, sidesteps that mislabelling
/// entirely.
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
