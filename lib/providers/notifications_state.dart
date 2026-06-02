import 'package:flutter/foundation.dart';

/// Tracks the number of unread notifications.
///
/// The home-header bell badge listens to [unreadCount] and only paints the
/// red dot when it's > 0. Defaults to 0 — no dot is shown until the
/// notifications API is wired up to update this notifier.
class NotificationsState {
  NotificationsState._();

  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Convenience helper for callers that just need a boolean.
  static bool get hasUnread => unreadCount.value > 0;

  /// Call when notifications are fetched / marked-read.
  static void setUnread(int count) {
    unreadCount.value = count < 0 ? 0 : count;
  }

  /// Convenience helper for "mark all as read" actions.
  static void clear() => unreadCount.value = 0;
}
