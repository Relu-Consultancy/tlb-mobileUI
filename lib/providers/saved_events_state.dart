import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../models/event_model.dart';
import 'auth_state.dart';
import '../widgets/login_sheet.dart';
import '../services/wishlist_service.dart';

class SavedEventsState {
  static final ValueNotifier<List<EventModel>> savedEvents =
      ValueNotifier<List<EventModel>>([]);

  static bool isSaved(EventModel event) =>
      savedEvents.value.any((e) => e.uniqueId == event.uniqueId);

  // ── API sync ───────────────────────────────────────────────────────────────

  /// Fetches the server wishlist and replaces local state.
  ///
  /// By default fails silently (local state stays) — used for the fire-and-
  /// forget app-startup load. Pass [silent] = false to rethrow errors so a
  /// screen can show an error/Retry state.
  static Future<void> loadFromApi({bool silent = true}) async {
    if (!AuthState.isLoggedIn.value || AuthState.accessToken == null) {
      if (!silent) throw Exception('Please log in to see your favorites.');
      return;
    }
    try {
      final items = await WishlistService.fetchWishlist(AuthState.accessToken!);
      final events = items
          .map(_eventFromWishlistItem)
          .where((e) => e.id.isNotEmpty)
          .toList();
      savedEvents.value = events;
    } catch (e) {
      if (!silent) rethrow;
      // Silently ignore — show stale or empty state
    }
  }

  /// Builds an [EventModel] from one wishlist item, tolerating the different
  /// shapes the API uses (nested `listing` object, or fields inline).
  static EventModel _eventFromWishlistItem(Map<String, dynamic> item) {
    final listing = item['listing'] is Map<String, dynamic>
        ? item['listing'] as Map<String, dynamic>
        : item;

    String? s(dynamic v) => v?.toString();
    final id = s(item['listing_id']) ?? s(listing['id']) ?? s(item['id']) ?? '';

    return EventModel(
      id: id,
      title: s(listing['title']) ?? '',
      venue: s(listing['city']) ?? s(listing['area']) ?? '',
      imagePath: s(listing['cover_url']) ?? '',
      tag: s(listing['listing_type']),
    );
  }

  // ── Toggle (optimistic) ────────────────────────────────────────────────────

  /// Optimistic toggle: updates UI immediately, then calls the API.
  /// Reverts + shows snackbar on failure.
  /// Returns the new [isSaved] state.
  static Future<bool> toggle(EventModel event, BuildContext context) async {
    if (!AuthState.isLoggedIn.value) {
      showLoginSheet(context);
      return isSaved(event);
    }

    final wasLiked = isSaved(event);
    final willBeLiked = !wasLiked;

    // Optimistic local update
    final list = List<EventModel>.from(savedEvents.value);
    if (wasLiked) {
      list.removeWhere((e) => e.uniqueId == event.uniqueId);
    } else {
      list.add(event);
    }
    savedEvents.value = list;

    // API call only for real listing IDs
    if (event.id.isNotEmpty && AuthState.accessToken != null) {
      try {
        if (willBeLiked) {
          await WishlistService.add(AuthState.accessToken!, event.id);
        } else {
          await WishlistService.remove(AuthState.accessToken!, event.id);
        }
      } catch (e) {
        // Revert optimistic update
        final revert = List<EventModel>.from(savedEvents.value);
        if (willBeLiked) {
          revert.removeWhere((el) => el.uniqueId == event.uniqueId);
        } else {
          if (!revert.any((el) => el.uniqueId == event.uniqueId)) {
            revert.add(event);
          }
        }
        savedEvents.value = revert;

        if (context.mounted) {
          AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
        }
        return wasLiked;
      }
    }

    return willBeLiked;
  }

  // ── Local helpers ──────────────────────────────────────────────────────────

  static void remove(EventModel event) {
    final list = List<EventModel>.from(savedEvents.value);
    list.removeWhere((e) => e.uniqueId == event.uniqueId);
    savedEvents.value = list;
  }

  static void clear() {
    savedEvents.value = [];
  }
}
