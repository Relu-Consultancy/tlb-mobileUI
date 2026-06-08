import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
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
}
