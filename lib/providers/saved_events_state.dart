import 'package:flutter/material.dart';
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
  /// Silent fail — local state stays if the network call errors.
  static Future<void> loadFromApi() async {
    if (!AuthState.isLoggedIn.value || AuthState.accessToken == null) return;
    try {
      final items = await WishlistService.fetchWishlist(AuthState.accessToken!);
      final events = items.map((item) {
        final listing = item['listing'] as Map<String, dynamic>?;
        return EventModel(
          id: (item['listing_id'] as String?) ?? '',
          title: (listing?['title'] as String?) ?? '',
          venue: (listing?['city'] as String?) ?? '',
          imagePath: (listing?['cover_url'] as String?) ?? '',
          tag: listing?['listing_type'] as String?,
        );
      }).where((e) => e.id.isNotEmpty).toList();
      savedEvents.value = events;
    } catch (_) {
      // Silently ignore — show stale or empty state
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
