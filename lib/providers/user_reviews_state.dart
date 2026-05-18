import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_review_model.dart';
import '../providers/auth_state.dart';
import '../services/review_service.dart';

class UserReviewsState {
  static final ValueNotifier<List<ApiReview>> reviewsNotifier = ValueNotifier([]);
  static bool _loaded = false;

  static const _prefsKey = 'user_reviews_v1';

  // ── Persistence ─────────────────────────────────────────────────────────────

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = reviewsNotifier.value.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_prefsKey, encoded);
    } catch (_) {}
  }

  static Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? [];
      if (raw.isEmpty) return;
      reviewsNotifier.value = List.unmodifiable(
        raw.map((s) => ApiReview.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList(),
      );
      _loaded = true;
    } catch (_) {}
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Loads reviews from local storage, then refreshes media for each review
  /// via `GET /api/v1/reviews/{review_id}/media/`.
  /// Never throws — callers always get a result.
  static Future<void> loadFromApi() async {
    await _loadFromStorage();
    final token = AuthState.accessToken;
    if (token == null || reviewsNotifier.value.isEmpty) return;
    try {
      final enriched = await Future.wait(reviewsNotifier.value.map((r) async {
        try {
          final media = await ReviewService.fetchReviewMedia(token, r.id);
          return media.isNotEmpty ? r.copyWith(media: media) : r;
        } catch (_) {
          return r;
        }
      }));
      reviewsNotifier.value = List.unmodifiable(enriched);
      _loaded = true;
      await _persist();
    } catch (_) {}
  }

  static bool get isLoaded => _loaded;

  /// Adds a new review or replaces an existing one (matched by id).
  static Future<void> upsert(ApiReview review) async {
    final current = List<ApiReview>.from(reviewsNotifier.value);
    final idx = current.indexWhere((r) => r.id == review.id);
    if (idx >= 0) {
      current[idx] = review;
    } else {
      current.insert(0, review);
    }
    reviewsNotifier.value = List.unmodifiable(current);
    await _persist();
  }

  static Future<void> remove(int reviewId) async {
    reviewsNotifier.value = List.unmodifiable(
      reviewsNotifier.value.where((r) => r.id != reviewId).toList(),
    );
    await _persist();
  }

  static Future<void> clear() async {
    reviewsNotifier.value = [];
    _loaded = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }
}
