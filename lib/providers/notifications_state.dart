import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/push_notifications.dart';
import 'auth_state.dart';

/// Tracks the number of unread notifications.
///
/// The home-header bell badge listens to [unreadCount] and only paints the
/// red dot when it's > 0.
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

  /// Decrement by one (e.g. after marking a single notification read), never
  /// going below zero.
  static void decrement() {
    if (unreadCount.value > 0) unreadCount.value -= 1;
  }

  /// Fire-and-forget: pull the unread count from the API and update the badge.
  /// No-op when logged out or on any network error (keeps the current value).
  static Future<void> refreshFromApi() async {
    final token = AuthState.accessToken;
    if (token == null || token.isEmpty) return;
    final count = await NotificationService.unreadCount(token: token);
    if (count != null) setUnread(count);
  }

  static const _seenKey = 'seen_notification_ids';

  /// Mirrors freshly-arrived in-app notifications to the device's system tray.
  ///
  /// Fetches the latest page, compares against the IDs we've already surfaced
  /// (persisted), and raises a local notification for each NEW unread item.
  /// On the very first run it just seeds the seen-set so the user isn't blasted
  /// with a tray full of pre-existing notifications. No-op when logged out /
  /// offline. Call on app start and whenever the app returns to the foreground.
  static Future<void> syncAndNotify() async {
    final token = AuthState.accessToken;
    if (token == null || token.isEmpty) return;
    try {
      final page = await NotificationService.listInApp(
        token: token,
        page: 1,
        pageSize: 20,
      );
      final prefs = await SharedPreferences.getInstance();
      final firstRun = !prefs.containsKey(_seenKey);
      final seen = prefs.getStringList(_seenKey)?.toSet() ?? <String>{};

      if (!firstRun) {
        // Oldest-first so the tray ordering matches arrival order.
        for (final n in page.results.reversed) {
          if (n.id.isEmpty || n.isRead || seen.contains(n.id)) continue;
          await PushNotifications.showLocal(
            title: n.title.isEmpty ? 'New notification' : n.title,
            body: n.body,
            payload: n.id,
          );
        }
      }

      // Record every fetched ID as seen (cap the set so it can't grow forever).
      seen.addAll(page.results.map((n) => n.id).where((id) => id.isNotEmpty));
      final capped = seen.toList();
      if (capped.length > 300) {
        capped.removeRange(0, capped.length - 300);
      }
      await prefs.setStringList(_seenKey, capped);
    } catch (_) {
      // Best-effort — never disrupt the UI over a tray mirror.
    }
  }
}
