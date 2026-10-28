import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/auth_state.dart';
import 'auth_http.dart';

/// `POST /api/v1/activity/track/` — customer activity events.
///
/// The app reports only what the backend can't see for itself — the endpoint
/// accepts just four types, and anything else is a 400:
///  - `view_listing` for event, class and program detail. **Not venues**: the
///    backend records a venue view on GET /listings/venues/{id}/, so sending
///    one would count it twice.
///  - `search`, on a committed search (not per keystroke).
///  - `apply_filters`, once per applied filter set (not per tap).
///  - `share`.
/// Login, favourites, checkout, bookings, enquiries and reviews are recorded
/// server-side and must not be sent.
///
/// Fire-and-forget by contract: the API always answers 202, and a rejected
/// event is never an application error. Nothing here throws, returns a
/// result, or retries, so a listing open can never wait on it. Signed-out
/// customers are not tracked (the endpoint 401s without a token).
class ActivityService {
  ActivityService._();

  static const String _url =
      'https://tlb-api.reluconsultancy.in/api/v1/activity/track/';
  static const _timeout = Duration(seconds: 10);

  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Test seam: the request sender, the real authenticated POST by default.
  static Future<void> Function(Map<String, dynamic> body) send = _post;

  /// Test seam: the clock behind the rate limit and de-duplication.
  static DateTime Function() now = DateTime.now;

  /// The API allows 60 events a minute per user, then answers 429. Stay a
  /// little under it and drop the excess rather than earn the errors.
  static const int _perMinute = 55;
  static final List<DateTime> _sentAt = [];

  // De-duplication: the same search term, or the same filter set on the same
  // screen, is one event — not one per submit, result tap or sheet close.
  static String? _lastSearch;
  static DateTime? _lastSearchAt;
  static const Duration _searchRepeatWindow = Duration(minutes: 1);
  static final Map<String, String> _lastFilterSet = {};

  // ── Partner profile views (POST /partner/{id}/track-view/) ──────────────
  static const String _partnerBase =
      'https://tlb-api.reluconsultancy.in/api/v1/partner';

  /// That endpoint allows 20 a minute; stay a little under.
  static const int _partnerPerMinute = 18;
  static final List<DateTime> _partnerSentAt = [];

  /// The server counts the same viewer and partner once per 30 minutes, so a
  /// repeat inside that window only spends rate limit.
  static const Duration _partnerRepeatWindow = Duration(minutes: 30);
  static final Map<String, DateTime> _partnerSeen = {};

  /// Test seam: sends one partner view; the real request by default.
  static Future<void> Function(String partnerId, String? token)
      sendPartnerView = _postPartnerView;

  static void resetForTest() {
    send = _post;
    sendPartnerView = _postPartnerView;
    now = DateTime.now;
    _sentAt.clear();
    _lastSearch = null;
    _lastSearchAt = null;
    _lastFilterSet.clear();
    _partnerSentAt.clear();
    _partnerSeen.clear();
  }

  /// A customer opened a partner's profile — the "profile views" count on the
  /// partner's dashboard. Unlike the events above, this works signed out.
  /// Call once per open of the profile, never per rebuild.
  static void trackPartnerView(String partnerId) {
    try {
      if (!_uuid.hasMatch(partnerId)) return;
      final at = now();
      final last = _partnerSeen[partnerId];
      if (last != null && at.difference(last) < _partnerRepeatWindow) return;
      _partnerSentAt
          .removeWhere((t) => at.difference(t) >= const Duration(minutes: 1));
      if (_partnerSentAt.length >= _partnerPerMinute) return;
      _partnerSentAt.add(at);
      _partnerSeen[partnerId] = at;
      // Signed in: let the server de-duplicate by customer rather than IP.
      final token = AuthState.isLoggedIn.value ? AuthState.accessToken : null;
      unawaited(sendPartnerView(partnerId, token).catchError((_) {}));
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  static Future<void> _postPartnerView(String partnerId, String? token) async {
    Future<http.Response> post(String? t) => http
        .post(
          Uri.parse('$_partnerBase/$partnerId/track-view/'),
          headers: {
            'X-Client-Platform': 'app',
            if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
          },
        )
        .timeout(_timeout);
    try {
      var res = await post(token);
      // The endpoint works anonymously but rejects an expired token outright
      // (401, verified against the live API). Resend without it rather than
      // lose the view — and never log the customer out over it.
      if (res.statusCode == 401 && token != null) res = await post(null);
      if (kDebugMode) {
        debugPrint('activity partner_view -> ${res.statusCode}'
            '${res.statusCode == 200 ? '' : ' ${res.body}'}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('activity partner_view failed: $e');
    }
  }

  /// Reports one open of a listing's detail screen — the Listing View behind
  /// a partner's view counts, view-to-enquiry conversion and traffic sources.
  ///
  /// Call once per open, never per rebuild or for a card merely shown in a
  /// list. [source] is a [ListingSource] value, or null when unknown.
  ///
  /// Skipped when signed out (the endpoint has no anonymous path) and when
  /// [listingId] is not a real listing UUID: the bundled placeholder cards
  /// shown before a feed loads have no id, and a view the backend cannot
  /// attribute to a listing counts toward no partner's stats anyway.
  static void trackListingView({required String listingId, String? source}) {
    try {
      if (!_uuid.hasMatch(listingId)) return;
      _track({
        'event_type': 'view_listing',
        'listing_id': listingId,
        if (source != null && source.isNotEmpty) 'utm_source': source,
      });
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  /// A committed search: the keyboard's search key, or opening a result.
  /// Never per keystroke. The same term again within a minute is skipped, so
  /// submitting and then tapping a result counts once.
  static void trackSearch(
    String term, {
    String? scope,
    Map<String, Object?> filters = const {},
    int? resultCount,
  }) {
    try {
      final t = term.trim();
      if (t.isEmpty) return;
      final key = t.toLowerCase();
      final at = now();
      final last = _lastSearchAt;
      if (key == _lastSearch &&
          last != null &&
          at.difference(last) < _searchRepeatWindow) {
        return;
      }
      if (!AuthState.isLoggedIn.value) return;
      _lastSearch = key;
      _lastSearchAt = at;
      _track({
        'event_type': 'search',
        'metadata': {
          'term': t,
          'scope': ?scope,
          'results': ?resultCount,
          ...filters,
        },
      });
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  /// An applied filter set on [screen] (e.g. `category_events`, `search`).
  /// Sent once per distinct set: applying the same selection again, or
  /// closing the sheet without changing anything, sends nothing. An empty set
  /// (everything cleared) is reported once, as a change back to no filters.
  static void trackFilters(String screen, Map<String, Object?> filters) {
    try {
      final clean = _metadata(filters);
      final signature = jsonEncode(
        Map.fromEntries(
          clean.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        ),
      );
      if (_lastFilterSet[screen] == signature) return;
      // An empty set on a screen that never had filters is not an event.
      if (clean.isEmpty && !_lastFilterSet.containsKey(screen)) return;
      if (!AuthState.isLoggedIn.value) return;
      _lastFilterSet[screen] = signature;
      _track({
        'event_type': 'apply_filters',
        'metadata': {'screen': screen, ...clean},
      });
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  /// The customer opened the share sheet for something. [type] is
  /// `event`, `class`, `program`, `venue` or `partner`. A listing goes in
  /// `listing_id`; a partner profile isn't a listing, so its id travels in
  /// metadata instead (an unknown listing_id would only be dropped anyway).
  static void trackShare({required String type, String? id}) {
    try {
      final hasId = id != null && _uuid.hasMatch(id);
      final isPartner = type == 'partner';
      _track({
        'event_type': 'share',
        if (hasId && !isPartner) 'listing_id': id,
        'metadata': {
          'listing_type': type,
          if (hasId && isPartner) 'partner_id': id,
        },
      });
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  static void _track(Map<String, dynamic> body) {
    try {
      if (!AuthState.isLoggedIn.value) return;
      final at = now();
      _sentAt.removeWhere(
        (t) => at.difference(t) >= const Duration(minutes: 1),
      );
      if (_sentAt.length >= _perMinute) return;
      _sentAt.add(at);
      final meta = body['metadata'];
      unawaited(
        send({
          ...body,
          'platform': 'app',
          if (meta is Map<String, Object?>) 'metadata': _metadata(meta),
        }).catchError((_) {}),
      );
    } catch (_) {
      // Tracking must never break the screen that triggered it.
    }
  }

  /// The API keeps at most 20 metadata keys and 200 characters per value.
  /// Trimmed here so what is sent is what is stored; empty values dropped.
  static Map<String, Object> _metadata(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final e in raw.entries) {
      if (out.length == 20) break;
      final v = e.value;
      if (v == null) continue;
      if (v is num || v is bool) {
        out[e.key] = v;
        continue;
      }
      final text = v is Iterable ? v.join(', ') : v.toString();
      final t = text.trim();
      if (t.isEmpty) continue;
      out[e.key] = t.length > 200 ? t.substring(0, 200) : t;
    }
    return out;
  }

  static Future<void> _post(Map<String, dynamic> body) async {
    try {
      final res = await AuthHttp.send(
        (t) => http
            .post(
              Uri.parse(_url),
              headers: {
                'Authorization': 'Bearer $t',
                'Content-Type': 'application/json',
                'X-Client-Platform': 'app',
              },
              body: jsonEncode(body),
            )
            .timeout(_timeout),
        // Never sign the customer out over an analytics event.
        logoutOnFailure: false,
      );
      // Debug builds only: the reply is otherwise discarded, so a rejected
      // event (400/401/429) would be invisible. Expect 202.
      if (kDebugMode) {
        debugPrint(
          'activity ${body['event_type']} -> ${res.statusCode}'
          '${res.statusCode == 202 ? '' : ' ${res.body}'}',
        );
      }
    } catch (e) {
      // Offline, timed out, or rate-limited — a missed event is acceptable.
      if (kDebugMode) debugPrint('activity ${body['event_type']} failed: $e');
    }
  }
}
