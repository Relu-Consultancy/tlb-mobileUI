import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../providers/auth_state.dart';
import 'auth_http.dart';

/// `POST /api/v1/activity/track/` — customer activity events.
///
/// Fire-and-forget by contract: the API always answers 202, and a rejected
/// event is never an application error. Nothing here throws, returns a
/// result, or retries, so a listing open can never wait on it.
class ActivityService {
  ActivityService._();

  static const String _url =
      'https://tlb-api.reluconsultancy.in/api/v1/activity/track/';
  static const _timeout = Duration(seconds: 10);

  static final RegExp _uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false);

  /// Test seam: the request sender, the real authenticated POST by default.
  static Future<void> Function(Map<String, dynamic> body) send = _post;

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
  static void trackListingView({
    required String listingId,
    String? source,
  }) {
    if (!AuthState.isLoggedIn.value) return;
    if (!_uuid.hasMatch(listingId)) return;
    unawaited(send({
      'event_type': 'view_listing',
      'listing_id': listingId,
      'platform': 'app',
      if (source != null && source.isNotEmpty) 'utm_source': source,
    }).catchError((_) {}));
  }

  static Future<void> _post(Map<String, dynamic> body) async {
    try {
      await AuthHttp.send((t) => http
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': 'Bearer $t',
              'Content-Type': 'application/json',
              'X-Client-Platform': 'app',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout));
    } catch (_) {
      // Offline, timed out, or rate-limited — a missed view is acceptable.
    }
  }
}
